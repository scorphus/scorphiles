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


def get_focused_workspace(tree):
    nodes = tree.get('nodes')
    if nodes:
        for node in nodes:
            if node.get('focused'):
                return tree
            subtree = get_focused_workspace(node)
            if subtree:
                return subtree


def main():
    tree = i3.get_tree()
    focused_workspace = get_focused_workspace(tree)
    if focused_workspace:
        jump_to_window(focused_workspace, window_number)
    from ipdb import set_trace; set_trace()  # BREAKPOINT
    pass


if __name__ == '__main__':
    main()
