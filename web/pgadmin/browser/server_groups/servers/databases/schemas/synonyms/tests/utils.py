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


def create_synonym(server, db_name, schema_name, synonym_name, sequence_name):
    """
    This function create the synonym on given schema node.
    :param server: server details
    :type server: dict
    :param db_name: database name
    :type db_name: str
    :param schema_name: schema name
    :type schema_name: str
    :param synonym_name: synonym name
    :type synonym_name: str
    :param sequence_name: sequence name
    :type sequence_name: str
    """
    try:
        connection = utils.get_db_connection(db_name,
                                             server['username'],
                                             server['db_password'],
                                             server['host'],
                                             server['port'])
        sys_cursor = connection.cursor()
        query = "CREATE OR REPLACE SYNONYM %s.%s FOR %s.%s" % (
            schema_name, synonym_name, schema_name, sequence_name)
        sys_cursor.execute(query)
        connection.commit()
    except Exception:
        traceback.print_exc(file=sys.stderr)


def verify_synonym(server, db_name, synonym_name):
    """
    This function create the synonym on given schema node.
    :param server: server details
    :type server: dict
    :param db_name: database name
    :type db_name: str
    :param synonym_name: synonym name
    :type synonym_name: str
    :return synonym: synonym record from database
    :rtype: tuple
    """
    try:
        connection = utils.get_db_connection(db_name,
                                             server['username'],
                                             server['db_password'],
                                             server['host'],
                                             server['port'])
        sys_cursor = connection.cursor()
        sys_cursor.execute("SELECT * FROM sys_synonym WHERE synname='%s'" %
                          synonym_name)
        synonym = sys_cursor.fetchone()
        connection.close()
        return synonym
    except Exception:
        traceback.print_exc(file=sys.stderr)
