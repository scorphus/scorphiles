#!/usr/bin/env python3
# -*- coding:utf-8 -*-
#
# Onetab to Markdown converter
#
# Copyright 2015 Pablo S. Blum de Aguiar <scorphus@gmail.com>
# All rights reserved.
#
# Use of this source code is governed by Apache License, Version 2.0,
# that can be found on https://opensource.org/licenses/Apache-2.0
#
# See http://one-tab.com for more information about OneTab. This tool
# is not affiliated with them in any way.
#
# usage: onetab-to-markdown.py [-h] [-s] [-t title] [-i file] [-o file]
#
# Convert OneTab export to HTML bookmarks
#
# optional arguments:
#   -h, --help            show this help message and exit
#   -s, --self-render     create self-rendering Markdown + LaTeX document
#   -t, --title           show this help message and exit
#   -i, --input-file [INPUT_FILE]
#                         path to OneTab file (default: STDIN)
#   -o, --output-file [OUTPUT_FILE]
#                         path to markdown file (default: STDOUT)

import argparse
import sys


HEADER = """<!DOCTYPE html>
    <html>
    <head>
        <script>window.texme = {{ style: 'none' }}</script>
        <script src="https://cdn.jsdelivr.net/npm/texme@0.9.0"></script>
        <title>{title}</title>
        <meta charset="UTF-8" />
    </head>
    <body>
    <textarea>
    # {title}
"""
SEP = "\n---\n\n"
FOOTER = """</textarea></body></html><style>body {
        background: #141414;
        font-family: Arial;
        color: #aaa;
    }
h1 {
    margin: 0.75em;
}
a {
    color: #88aaff;
    font-size: 1.1em;
    font-weight: 800;
    line-height: 1.25em;
    text-decoration: none;
}
ul {
    padding-left: 1.25em;
}
li {
    margin: 1em 0;
}</style>\n"""


def main(args):
    if args.output_file:
        out = open(args.output_file, "w")
    else:
        out = sys.stdout
    if args.input_file:
        with open(args.input_file) as f:
            onetabs = f.readlines()
    else:
        onetabs = sys.stdin.readlines()
    out.write(HEADER.format(title=args.title))
    for onetab in onetabs:
        if not onetab.startswith("http"):
            out.write(SEP)
            continue
        site, *rem = onetab.strip().split(" | ", 1)
        name = rem[0] if rem else site
        out.write(f" - [{name}]({site})\n")
    out.write(FOOTER)
    if args.output_file:
        out.close()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description="Convert OneTab export to HTML bookmarks",
        epilog="(c) Brian Landers <brian@packetslave.com>",
    )
    parser.add_argument(
        "-s", "--self-render", action="store_true", help="Title of the page"
    )
    parser.add_argument(
        "-t", "--title", nargs="?", help="Title of the page", default="OneTab"
    )
    parser.add_argument(
        "-i", "--input-file", nargs="?", help="path to OneTab file (default: STDIN)"
    )
    parser.add_argument(
        "-o",
        "--output-file",
        nargs="?",
        help="path to bookmarks file (default: STDOUT)",
    )
    args = parser.parse_args()
    main(args)
