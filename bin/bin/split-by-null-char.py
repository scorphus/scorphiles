#!/usr/bin/env python

import sys


def split_by_null_char(text):
    return text.split("\x00")


def main():
    text = sys.stdin.read()
    for line in split_by_null_char(text):
        print(line)


if __name__ == "__main__":
    main()
