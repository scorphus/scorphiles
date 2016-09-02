#!/bin/sh

days=10
path=$HOME/Volatile

test -d $path || exit 1

echo Removing old files:
find $path -type f -mtime +$days -print -delete

echo Removing empty directories:
find $path -type d -empty -print -delete
