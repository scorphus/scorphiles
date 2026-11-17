#!/usr/bin/python
# -*- coding: utf-8 -*-

import json
import sys


def main(keys):
    with sys.stdin as json_string:
        json_dict = json.load(json_string)
    for key in keys:
        json_dict = json_dict[key]
    for key in json_dict:
        print key

if __name__ == '__main__':
    keys = sys.argv[1:]
    main(keys)
