#!/usr/bin/env fish

set days 10
set path ~/Volatile/

test -d $path; or exit 1

echo Removing old files:
find $path -type f -mtime +$days -print -delete

echo Removing empty directories:
find $path -type d -empty -print -delete
