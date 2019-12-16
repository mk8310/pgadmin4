##########################################################################
#
# pgAdmin 4 - PostgreSQL Tools
#
# Copyright (C) 2013 - 2019, The pgAdmin Development Team
# This software is released under the PostgreSQL Licence
#
##########################################################################

import os

import jinja2
from regression.python_test_utils.sql_template_test_base import \
    SQLTemplateTestBase
from regression.python_test_utils.template_helper import file_as_template


class TestTriggerGetOidSql(SQLTemplateTestBase):
    scenarios = [
        ('Test Trigger to retrieve OID SQL file', dict())
    ]

    def __init__(self):
        super(TestTriggerGetOidSql, self).__init__()
        self.table_id = -1
        self.column_id = -1

    def test_setup(self, connection, cursor):
        cursor.execute("SELECT sys_class.oid AS table_id, "
                       "sys_attribute.attnum AS column_id "
                       "FROM sys_class JOIN sys_attribute ON "
                       "attrelid=sys_class.oid "
                       "WHERE sys_class.relname='test_table'"
                       " AND sys_attribute.attname = 'some_column'")
        self.table_id, self.column_id = cursor.fetchone()

    def generate_sql(self, version):
        file_path = os.path.join(os.path.dirname(__file__), "..", "templates",
                                 "triggers", "sql")
        if 'type' in self.server:
            file_path = os.path.join(os.path.dirname(__file__), "..",
                                     "templates",
                                     "triggers", "sql", self.server['type'])
        template_file = self.get_template_file(version, file_path,
                                               "get_oid.sql")
        jinja2.filters.FILTERS['qtLiteral'] = lambda value: "NULL"
        template = file_as_template(template_file)

        sql = template.render(data={'name': None},
                              tid=self.table_id
                              )

        return sql

    def assertions(self, fetch_result, descriptions):
        self.assertEqual(0, len(fetch_result))
