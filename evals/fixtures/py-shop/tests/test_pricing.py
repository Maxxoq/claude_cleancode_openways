from shop import total, format_price
from shop.pricing import subtotal


def test_total():
    assert total([{"price": 10, "qty": 2}]) == 20


def test_discount():
    assert total([{"price": 100, "qty": 1}], d=True) == 90


def test_subtotal_skips_zero_qty():
    assert subtotal([{"price": 5, "qty": 0}, {"price": 5, "qty": 3}]) == 15


def test_format_price():
    assert format_price(3) == "3.00 CZK"


def test_total_with_fixture(cart):
    assert total(cart) == 20
