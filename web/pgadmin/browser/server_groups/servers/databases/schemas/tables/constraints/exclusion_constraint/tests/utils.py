##########################################################################
#
# pgAdmin 4 - PostgreSQL Tools
#
# Copyright (C) 2013 - 2019, The pgAdmin Development Team
# This software is released under the PostgreSQL Licence
#
##########################################################################

from __future__ import print_function

import sys
import traceback

from regression.python_test_utils import test_utils as utils


def create_exclusion_constraint(server, db_name, schema_name, table_name,
                                key_name):
    """
    This function creates a exclusion constraint under provided table.
    :param server: server details
    :type server: dict
    :param db_name: database name
    :type db_name: str
    :param schema_name: schema name
    :type schema_name: str
    :param table_name: table name
    :type table_name: str
    :param key_name: test name for key
    :type key_name: str
    :return oid: key constraint id
    :rtype: int
    """
    try:
        connection = utils.get_db_connection(db_name,
                                             server['username'],
                                             server['db_password'],
                                             server['host'],
                                             server['port'],
                                             server['sslmode'])
        old_isolation_level = connection.isolation_level
        connection.set_isolation_level(0)
        sys_cursor = connection.cursor()
        query = "ALTER TABLE %s.%s ADD CONSTRAINT %s EXCLUDE USING btree(" \
                "id ASC NULLS FIRST WITH =)" % \
                (schema_name, table_name, key_name)
        sys_cursor.execute(query)
        connection.set_isolation_level(old_isolation_level)
        connection.commit()
        # Get oid of newly added index constraint
        sys_cursor.execute(
            "SELECT conindid FROM sys_constraint where conname='%s'" % key_name)
        index_constraint = sys_cursor.fetchone()
        connection.close()
        oid = index_constraint[0]
        return oid
    except Exception:
        traceback.print_exc(file=sys.stderr)


def verify_exclusion_constraint(server, db_name, index_name):
    """
    This function verifies index exist or not.
    :param server: server details
    :type server: dict
    :param db_name: database name
    :type db_name: str
    :param index_name: index name
    :type index_name: str
    :return table: table record from database
    :rtype: tuple
    """
    try:
        connection = utils.get_db_connection(db_name,
                                             server['username'],
                                             server['db_password'],
                                             server['host'],
                                             server['port'],
                                             server['sslmode'])
        sys_cursor = connection.cursor()
        sys_cursor.execute("select * from sys_class where relname='%s'" %
                          index_name)
        index_record = sys_cursor.fetchone()
        connection.close()
        return index_record
    except Exception:
        traceback.print_exc(file=sys.stderr)
        raise
