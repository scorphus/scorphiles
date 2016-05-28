#!/usr/bin/env python
# -*- coding:utf-8 -*-

# Copyright 2015 Pablo Santiago Blum de Aguiar <scorphus@gmail.com>. All rights
# reserved. Use of this source code is governed by Apache License, Version 2.0,
# that can be found on https://opensource.org/licenses/Apache-2.0

import sys
import yaml


def usage(yaml_dict=None):
    print main.__doc__
    if yaml_dict:
        print 'Available keys:\n  {}'.format(
            '\n  '.join(sorted(yaml_dict.keys()))
        )


def main(argv):
    '''Usage: extract_yaml.py <yam-file> <key>[.<key>...]'''

    if len(argv) < 1:
        usage()
        return 1

    if not sys.stdin.isatty():
        try:
            yaml_dict = yaml.safe_load(sys.stdin)
        except Exception as e:
            print 'Could not read from STDIN: {}'.format(e)
            return 2
        keys = [x for x in argv[1].split('.')] if len(argv) > 1 else []
    else:
        with open(sys.argv[1]) as yaml_file:
            try:
                yaml_dict = yaml.safe_load(yaml_file)
            except Exception as e:
                print 'Could not read {}: {}'.format(sys.argv[1], e)
                return 2
        keys = [x for x in argv[2].split('.')] if len(argv) > 2 else []

    if not keys:
        usage(yaml_dict)
        return 3

    status = 0
    for key in keys:
        try:
            idx = int(key)
            key = idx
        except:
            pass
        try:
            yaml_dict = yaml_dict[key]
        except:
            yaml_dict = ''
            status = 23
            break

    try:
        print(yaml_dict.encode('utf8') if yaml_dict else '')
    except:
        print(yaml.dump(yaml_dict).encode('utf8') if yaml_dict else '')

    return status


if __name__ == '__main__':
    status = main(sys.argv)
    sys.exit(status)
