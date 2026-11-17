#!/usr/bin/env python

try:
    from urllib import unquote
except ImportError:
    from urllib.parse import unquote
import sys


def main(url):
    print(unquote(url))


if __name__ == "__main__":
    try:
        url = sys.argv[1]
        main(url)
    except Exception as err:
        print(u"Error: {}".format(err))
        print(u"Use {} <url>".format(sys.argv[0]))
