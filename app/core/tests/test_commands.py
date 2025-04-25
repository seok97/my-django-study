"""
Test custom Django management commands.
"""

from unittest.mock import patch

from psycopg2 import OperationalError as Psycopg2Error01

from django.core.management import call_command
from django.db.utils import OperationalError
from django.test import SimpleTestCase

@patch('core.management.commands.wait_for_db.Command.check')
class CommandTests(SimpleTestCase):
    """Test commands."""

    def test_wait_for_db_ready(self, patched_check):
        """Test waiting for db when db is available."""
        # patched_check.return_value 설정:
        # 실제 check() 호출 시 True 반환 -> 연결 성공으로 간주
        patched_check.return_value = True

        # call_command으로 명령 실행
        call_command('wait_for_db')

        # 호출 횟수 및 인자 검증
        patched_check.assert_called_once_with(databases=['default'])

    @patch('time.sleep')
    def test_wait_for_db_deley(self, patched_sleep, patched_check):
        """Test waiting for db when getting OperationalError."""
        # patched_check.side_effect 설정:
        # 1~2번째 호출: psycopg2 단계 오류
        # 3~5번째 호출: Django 단계 오류
        # 6번째 호출: True 반환 (성공)
        patched_check.side_effect = [Psycopg2Error01] * 2 + [OperationalError] * 3 + [True]

        call_command('wait_for_db')

        # 총 호출 횟수가 6번인지 검증
        self.assertEqual(patched_check.call_count, 6)
        # 마지막 호출 시 인자가 올바른지 검증
        patched_check.assert_called_with(databases=['default'])
        