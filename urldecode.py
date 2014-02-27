#!/usr/bin/env python

import urllib
import sys


def main(url):
    print urllib.unquote(url).decode('utf8')

if __name__ == '__main__':
    try:
        url = sys.argv[1]
        main(url)
    except Exception:
        print 'Use %s <url>' % sys.argv[0]
        pass
