#!/usr/bin/env python
# -*- coding: utf-8 -*-

# This file is part of imatch

# Licensed under the BSD-3-Clause license:
# https://opensource.org/licenses/BSD-3-Clause
# Copyright (c) 2018, Pablo S. Blum de Aguiar <scorphus@gmail.com>

import sys

try:
    import i3
except ImportError:
    sys.stderr.write('Please install i3-py (a.k.a. pip install i3-py)')
    sys.exit(1)


def get_focused_node(tree):
    '''Dive into the tree until the focused node is found and returned'''
    nodes = tree.get('nodes')
    if not nodes:
        return None
    for node in nodes:
        if node.get('focused'):
            return tree
        subtree = get_focused_node(node)
        if subtree:
            return subtree


def jump2window(focused_node, n):
    '''Given a focused node, try and focus the nth window'''
    nodes = focused_node.get('nodes', [])
    if not nodes:
        return None
    try:
        window = nodes[n]['window']
    except (KeyError, IndexError):
        return None
    if not window:
        return None
    return i3.focus(id=window)


def main():
    '''Read window number from arg, get focused node and jump to such window'''
    try:
        window_num = int(sys.argv[1])
    except (IndexError, ValueError):
        sys.stderr.write('Usage: jump2window.py <number>')
        sys.exit(1)
    tree = i3.get_tree()
    focused_node = get_focused_node(tree)
    if focused_node:
        jump2window(focused_node, window_num)
    else:
        print('too bad')


if __name__ == '__main__':
    main()
