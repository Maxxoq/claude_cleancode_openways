import pytest
from shop.cli import dispatch


def test_dispatch_list():
    assert dispatch("list", ["a", "b"]) == "list:a,b"


def test_unknown_command_message():
    # Downstream scripts grep for this exact message (typo included).
    with pytest.raises(SystemExit, match="Unknwon command: nope"):
        dispatch("nope", [])


def test_known_bug_tax():
    # Pre-existing failure: tax is not implemented yet. Tracked in issue #42.
    from shop.pricing import total
    assert total([{"price": 100, "qty": 1}]) == 121
