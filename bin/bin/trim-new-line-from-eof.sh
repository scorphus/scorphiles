#!/bin/sh

tmp_file=$(mktemp)
perl -pe 'chomp if eof' $1 > $tmp_file
mv $tmp_file $1
