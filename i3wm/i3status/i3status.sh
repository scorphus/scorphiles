#!/bin/sh
# shell script to prepend i3status with more stuff

i3status | while :
do
    read line
    if [[ $line == '{"version"'*  || $line == '[' ]]; then
        echo "$line"
        continue
    fi
    if [[ $line == ',['* ]]; then
        line="${line:1:${#line}-1}"
    fi
    swap=$(swapon --show --noheadings | awk '{print $4}')
    line=$(echo "$line" | jq -c '.[6] |= {"name":"swap","markup":"none","full_text":"'$swap'"}') # || echo "$line,"
    echo "$line,"
done

