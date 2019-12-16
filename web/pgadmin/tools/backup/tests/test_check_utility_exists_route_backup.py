##########################################################################
#
# pgAdmin 4 - PostgreSQL Tools
#
# Copyright (C) 2013 - 2019, The pgAdmin Development Team
# This software is released under the PostgreSQL Licence
#
##########################################################################

import sys
import json
from pgadmin.utils.route import BaseTestGenerator
from regression.python_test_utils.test_utils import\
    check_binary_path_or_skip_test

if sys.version_info < (3, 3):
    from mock import patch
else:
    from unittest.mock import patch


class TestUtilityCheckRouteCase(BaseTestGenerator):
    """Test to checks the utility route for Backup"""

    scenarios = [
        ('Check utility path route for backup utility', {
            'url': '/backup/utility_exists/{0}/objects',
            'expected_success_value': 1
        })
    ]

    def setUp(self):
        check_binary_path_or_skip_test(self, 'sys_dump')

    @patch('pgadmin.tools.backup.does_utility_exist')
    def runTest(self, does_utility_exist_mock):
        does_utility_exist_mock.return_value = False
        server_id = self.server_information['server_id']
        response = self.tester.get(self.url.format(server_id))
        self.assertEquals(response.status_code, 200)
        response = json.loads(response.data.decode('utf-8'))
        self.assertEquals(self.expected_success_value, response['success'])
