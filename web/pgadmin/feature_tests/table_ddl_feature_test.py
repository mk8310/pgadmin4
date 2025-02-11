##########################################################################
#
# pgAdmin 4 - PostgreSQL Tools
#
# Copyright (C) 2013 - 2019, The pgAdmin Development Team
# This software is released under the PostgreSQL Licence
#
##########################################################################

from __future__ import print_function
import random

from regression.feature_utils.base_feature_test import BaseFeatureTest
from regression.python_test_utils import test_utils
from regression.feature_utils.tree_area_locators import TreeAreaLocators


class TableDdlFeatureTest(BaseFeatureTest):
    """ This class test acceptance test scenarios """

    scenarios = [
        ("Test table DDL generation", dict())
    ]

    test_table_name = ""

    def before(self):

        self.page.add_server(self.server)

    def runTest(self):
        self.test_table_name = "test_table" + str(random.randint(1000, 3000))
        test_utils.create_table(self.server, self.test_db,
                                self.test_table_name)

        self.page.expand_database_node(
            self.server['name'],
            self.server['db_password'], self.test_db)
        self.page.toggle_open_tables_node(
            self.server['name'], self.server['db_password'],
            self.test_db, 'public')
        self.page.click_a_tree_node(
            self.test_table_name,
            TreeAreaLocators.sub_nodes_of_tables_node)
        self.page.click_tab("SQL")

        # Wait till data is displayed in SQL Tab
        self.assertTrue(self.page.check_if_element_exist_by_xpath(
            "//*[contains(@class,'CodeMirror-lines') and "
            "contains(.,'CREATE TABLE public.%s')]" % self.test_table_name,
            10), "No data displayed in SQL tab")

    def after(self):
        self.page.remove_server(self.server)
        test_utils.delete_table(
            self.server, self.test_db, self.test_table_name)
