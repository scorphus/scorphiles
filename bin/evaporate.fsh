#!/usr/bin/fish

set days 6
set path ~/gone_in_6_days/

test -d $path; or exit 1

echo Removing old files:
find $path -type f -mtime +$days -print -delete

echo Removing empty directories:
find $path -type d -empty -print -delete
