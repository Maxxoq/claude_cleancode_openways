import pytest


@pytest.fixture
def cart():
    return [{"price": 10, "qty": 2}, {"price": 5, "qty": 0}]
