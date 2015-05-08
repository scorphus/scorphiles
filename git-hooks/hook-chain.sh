#!/bin/bash
#
# based on a hook chain by orefalo, thanks!

hookname=`basename $0`

TEMP_FILE=`mktemp 2>/dev/null || mktemp -t 'hook-chain-yeah'`
trap 'rm -f $TEMP_FILE' EXIT
cat - > $TEMP_FILE

for hook in .git/hooks/$hookname-*
do
    if test -x "$hook"; then
        cat $TEMP_FILE | $hook "$@"
        status=$?
        if test $status -ne 0; then
            echo Hook $hook failed with error code $status
            exit $status
        fi
    fi
done
