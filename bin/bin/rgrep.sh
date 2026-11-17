#!/bin/sh

first=$1
shift
grep --color -I -r "$first" * "$@"
