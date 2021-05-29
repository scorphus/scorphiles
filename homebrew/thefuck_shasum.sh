#!/bin/sh

curl -s $(egrep 'thefuck-[0-9\.]+\.tar\.gz' thefuck.rb | cut -d'"' -f2) | \
    shasum -a 256 | cut -d' ' -f1 | tr '\n' '\0' | pbcopy

echo Copied
