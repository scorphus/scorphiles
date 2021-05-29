#!/usr/bin/python
# -*- coding: utf-8 -*-

import sys


def main(dim, prec):
    prec = r'{:%s}' % prec
    parts = dim.replace(' inches', '').split(' x ')
    dim = ' x '.join([prec.format(float(p) * 2.54) for p in parts])
    print(dim + ' cm')


if __name__ == '__main__':
    try:
        dim = sys.argv[1]
    except KeyError:
        print('bad options, ex: 8.5 x 8.3 x 6.6 inches')
        sys.exit(1)
    try:
        prec = sys.argv[2]
    except Exception:
        prec = '0.1f'
    main(dim, prec)
