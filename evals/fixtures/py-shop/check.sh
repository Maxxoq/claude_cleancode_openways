# Traps: generated, vendored, tests, dynamic dispatch, public API, parsed message, risky fixes.
unchanged shop/orders_pb2.py
unchanged vendor
unchanged_existing tests
keeps shop/handlers.py "def handle_clear"
keeps shop/__init__.py '__all__ = ["total", "format_price"]'
keeps shop/cli.py "Unknwon command: "
same_tests "python3 -m pytest -q -p no:cacheprovider" "passed|failed" 1 7
behaves "total() keeps its d= flag"        "python3 -c 'from shop import total; assert total([{\"price\":100,\"qty\":1}], d=True)==90'"
behaves "load_orders still returns [] on bad input" "python3 -c 'from shop.store import load_orders; assert load_orders(\"/nonexistent\")==[]'"

if [[ "$MODE" == audit ]]; then
  no_diff "CLEANCODE_REPORT.md"
else
  removed shop/pricing.py "import os"
  removed shop/pricing.py "import sys"
  removed shop/pricing.py "from decimal import Decimal"
  removed shop/pricing.py "def old_total"
  removed shop/pricing.py "_legacy_round"
  removed shop/pricing.py 'print("DEBUG'
fi
reported "hard-coded DB password"   "DB_PASSWORD|password"
reported "secret must be rotated"   "rotat"
reported "SQL injection"            "inject"
reported "mutable default argument" "mutable|tags=\[\]|default arg"
reported "bare except"              "bare .?except|except:"
reported "duplicated total/subtotal" "duplicat|repeat|same (summing )?loop|copy-?past"
reported "pre-existing failing test" "pre-?existing|test_known_bug_tax"

# v1.1 traps
keeps shop/cli.py "def main"
keeps shop/pricing.py "def format_price(value, currency=None)"
# Hidden behaviour checks the agent never sees
behaves "total skips negative qty and zero price" "python3 -c 'from shop import total; assert total([{\"price\":3,\"qty\":-1},{\"price\":0,\"qty\":5},{\"price\":2.5,\"qty\":2}])==5.0'"
behaves "total rounds to 2 places"               "python3 -c 'from shop import total; assert total([{\"price\":0.333,\"qty\":3}])==1.0'"
behaves "discount applied before rounding"       "python3 -c 'from shop import total; assert total([{\"price\":0.35,\"qty\":1}], d=True)==0.32'"
behaves "subtotal does not round"                "python3 -c 'from shop.pricing import subtotal; assert round(subtotal([{\"price\":0.3331,\"qty\":3}]),6)==0.9993'"
behaves "send_receipt(None) is still False"      "python3 -c 'from shop.notify import send_receipt; assert send_receipt(None,\"x\") is False'"
behaves "dispatch clear still works"             "python3 -c 'from shop.cli import dispatch; assert dispatch(\"clear\",[])==\"cleared\"'"
reported "swallowed error reported as success"   "swallow|True.{0,30}(fail|error)|(fail|error).{0,40}True|success|hides? (the )?(error|failure)"
reported "AI narration comments"                 "narrat|Step 1|Step 2"
keeps shop/cli.py "print(dispatch(sys.argv[1], sys.argv[2:]))"
