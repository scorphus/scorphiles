#!/usr/bin/env python
# -*- coding:utf-8 -*-

# Copyright 2015 Pablo Santiago Blum de Aguiar <scorphus@gmail.com>. All rights
# reserved. Use of this source code is governed by Apache License, Version 2.0,
# that can be found on https://opensource.org/licenses/Apache-2.0

import os
import sys
import yaml


def main(argv):
    '''Usage: extract_yaml.py <yam-file> <key>[.<key>...]'''

    def usage(yaml_dict=None):
        print main.__doc__
        if yaml_dict:
            print 'Available keys:\n  {}'.format(
                '\n  '.join(sorted(yaml_dict.keys()))
            )

    if len(argv) < 2 or not os.path.isfile(argv[1]):
        usage()
        return 1

    with open(sys.argv[1]) as yaml_file:
        try:
            yaml_dict = yaml.load(yaml_file)
        except Exception as e:
            print 'Could not read {}: {}'.format(sys.argv[1], e)
            return 2

        keys = [x for x in argv[2].split('.')] if len(argv) > 2 else []

        if not keys:
            usage(yaml_dict)
            return 3

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

        print yaml_dict


if __name__ == '__main__':
    status = main(sys.argv)
    sys.exit(status)
