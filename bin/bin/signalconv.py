#!/usr/bin/env python
# -*- coding: utf-8 -*-

import signal
import sys


def signal_name(num):
    name = []
    for key in signal.__dict__.keys():
        if key.startswith('SIG') and getattr(signal, key) == num:
            name.append(key.replace('SIG', ''))
    if len(name) > 1:
        return ', '.join(name)
    elif len(name) == 1:
        return name[0]
    return '?'


def signal_num(name):
    num = {}
    for key in signal.__dict__.keys():
        if key.startswith('SIG') and name.lower() in key.lower():
            num[key.replace('SIG', '')] = str(getattr(signal, key))
    if len(num) > 1:
        return '\n'.join(['{} = {}'.format(*item) for item in num.items()])
    elif len(num) == 1:
        return '{} = {}'.format(*num.items()[0])
    return '?'


def main():
    if len(sys.argv) > 1:
        sig = sys.argv[1]
        if sig.isdigit():
            print(signal_name(int(sig)))
        else:
            print(signal_num(sig))


if __name__ == '__main__':
    main()
