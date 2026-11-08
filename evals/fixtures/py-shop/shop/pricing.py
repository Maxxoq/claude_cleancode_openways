import os
import sys
import math
from decimal import Decimal

TAX = 0.21


def total(items, d=False):
    t = 0
    for i in range(len(items)):
        if items[i]["qty"] > 0:
            if items[i]["price"] > 0:
                t = t + items[i]["price"] * items[i]["qty"]
    if d == True:
        t = t * 0.9
    print("DEBUG total=", t)
    return round(t, 2)


def subtotal(items):
    t = 0
    for i in range(len(items)):
        if items[i]["qty"] > 0:
            if items[i]["price"] > 0:
                t = t + items[i]["price"] * items[i]["qty"]
    return t


def format_price(value, currency=None):
    # used by external projects via `from shop import format_price`
    return f"{value:.2f} CZK"


def _legacy_round(x):
    return math.floor(x * 100) / 100


# def old_total(items):
#     s = 0
#     for it in items:
#         s += it["price"]
#     return s
