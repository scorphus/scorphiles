#!/usr/bin/env python
# -*- coding:utf-8 -*-

# Copyright 2015 Pablo Santiago Blum de Aguiar <scorphus@gmail.com>. All rights
# reserved. Use of this source code is governed by Apache License, Version 2.0,
# that can be found on https://opensource.org/licenses/Apache-2.0

import sys
import json


def usage(json_dict=None):
    print main.__doc__
    if json_dict:
        print 'Available keys:\n  {}'.format(
            '\n  '.join(sorted(json_dict.keys()))
        )


def main(argv):
    '''Usage: extract_json.py <json-file> <key>[.<key>...]'''

    iterate = '--iterate' in argv
    if iterate:
        del(argv[argv.index('--iterate')])

    if len(argv) < 1:
        usage()
        return 1

    if not sys.stdin.isatty():
        try:
            json_dict = json.load(sys.stdin)
        except Exception as e:
            print 'Could not read from STDIN: {}'.format(e)
            return 2
        keys = [x for x in argv[1].split('.')] if len(argv) > 1 else []
    else:
        with open(sys.argv[1]) as json_file:
            try:
                json_dict = json.load(json_file)
            except Exception as e:
                print 'Could not read {}: {}'.format(sys.argv[1], e)
                return 2
        keys = [x for x in argv[2].split('.')] if len(argv) > 2 else []

    if not keys:
        usage(json_dict)
        return 3

    status = 0
    for key in keys:
        try:
            idx = int(key)
            key = idx
        except:
            pass
        try:
            json_dict = json_dict[key]
        except:
            json_dict = ''
            status = 23
            break

    try:
        print(json_dict.encode('utf8') if json_dict else '')
    except:
        if iterate and type(json_dict) is list:
            for item in json_dict:
                try:
                    print(item.encode('utf8') if item else '')
                except:
                    print(json.dumps(item).encode('utf8') if item else '')
        elif iterate and type(json_dict) is dict:
            for key, item in json_dict.items():
                try:
                    print('{}:{}'.format(
                        key, item.encode('utf8') if item else '')
                    )
                except:
                    print('{}:{}'.format(
                        key, json.dumps(item).encode('utf8') if item else '')
                    )
        else:
            print(json.dumps(json_dict).encode('utf8') if json_dict else '')

    return status


if __name__ == '__main__':
    status = main(sys.argv)
    sys.exit(status)
