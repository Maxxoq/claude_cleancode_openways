"""Command handlers. Looked up dynamically by name in shop/cli.py."""


def handle_list(args):
    return "list:" + ",".join(args)


def handle_clear(args):
    return "cleared"
