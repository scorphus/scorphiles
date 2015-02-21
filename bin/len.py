#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys
from json import load


def main(fp, keys):
    d = load(fp)
    for key in keys:
        k = key if not key.isdigit() else int(key)
        d = d[k]
    print len(d)

if __name__ == '__main__':
    try:
        keys = sys.argv[1:]
    except Exception:
        keys = []
    main(sys.stdin, keys)
