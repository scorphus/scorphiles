#!/usr/bin/env python

from urllib.parse import quote
import sys


def main(url):
    print(quote(url, safe=""))


if __name__ == "__main__":
    try:
        url = sys.argv[1]
        main(url)
    except Exception:
        print("Use %s <url>" % sys.argv[0])
        pass
