##########################################################################
#
# pgAdmin 4 - PostgreSQL Tools
#
# Copyright (C) 2013 - 2019, The pgAdmin Development Team
# This software is released under the PostgreSQL Licence
#
##########################################################################

from __future__ import print_function

import os
import sys
import traceback

from regression.python_test_utils.test_utils import get_db_connection

file_name = os.path.basename(__file__)


def create_fts_configuration(server, db_name, schema_name, fts_conf_name):
    """This function will add the fts_configuration under test schema using
    default parser. """

    try:
        connection = get_db_connection(db_name,
                                       server['username'],
                                       server['db_password'],
                                       server['host'],
                                       server['port'],
                                       server['sslmode'])
        sys_cursor = connection.cursor()

        query = "CREATE TEXT SEARCH CONFIGURATION " + schema_name + "." + \
                fts_conf_name + "(PARSER=default)"

        sys_cursor.execute(query)
        connection.commit()

        # Get 'oid' from newly created configuration
        sys_cursor.execute("select oid from sys_catalog.sys_ts_config where "
                          "cfgname = '%s' order by oid ASC limit 1"
                          % fts_conf_name)

        oid = sys_cursor.fetchone()
        fts_conf_id = ''
        if oid:
            fts_conf_id = oid[0]
        connection.close()
        return fts_conf_id
    except Exception:
        traceback.print_exc(file=sys.stderr)


def verify_fts_configuration(server, db_name, fts_conf_name):
    """
    This function will verify current FTS configuration.

    :param server: server details
    :type server: dict
    :param db_name: database name
    :type db_name: str
    :param fts_conf_name: FTS configuration name to be added
    :type fts_conf_name: str
    :return fts_conf: FTS configuration detail
    :rtype: tuple
    """
    try:
        connection = get_db_connection(db_name,
                                       server['username'],
                                       server['db_password'],
                                       server['host'],
                                       server['port'],
                                       server['sslmode'])
        sys_cursor = connection.cursor()

        sys_cursor.execute(
            "select oid from sys_catalog.sys_ts_config where "
            "cfgname = '%s' order by oid ASC limit 1"
            % fts_conf_name)
        fts_conf = sys_cursor.fetchone()
        connection.close()
        return fts_conf
    except Exception:
        traceback.print_exc(file=sys.stderr)


def delete_fts_configurations(server, db_name, schema_name, fts_conf_name):
    """
    This function delete FTS configuration.
    :param server: server details
    :type server: dict
    :param db_name: database name
    :type db_name: str
    :param fts_conf_name: FTS configuration name to be added
    :type fts_conf_name: str
    :param schema_name: schema name
    :type schema_name: str
    :return: None
    """
    connection = get_db_connection(db_name,
                                   server['username'],
                                   server['db_password'],
                                   server['host'],
                                   server['port'],
                                   server['sslmode'])
    sys_cursor = connection.cursor()
    sys_cursor.execute("DROP TEXT SEARCH CONFIGURATION %s.%s" % (schema_name,
                                                                fts_conf_name))
    connection.commit()
    connection.close()
