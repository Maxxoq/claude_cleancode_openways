import sys
from shop import handlers


def dispatch(command, args):
    fn = getattr(handlers, "handle_" + command, None)
    if fn == None:
        raise SystemExit("Unknwon command: " + command)
    return fn(args)


def add_tag(tag, tags=[]):
    tags.append(tag)
    return tags


if __name__ == "__main__":
    print(dispatch(sys.argv[1], sys.argv[2:]))


def main():
    print(dispatch(sys.argv[1], sys.argv[2:]))
