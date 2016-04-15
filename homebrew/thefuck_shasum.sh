#!/bin/sh

curl -s $(grep packages/source/t/thefuck/thefuck thefuck.rb | cut -d'"' -f2) | \
    shasum -a 256 | cut -d' ' -f1 | tr '\n' '\0' | pbcopy

echo Copied
