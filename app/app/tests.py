"""
Sample tests
"""

from django.test import SimpleTestCase
from app import calc

class CalcTests(SimpleTestCase):
    """Test the calc moudle."""

    def test_add_num(self):
        res = calc.add(5, 6)

        self.assertEqual(res, 11)