##########################################################################
#
# pgAdmin 4 - PostgreSQL Tools
#
# Copyright (C) 2013 - 2019, The pgAdmin Development Team
# This software is released under the PostgreSQL Licence
#
##########################################################################

""" Implements Table Node """

import simplejson as json
import re

import pgadmin.browser.server_groups.servers.databases as database
from flask import render_template, request, jsonify, url_for
from flask_babelex import gettext
from pgadmin.browser.server_groups.servers.databases.schemas.utils \
    import SchemaChildModule, DataTypeReader, VacuumSettings
from pgadmin.browser.server_groups.servers.utils import parse_priv_to_db
from pgadmin.utils.ajax import make_json_response, internal_server_error, \
    make_response as ajax_response, gone
from .utils import BaseTableView
from pgadmin.utils.preferences import Preferences
from pgadmin.browser.server_groups.servers.databases.schemas.tables.\
    constraints.foreign_key import utils as fkey_utils
from pgadmin.browser.server_groups.servers.databases.schemas.tables.\
    columns import utils as column_utils


class TableModule(SchemaChildModule):
    """
     class TableModule(SchemaChildModule)

        A module class for Table node derived from SchemaChildModule.

    Methods:
    -------
    * __init__(*args, **kwargs)
      - Method is used to initialize the Table and it's base module.

    * get_nodes(gid, sid, did, scid, tid)
      - Method is used to generate the browser collection node.

    * node_inode()
      - Method is overridden from its base class to make the node as leaf node.

    * script_load()
      - Load the module script for schema, when any of the server node is
        initialized.
    """
    NODE_TYPE = 'table'
    COLLECTION_LABEL = gettext("Tables")

    def __init__(self, *args, **kwargs):
        """
        Method is used to initialize the TableModule and it's base module.

        Args:
            *args:
            **kwargs:
        """
        super(TableModule, self).__init__(*args, **kwargs)
        self.max_ver = None
        self.min_ver = None

    def get_nodes(self, gid, sid, did, scid):
        """
        Generate the collection node
        """
        yield self.generate_browser_collection_node(scid)

    @property
    def script_load(self):
        """
        Load the module script for database, when any of the database node is
        initialized.
        """
        return database.DatabaseModule.NODE_TYPE

    @property
    def csssnippets(self):
        """
        Returns a snippet of css to include in the page
        """
        snippets = [
            render_template(
                "browser/css/collection.css",
                node_type=self.node_type,
            ),
            render_template(
                "browser/css/node.css",
                node_type=self.node_type,
            ),
            render_template(
                "browser/css/node.css",
                node_type='table',
                file_name='table-inherited',
            ),
            render_template(
                "browser/css/node.css",
                node_type='table',
                file_name='table-inherits',
            ),
            render_template(
                "browser/css/node.css",
                node_type='table',
                file_name='table-multi-inherit',
            ),
        ]

        for submodule in self.submodules:
            snippets.extend(submodule.csssnippets)

        return snippets

    def get_own_javascripts(self):
        scripts = SchemaChildModule.get_own_javascripts(self)

        scripts.append({
            'name': 'pgadmin.browser.table.partition.utils',
            'path': url_for('browser.index') +
                    'table/static/js/partition.utils',
            'when': 'database', 'is_template': False
        })

        return scripts


blueprint = TableModule(__name__)


class TableView(BaseTableView, DataTypeReader, VacuumSettings):
    """
    This class is responsible for generating routes for Table node

    Methods:
    -------
    * __init__(**kwargs)
      - Method is used to initialize the TableView and it's base view.

    * list()
      - This function is used to list all the Table nodes within that
      collection.

    * nodes()
      - This function will used to create all the child node within that
        collection, Here it will create all the Table node.

    * properties(gid, sid, did, scid, tid)
      - This function will show the properties of the selected Table node

    * create(gid, sid, did, scid)
      - This function will create the new Table object

    * update(gid, sid, did, scid, tid)
      - This function will update the data for the selected Table node

    * delete(gid, sid, scid, tid):
      - This function will drop the Table object

    * truncate(gid, sid, scid, tid):
      - This function will truncate table object

    * set_trigger(gid, sid, scid, tid):
      - This function will enable/disable trigger(s) on table object

    * reset(gid, sid, scid, tid):
      - This function will reset table object statistics

    * msql(gid, sid, did, scid, tid)
      - This function is used to return modified SQL for the selected
        Table node

    * get_sql(did, scid, tid, data)
      - This function will generate sql from model data

    * sql(gid, sid, did, scid, tid):
      - This function will generate sql to show it in sql pane for the
        selected Table node.

    * dependency(gid, sid, did, scid, tid):
      - This function will generate dependency list show it in dependency
        pane for the selected Table node.

    * dependent(gid, sid, did, scid, tid):
      - This function will generate dependent list to show it in dependent
        pane for the selected node.

    * get_types(self, gid, sid, did, scid)
      - This function will return list of types available for columns node
        via AJAX response

    * get_oftype(self, gid, sid, did, scid, tid)
      - This function will return list of types available for table node
        via AJAX response

    * get_inherits(self, gid, sid, did, scid, tid)
      - This function will return list of tables availablefor inheritance
        via AJAX response

    * get_relations(self, gid, sid, did, scid, tid)
      - This function will return list of tables available for like/relation
        via AJAX response

    * get_columns(gid, sid, did, scid, foid=None):
      - Returns the Table Columns.

    * get_table_vacuum(gid, sid, did, scid=None, tid=None):
      - Fetch the default values for table auto-vacuum

    * get_toast_table_vacuum(gid, sid, did, scid=None, tid=None)
      - Fetch the default values for toast table auto-vacuum

    * get_index_constraint_sql(self, did, tid, data):
      - This function will generate modified sql for index constraints
        (Primary Key & Unique)

    * select_sql(gid, sid, did, scid, foid):
      - Returns sql for Script

    * insert_sql(gid, sid, did, scid, foid):
      - Returns sql for Script

    * update_sql(gid, sid, did, scid, foid):
      - Returns sql for Script

    * delete_sql(gid, sid, did, scid, foid):
      - Returns sql for Script
"""

    node_type = blueprint.node_type

    parent_ids = [
        {'type': 'int', 'id': 'gid'},
        {'type': 'int', 'id': 'sid'},
        {'type': 'int', 'id': 'did'},
        {'type': 'int', 'id': 'scid'}
    ]
    ids = [
        {'type': 'int', 'id': 'tid'}
    ]

    operations = dict({
        'obj': [
            {'get': 'properties', 'delete': 'delete', 'put': 'update'},
            {'get': 'list', 'post': 'create', 'delete': 'delete'}
        ],
        'delete': [{'delete': 'delete'}, {'delete': 'delete'}],
        'children': [{'get': 'children'}],
        'nodes': [{'get': 'node'}, {'get': 'nodes'}],
        'sql': [{'get': 'sql'}],
        'msql': [{'get': 'msql'}, {'get': 'msql'}],
        'stats': [{'get': 'statistics'}, {'get': 'statistics'}],
        'dependency': [{'get': 'dependencies'}],
        'dependent': [{'get': 'dependents'}],
        'get_oftype': [{'get': 'get_oftype'}, {'get': 'get_oftype'}],
        'get_inherits': [{'get': 'get_inherits'}, {'get': 'get_inherits'}],
        'get_relations': [{'get': 'get_relations'}, {'get': 'get_relations'}],
        'truncate': [{'put': 'truncate'}],
        'reset': [{'delete': 'reset'}],
        'set_trigger': [{'put': 'enable_disable_triggers'}],
        'get_types': [{'get': 'types'}, {'get': 'types'}],
        'get_columns': [{'get': 'get_columns'}, {'get': 'get_columns'}],
        'get_table_vacuum': [{}, {'get': 'get_table_vacuum'}],
        'get_toast_table_vacuum': [{}, {'get': 'get_toast_table_vacuum'}],
        'all_tables': [{}, {'get': 'get_all_tables'}],
        'get_access_methods': [{}, {'get': 'get_access_methods'}],
        'get_oper_class': [{}, {'get': 'get_oper_class'}],
        'get_operator': [{}, {'get': 'get_operator'}],
        'get_attach_tables': [
            {'get': 'get_attach_tables'},
            {'get': 'get_attach_tables'}],
        'select_sql': [{'get': 'select_sql'}],
        'insert_sql': [{'get': 'insert_sql'}],
        'update_sql': [{'get': 'update_sql'}],
        'delete_sql': [{'get': 'delete_sql'}],
        'count_rows': [{'get': 'count_rows'}]
    })

    @BaseTableView.check_precondition
    def list(self, gid, sid, did, scid):
        """
        This function is used to list all the table nodes within that
        collection.

        Args:
            gid: Server group ID
            sid: Server ID
            did: Database ID
            scid: Schema ID

        Returns:
            JSON of available table nodes
        """
        SQL = render_template(
            "/".join([self.table_template_path, 'properties.sql']),
            did=did, scid=scid,
            datlastsysoid=self.datlastsysoid
        )
        status, res = self.conn.execute_dict(SQL)

        if not status:
            return internal_server_error(errormsg=res)
        return ajax_response(
            response=res['rows'],
            status=200
        )

    def get_icon_css_class(self, table_info, default_val='icon-table'):
        if ('is_inherits' in table_info and
            table_info['is_inherits'] == '1') or \
                ('coll_inherits' in table_info and
                 len(table_info['coll_inherits']) > 0):

            if ('is_inherited' in table_info and
                table_info['is_inherited'] == '1')\
                    or ('relhassubclass' in table_info and
                        table_info['relhassubclass']):
                default_val = 'icon-table-multi-inherit'
            else:
                default_val = 'icon-table-inherits'
        elif ('is_inherited' in table_info and
              table_info['is_inherited'] == '1')\
                or ('relhassubclass' in table_info and
                    table_info['relhassubclass']):
            default_val = 'icon-table-inherited'

        return super(TableView, self).\
            get_icon_css_class(table_info, default_val)

    @BaseTableView.check_precondition
    def node(self, gid, sid, did, scid, tid):
        """
        This function is used to list all the table nodes within that
        collection.

        Args:
            gid: Server group ID
            sid: Server ID
            did: Database ID
            scid: Schema ID
            tid: Table ID

        Returns:
            JSON of available table nodes
        """
        res = []
        SQL = render_template(
            "/".join([self.table_template_path, 'nodes.sql']),
            scid=scid, tid=tid
        )
        status, rset = self.conn.execute_2darray(SQL)
        if not status:
            return internal_server_error(errormsg=rset)
        if len(rset['rows']) == 0:
            return gone(gettext("Could not find the table."))

        table_information = rset['rows'][0]
        icon = self.get_icon_css_class(table_information)

        res = self.blueprint.generate_browser_node(
            table_information['oid'],
            scid,
            table_information['name'],
            icon=icon,
            tigger_count=table_information['triggercount'],
            has_enable_triggers=table_information['has_enable_triggers'],
            is_partitioned=self.is_table_partitioned(table_information)
        )

        return make_json_response(
            data=res,
            status=200
        )

    @BaseTableView.check_precondition
    def nodes(self, gid, sid, did, scid):
        """
        This function is used to list all the table nodes within that
        collection.

        Args:
            gid: Server group ID
            sid: Server ID
            did: Database ID
            scid: Schema ID

        Returns:
            JSON of available table nodes
        """
        res = []
        SQL = render_template(
            "/".join([self.table_template_path, 'nodes.sql']),
            scid=scid
        )
        status, rset = self.conn.execute_2darray(SQL)
        if not status:
            return internal_server_error(errormsg=rset)

        for row in rset['rows']:
            icon = self.get_icon_css_class(row)

            res.append(
                self.blueprint.generate_browser_node(
                    row['oid'],
                    scid,
                    row['name'],
                    icon=icon,
                    tigger_count=row['triggercount'],
                    has_enable_triggers=row['has_enable_triggers'],
                    is_partitioned=self.is_table_partitioned(row),
                    rows_cnt=0
                ))

        return make_json_response(
            data=res,
            status=200
        )

    @BaseTableView.check_precondition
    def get_all_tables(self, gid, sid, did, scid, tid=None):
        """
        Args:
            gid: Server Group Id
            sid: Server Id
            did: Database Id
            scid: Schema Id
            tid: Table Id

        Returns:
            Returns the lits of tables required for constraints.
        """
        try:
            SQL = render_template(
                "/".join([
                    self.table_template_path, 'get_tables_for_constraints.sql'
                ]),
                show_sysobj=self.blueprint.show_system_objects
            )

            status, res = self.conn.execute_dict(SQL)

            if not status:
                return internal_server_error(errormsg=res)

            return make_json_response(
                data=res['rows'],
                status=200
            )

        except Exception as e:
            return internal_server_error(errormsg=str(e))

    @BaseTableView.check_precondition
    def get_table_vacuum(self, gid, sid, did, scid=None, tid=None):
        """
        Fetch the default values for table auto-vacuum
        fields, return an array of
          - label
          - name
          - setting
        values
        """
        res = self.get_vacuum_table_settings(self.conn)
        return ajax_response(
            response=res['rows'],
            status=200
        )

    @BaseTableView.check_precondition
    def get_toast_table_vacuum(self, gid, sid, did, scid=None, tid=None):
        """
        Fetch the default values for toast table auto-vacuum
        fields, return an array of
          - label
          - name
          - setting
        values
        """
        res = self.get_vacuum_toast_settings(self.conn)
        return ajax_response(
            response=res['rows'],
            status=200
        )

    @BaseTableView.check_precondition
    def get_access_methods(self, gid, sid, did, scid, tid=None):
        """
        This function returns access methods.

        Args:
          gid: Server Group ID
          sid: Server ID
          did: Database ID
          scid: Schema ID
          tid: Table ID
          exid: Exclusion constraint ID

        Returns:

        """
        res = [{'label': '', 'value': ''}]
        sql = render_template("/".join([
            self.exclusion_constraint_template_path, 'get_access_methods.sql'
        ]))

        status, rest = self.conn.execute_2darray(sql)

        if not status:
            return internal_server_error(errormsg=rest)

        for row in rest['rows']:
            res.append(
                {'label': row['amname'], 'value': row['amname']}
            )
        return make_json_response(
            data=res,
            status=200
        )

    @BaseTableView.check_precondition
    def get_oper_class(self, gid, sid, did, scid, tid=None):
        """

        Args:
          gid: Server Group ID
          sid: Server ID
          did: Database ID
          scid: Schema ID
          tid: Table ID
          exid: Exclusion constraint ID

        Returns:

        """
        data = request.args if request.args else None
        try:
            if data and 'indextype' in data:
                SQL = render_template(
                    "/".join([
                        self.exclusion_constraint_template_path,
                        'get_oper_class.sql'
                    ]),
                    indextype=data['indextype']
                )

                status, res = self.conn.execute_2darray(SQL)

                if not status:
                    return internal_server_error(errormsg=res)
                result = []
                for row in res['rows']:
                    result.append([row['opcname'], row['opcname']])
                return make_json_response(
                    data=result,
                    status=200
                )
        except Exception as e:
            return internal_server_error(errormsg=str(e))

    @BaseTableView.check_precondition
    def get_operator(self, gid, sid, did, scid, tid=None):
        """

        Args:
          gid: Server Group ID
          sid: Server ID
          did: Database ID
          scid: Schema ID
          tid: Table ID
          exid: Exclusion constraint ID

        Returns:

        """
        data = request.args if request.args else None
        try:
            if data and 'col_type' in data:
                SQL = render_template(
                    "/".join([
                        self.exclusion_constraint_template_path,
                        'get_operator.sql'
                    ]),
                    type=data['col_type'],
                    show_sysobj=self.blueprint.show_system_objects
                )

                status, res = self.conn.execute_2darray(SQL)

                if not status:
                    return internal_server_error(errormsg=res)
                result = []
                for row in res['rows']:
                    result.append([row['oprname'], row['oprname']])
                return make_json_response(
                    data=result,
                    status=200
                )
        except Exception as e:
            return internal_server_error(errormsg=str(e))

    @BaseTableView.check_precondition
    def properties(self, gid, sid, did, scid, tid):
        """
        This function will show the properties of the selected table node.

        Args:
            gid: Server Group ID
            sid: Server ID
            did:  Database ID
            scid: Schema ID
            scid: Schema ID
            tid: Table ID

        Returns:
            JSON of selected table node
        """

        SQL = render_template(
            "/".join([self.table_template_path, 'properties.sql']),
            did=did, scid=scid, tid=tid,
            datlastsysoid=self.datlastsysoid
        )
        status, res = self.conn.execute_dict(SQL)
        if not status:
            return internal_server_error(errormsg=res)

        if len(res['rows']) == 0:
            return gone(gettext("The specified table could not be found."))

        # We will check the threshold set by user before executing
        # the query because that can cause performance issues
        # with large result set
        pref = Preferences.module('browser')
        table_row_count_pref = pref.preference('table_row_count_threshold')
        table_row_count_threshold = table_row_count_pref.get()
        estimated_row_count = int(res['rows'][0].get('reltuples', 0))

        # If estimated rows are greater than threshold then
        if estimated_row_count and \
                estimated_row_count > table_row_count_threshold:
            res['rows'][0]['rows_cnt'] = str(table_row_count_threshold) + '+'

        # If estimated rows is lower than threshold then calculate the count
        elif estimated_row_count and \
                table_row_count_threshold >= estimated_row_count:
            SQL = render_template(
                "/".join(
                    [self.table_template_path, 'get_table_row_count.sql']
                ), data=res['rows'][0]
            )

            status, count = self.conn.execute_scalar(SQL)

            if not status:
                return internal_server_error(errormsg=count)

            res['rows'][0]['rows_cnt'] = count

        # If estimated_row_count is zero then set the row count with same
        elif not estimated_row_count:
            res['rows'][0]['rows_cnt'] = estimated_row_count

        return super(TableView, self).properties(
            gid, sid, did, scid, tid, res
        )

    @BaseTableView.check_precondition
    def types(self, gid, sid, did, scid, tid=None, clid=None):
        """
        Returns:
            This function will return list of types available for column node
            for node-ajax-control
        """
        condition = render_template(
            "/".join([
                self.table_template_path, 'get_types_where_condition.sql'
            ]),
            show_system_objects=self.blueprint.show_system_objects
        )

        status, types = self.get_types(self.conn, condition, True, sid)

        if not status:
            return internal_server_error(errormsg=types)

        return make_json_response(
            data=types,
            status=200
        )

    @BaseTableView.check_precondition
    def get_columns(self, gid, sid, did, scid, tid=None):
        """
        Returns the Table Columns.

        Args:
            gid: Server Group Id
            sid: Server Id
            did: Database Id
            scid: Schema Id
            tid: Table Id

        Returns:
              JSON Array with below parameters.
              name: Column Name
              ctype: Column Data Type
              inherited_from: Parent Table from which the related column
                              is inheritted.
        """
        res = []
        data = request.args if request.args else None
        try:
            if data and 'tid' in data:
                SQL = render_template(
                    "/".join([
                        self.table_template_path, 'get_columns_for_table.sql'
                    ]),
                    tid=data['tid']
                )
            elif data and 'tname' in data:
                SQL = render_template(
                    "/".join([
                        self.table_template_path, 'get_columns_for_table.sql'
                    ]),
                    tname=data['tname']
                )

            if SQL:
                status, res = self.conn.execute_dict(SQL)
                if not status:
                    return internal_server_error(errormsg=res)
                res = res['rows']

            return make_json_response(
                data=res,
                status=200
            )

        except Exception as e:
            return internal_server_error(errormsg=str(e))

    @BaseTableView.check_precondition
    def get_oftype(self, gid, sid, did, scid, tid=None):
        """
        Returns:
            This function will return list of types available for table node
            for node-ajax-control
        """
        res = [{'label': '', 'value': ''}]
        try:
            SQL = render_template(
                "/".join([self.table_template_path, 'get_oftype.sql']),
                scid=scid,
                server_type=self.manager.server_type,
                show_sys_objects=self.blueprint.show_system_objects
            )
            status, rset = self.conn.execute_2darray(SQL)
            if not status:
                return internal_server_error(errormsg=res)
            for row in rset['rows']:
                # Get columns for all 'OF TYPES'.
                SQL = render_template(
                    "/".join(
                        [self.table_template_path,
                         'get_columns_for_table.sql']
                    ), tid=row['oid']
                )

                status, type_cols = self.conn.execute_dict(SQL)
                if not status:
                    return internal_server_error(errormsg=type_cols)

                res.append({
                    'label': row['typname'],
                    'value': row['typname'],
                    'tid': row['oid'],
                    'oftype_columns': type_cols['rows']
                })
            return make_json_response(
                data=res,
                status=200
            )

        except Exception as e:
            return internal_server_error(errormsg=str(e))

    @BaseTableView.check_precondition
    def get_inherits(self, gid, sid, did, scid, tid=None):
        """
        Returns:
            This function will return list of tables available for inheritance
            while creating new table
        """
        try:
            res = []
            SQL = render_template(
                "/".join([self.table_template_path, 'get_inherits.sql']),
                show_system_objects=self.blueprint.show_system_objects,
                tid=tid,
                scid=scid,
                server_type=self.manager.server_type
            )
            status, rset = self.conn.execute_2darray(SQL)
            if not status:
                return internal_server_error(errormsg=res)
            for row in rset['rows']:
                res.append(
                    {'label': row['inherits'], 'value': row['inherits'],
                     'tid': row['oid']
                     }
                )
            return make_json_response(
                data=res,
                status=200
            )

        except Exception as e:
            return internal_server_error(errormsg=str(e))

    @BaseTableView.check_precondition
    def get_attach_tables(self, gid, sid, did, scid, tid=None):
        """
        Returns:
            This function will return list of tables available to be attached
            to the partitioned table.
        """
        try:
            res = []
            SQL = render_template(
                "/".join([
                    self.partition_template_path, 'get_attach_tables.sql'
                ]),
                tid=tid
            )

            status, rset = self.conn.execute_2darray(SQL)
            if not status:
                return internal_server_error(errormsg=res)

            for row in rset['rows']:
                res.append(
                    {'label': row['table_name'], 'value': row['oid']}
                )

            return make_json_response(
                data=res,
                status=200
            )

        except Exception as e:
            return internal_server_error(errormsg=str(e))

    @BaseTableView.check_precondition
    def get_relations(self, gid, sid, did, scid, tid=None):
        """
        Returns:
            This function will return list of tables available for
            like/relation combobox while creating new table
        """
        res = [{'label': '', 'value': ''}]
        try:
            SQL = render_template(
                "/".join([self.table_template_path, 'get_relations.sql']),
                show_sys_objects=self.blueprint.show_system_objects,
                server_type=self.manager.server_type
            )
            status, rset = self.conn.execute_2darray(SQL)
            if not status:
                return internal_server_error(errormsg=res)
            for row in rset['rows']:
                res.append(
                    {
                        'label': row['like_relation'],
                        'value': row['like_relation']
                    }
                )
            return make_json_response(
                data=res,
                status=200
            )

        except Exception as e:
            return internal_server_error(errormsg=str(e))

    @BaseTableView.check_precondition
    def create(self, gid, sid, did, scid):
        """
        This function will creates new the table object

         Args:
           gid: Server Group ID
           sid: Server ID
           did: Database ID
           scid: Schema ID
        """
        data = request.form if request.form else json.loads(
            request.data, encoding='utf-8'
        )

        for k, v in data.items():
            try:
                # comments should be taken as is because if user enters a
                # json comment it is parsed by loads which should not happen
                if k in ('description',):
                    data[k] = v
                else:
                    data[k] = json.loads(v, encoding='utf-8')
            except (ValueError, TypeError, KeyError):
                data[k] = v

        required_args = [
            'name'
        ]

        for arg in required_args:
            if arg not in data:
                return make_json_response(
                    status=410,
                    success=0,
                    errormsg=gettext(
                        "Could not find the required parameter (%s)." % arg
                    )
                )

        # Parse privilege data coming from client according to database format
        if 'relacl' in data:
            data['relacl'] = parse_priv_to_db(data['relacl'], self.acl)

        # Parse & format columns
        data = column_utils.parse_format_columns(data)
        data = TableView.check_and_convert_name_to_string(data)

        # 'coll_inherits' is Array but it comes as string from browser
        # We will convert it again to list
        if 'coll_inherits' in data and \
                isinstance(data['coll_inherits'], str):
            data['coll_inherits'] = json.loads(
                data['coll_inherits'], encoding='utf-8'
            )

        if 'foreign_key' in data:
            for c in data['foreign_key']:
                schema, table = fkey_utils.get_parent(
                    self.conn, c['columns'][0]['references'])
                c['remote_schema'] = schema
                c['remote_table'] = table

        try:
            partitions_sql = ''
            if self.is_table_partitioned(data):
                data['relkind'] = 'p'
                # create partition scheme
                data['partition_scheme'] = self.get_partition_scheme(data)
                partitions_sql = self.get_partitions_sql(data)

            SQL = render_template(
                "/".join([self.table_template_path, 'create.sql']),
                data=data, conn=self.conn
            )

            # Append SQL for partitions
            SQL += '\n' + partitions_sql

            status, res = self.conn.execute_scalar(SQL)
            if not status:
                return internal_server_error(errormsg=res)

            # PostgreSQL truncates the table name to 63 characters.
            # Have to truncate the name like PostgreSQL to get the
            # proper OID
            CONST_MAX_CHAR_COUNT = 63

            if len(data['name']) > CONST_MAX_CHAR_COUNT:
                data['name'] = data['name'][0:CONST_MAX_CHAR_COUNT]

            # Get updated schema oid
            SQL = render_template(
                "/".join([self.table_template_path, 'get_schema_oid.sql']),
                tname=data['name']
            )

            status, scid = self.conn.execute_scalar(SQL)
            if not status:
                return internal_server_error(errormsg=scid)

            # we need oid to to add object in tree at browser
            SQL = render_template(
                "/".join([self.table_template_path, 'get_oid.sql']),
                scid=scid, data=data
            )

            status, tid = self.conn.execute_scalar(SQL)
            if not status:
                return internal_server_error(errormsg=tid)

            return jsonify(
                node=self.blueprint.generate_browser_node(
                    tid,
                    scid,
                    data['name'],
                    icon=self.get_icon_css_class(data),
                    is_partitioned=self.is_table_partitioned(data)
                )
            )
        except Exception as e:
            return internal_server_error(errormsg=str(e))

    @BaseTableView.check_precondition
    def update(self, gid, sid, did, scid, tid):
        """
        This function will update an existing table object

         Args:
           gid: Server Group ID
           sid: Server ID
           did: Database ID
           scid: Schema ID
           tid: Table ID
        """
        data = request.form if request.form else json.loads(
            request.data, encoding='utf-8'
        )

        for k, v in data.items():
            try:
                # comments should be taken as is because if user enters a
                # json comment it is parsed by loads which should not happen
                if k in ('description',):
                    data[k] = v
                else:
                    data[k] = json.loads(v, encoding='utf-8')
            except (ValueError, TypeError, KeyError):
                data[k] = v

        try:
            SQL = render_template(
                "/".join([self.table_template_path, 'properties.sql']),
                did=did, scid=scid, tid=tid,
                datlastsysoid=self.datlastsysoid
            )
            status, res = self.conn.execute_dict(SQL)
            if not status:
                return internal_server_error(errormsg=res)

            return super(TableView, self).update(
                gid, sid, did, scid, tid, data, res)
        except Exception as e:
            return internal_server_error(errormsg=str(e))

    @BaseTableView.check_precondition
    def delete(self, gid, sid, did, scid, tid=None):
        """
        This function will deletes the table object

         Args:
           gid: Server Group ID
           sid: Server ID
           did: Database ID
           scid: Schema ID
           tid: Table ID
        """
        if tid is None:
            data = request.form if request.form else json.loads(
                request.data, encoding='utf-8'
            )
        else:
            data = {'ids': [tid]}

        try:
            for tid in data['ids']:
                SQL = render_template(
                    "/".join([self.table_template_path, 'properties.sql']),
                    did=did, scid=scid, tid=tid,
                    datlastsysoid=self.datlastsysoid
                )
                status, res = self.conn.execute_dict(SQL)
                if not status:
                    return internal_server_error(errormsg=res)

                if not res['rows']:
                    return make_json_response(
                        success=0,
                        errormsg=gettext(
                            'Error: Object not found.'
                        ),
                        info=gettext(
                            'The specified table could not be found.\n'
                        )
                    )

                status, res = super(TableView, self).delete(gid, sid, did,
                                                            scid, tid, res)

                if not status:
                    return internal_server_error(errormsg=res)

            return make_json_response(
                success=1,
                info=gettext("Table dropped")
            )

        except Exception as e:
            return internal_server_error(errormsg=str(e))

    @BaseTableView.check_precondition
    def truncate(self, gid, sid, did, scid, tid):
        """
        This function will truncate the table object

         Args:
           gid: Server Group ID
           sid: Server ID
           did: Database ID
           scid: Schema ID
           tid: Table ID
        """

        try:
            SQL = render_template(
                "/".join([self.table_template_path, 'properties.sql']),
                did=did, scid=scid, tid=tid,
                datlastsysoid=self.datlastsysoid
            )
            status, res = self.conn.execute_dict(SQL)
            if not status:
                return internal_server_error(errormsg=res)

            return super(TableView, self).truncate(
                gid, sid, did, scid, tid, res
            )

        except Exception as e:
            return internal_server_error(errormsg=str(e))

    @BaseTableView.check_precondition
    def enable_disable_triggers(self, gid, sid, did, scid, tid):
        """
        This function will enable/disable trigger(s) on the table object

         Args:
           gid: Server Group ID
           sid: Server ID
           did: Database ID
           scid: Schema ID
           tid: Table ID
        """
        # Below will decide if it's simple drop or drop with cascade call
        data = request.form if request.form else json.loads(
            request.data, encoding='utf-8'
        )
        # Convert str 'true' to boolean type
        is_enable_trigger = data['is_enable_trigger']

        try:
            SQL = render_template(
                "/".join([self.table_template_path, 'properties.sql']),
                did=did, scid=scid, tid=tid,
                datlastsysoid=self.datlastsysoid
            )
            status, res = self.conn.execute_dict(SQL)
            if not status:
                return internal_server_error(errormsg=res)
            data = res['rows'][0]

            SQL = render_template(
                "/".join([
                    self.table_template_path, 'enable_disable_trigger.sql'
                ]),
                data=data, is_enable_trigger=is_enable_trigger
            )
            status, res = self.conn.execute_scalar(SQL)
            if not status:
                return internal_server_error(errormsg=res)

            return make_json_response(
                success=1,
                info=gettext("Trigger(s) have been disabled")
                if is_enable_trigger == 'D'
                else gettext("Trigger(s) have been enabled"),
                data={
                    'id': tid,
                    'scid': scid
                }
            )

        except Exception as e:
            return internal_server_error(errormsg=str(e))

    @BaseTableView.check_precondition
    def reset(self, gid, sid, did, scid, tid):
        """
        This function will reset statistics of table

         Args:
           gid: Server Group ID
           sid: Server ID
           did: Database ID
           scid: Schema ID
           tid: Table ID
        """
        return BaseTableView.reset_statistics(self, scid, tid)

    @BaseTableView.check_precondition
    def msql(self, gid, sid, did, scid, tid=None):
        """
        This function will create modified sql for table object

         Args:
           gid: Server Group ID
           sid: Server ID
           did: Database ID
           scid: Schema ID
           tid: Table ID
        """
        data = dict()
        res = None
        for k, v in request.args.items():
            try:
                # comments should be taken as is because if user enters a
                # json comment it is parsed by loads which should not happen
                if k in ('description',):
                    data[k] = v
                else:
                    data[k] = json.loads(v, encoding='utf-8')
            except (ValueError, TypeError, KeyError):
                data[k] = v

        if tid is not None:
            SQL = render_template(
                "/".join([self.table_template_path, 'properties.sql']),
                did=did, scid=scid, tid=tid,
                datlastsysoid=self.datlastsysoid
            )
            status, res = self.conn.execute_dict(SQL)
            if not status:
                return internal_server_error(errormsg=res)

        SQL, name = self.get_sql(did, scid, tid, data, res)
        SQL = re.sub('\n{2,}', '\n\n', SQL)
        SQL = SQL.strip('\n')
        if SQL == '':
            SQL = "--modified SQL"
        return make_json_response(
            data=SQL,
            status=200
        )

    @BaseTableView.check_precondition
    def dependents(self, gid, sid, did, scid, tid):
        """
        This function get the dependents and return ajax response
        for the table node.

        Args:
            gid: Server Group ID
            sid: Server ID
            did: Database ID
            scid: Schema ID
            tid: Table ID
        """
        return BaseTableView.get_table_dependents(self, tid)

    @BaseTableView.check_precondition
    def dependencies(self, gid, sid, did, scid, tid):
        """
        This function get the dependencies and return ajax response
        for the table node.

        Args:
            gid: Server Group ID
            sid: Server ID
            did: Database ID
            scid: Schema ID
            tid: Table ID
        """
        return BaseTableView.get_table_dependencies(self, tid)

    @BaseTableView.check_precondition
    def sql(self, gid, sid, did, scid, tid):
        """
        This function will creates reverse engineered sql for
        the table object

         Args:
           gid: Server Group ID
           sid: Server ID
           did: Database ID
           scid: Schema ID
           tid: Table ID
        """
        main_sql = []

        SQL = render_template(
            "/".join([self.table_template_path, 'properties.sql']),
            did=did, scid=scid, tid=tid,
            datlastsysoid=self.datlastsysoid
        )
        status, res = self.conn.execute_dict(SQL)
        if not status:
            return internal_server_error(errormsg=res)

        if len(res['rows']) == 0:
            return gone(gettext("The specified table could not be found."))

        data = res['rows'][0]

        return BaseTableView.get_reverse_engineered_sql(
            self, did, scid, tid, main_sql, data)

    @BaseTableView.check_precondition
    def select_sql(self, gid, sid, did, scid, tid):
        """
        SELECT script sql for the object

        Args:
            gid: Server Group Id
            sid: Server Id
            did: Database Id
            scid: Schema Id
            tid: Table Id

        Returns:
            SELECT Script sql for the object
        """
        SQL = render_template(
            "/".join([self.table_template_path, 'properties.sql']),
            did=did, scid=scid, tid=tid,
            datlastsysoid=self.datlastsysoid
        )
        status, res = self.conn.execute_dict(SQL)
        if not status:
            return internal_server_error(errormsg=res)

        data = res['rows'][0]
        data = self._formatter(did, scid, tid, data)

        columns = []

        # Now we have all list of columns which we need
        if 'columns' in data:
            for c in data['columns']:
                columns.append(self.qtIdent(self.conn, c['attname']))

        if len(columns) > 0:
            columns = ", ".join(columns)
        else:
            columns = '*'

        sql = u"SELECT {0}\n\tFROM {1};".format(
            columns,
            self.qtIdent(self.conn, data['schema'], data['name'])
        )
        return ajax_response(response=sql)

    @BaseTableView.check_precondition
    def insert_sql(self, gid, sid, did, scid, tid):
        """
        INSERT script sql for the object

        Args:
            gid: Server Group Id
            sid: Server Id
            did: Database Id
            scid: Schema Id
            tid: Table Id

        Returns:
            INSERT Script sql for the object
        """
        SQL = render_template(
            "/".join([self.table_template_path, 'properties.sql']),
            did=did, scid=scid, tid=tid,
            datlastsysoid=self.datlastsysoid
        )
        status, res = self.conn.execute_dict(SQL)
        if not status:
            return internal_server_error(errormsg=res)

        data = res['rows'][0]
        data = self._formatter(did, scid, tid, data)

        columns = []
        values = []

        # Now we have all list of columns which we need
        if 'columns' in data:
            for c in data['columns']:
                columns.append(self.qtIdent(self.conn, c['attname']))
                values.append('?')

        if len(columns) > 0:
            columns = ", ".join(columns)
            values = ", ".join(values)
            sql = u"INSERT INTO {0}(\n\t{1})\n\tVALUES ({2});".format(
                self.qtIdent(self.conn, data['schema'], data['name']),
                columns, values
            )
        else:
            sql = gettext('-- Please create column(s) first...')

        return ajax_response(response=sql)

    @BaseTableView.check_precondition
    def update_sql(self, gid, sid, did, scid, tid):
        """
        UPDATE script sql for the object

        Args:
            gid: Server Group Id
            sid: Server Id
            did: Database Id
            scid: Schema Id
            tid: Table Id

        Returns:
            UPDATE Script sql for the object
        """
        SQL = render_template(
            "/".join([self.table_template_path, 'properties.sql']),
            did=did, scid=scid, tid=tid,
            datlastsysoid=self.datlastsysoid
        )
        status, res = self.conn.execute_dict(SQL)
        if not status:
            return internal_server_error(errormsg=res)

        data = res['rows'][0]
        data = self._formatter(did, scid, tid, data)

        columns = []

        # Now we have all list of columns which we need
        if 'columns' in data:
            for c in data['columns']:
                columns.append(self.qtIdent(self.conn, c['attname']))

        if len(columns) > 0:
            if len(columns) == 1:
                columns = columns[0]
            else:
                columns = "=?, ".join(columns)
            columns += "=?"

            sql = u"UPDATE {0}\n\tSET {1}\n\tWHERE <condition>;".format(
                self.qtIdent(self.conn, data['schema'], data['name']),
                columns
            )
        else:
            sql = gettext('-- Please create column(s) first...')

        return ajax_response(response=sql)

    @BaseTableView.check_precondition
    def delete_sql(self, gid, sid, did, scid, tid):
        """
        DELETE script sql for the object

        Args:
            gid: Server Group Id
            sid: Server Id
            did: Database Id
            scid: Schema Id
            tid: Table Id

        Returns:
            DELETE Script sql for the object
        """
        SQL = render_template(
            "/".join([self.table_template_path, 'properties.sql']),
            did=did, scid=scid, tid=tid,
            datlastsysoid=self.datlastsysoid
        )
        status, res = self.conn.execute_dict(SQL)
        if not status:
            return internal_server_error(errormsg=res)

        data = res['rows'][0]

        sql = u"DELETE FROM {0}\n\tWHERE <condition>;".format(
            self.qtIdent(self.conn, data['schema'], data['name'])
        )

        return ajax_response(response=sql)

    @BaseTableView.check_precondition
    def statistics(self, gid, sid, did, scid, tid=None):
        """
        Statistics

        Args:
            gid: Server Group Id
            sid: Server Id
            did: Database Id
            scid: Schema Id
            tid: Table Id

        Returns the statistics for a particular table if tid is specified,
        otherwise it will return statistics for all the tables in that
        schema.
        """
        return BaseTableView.get_table_statistics(self, scid, tid)

    @BaseTableView.check_precondition
    def count_rows(self, gid, sid, did, scid, tid):
        """
        Count the rows of a table.
        Args:
            gid: Server Group Id
            sid: Server Id
            did: Database Id
            scid: Schema Id
            tid: Table Id

        Returns the total rows of a table.
        """
        data = {}
        data['schema'], data['name'] = \
            super(TableView, self).get_schema_and_table_name(tid)

        SQL = render_template(
            "/".join(
                [self.table_template_path, 'get_table_row_count.sql']
            ), data=data
        )

        status, count = self.conn.execute_scalar(SQL)

        if not status:
            return internal_server_error(errormsg=count)

        return make_json_response(
            status=200,
            info=gettext("Table rows counted: %s" % count),
            data={'total_rows': count}
        )


TableView.register_node_view(blueprint)
