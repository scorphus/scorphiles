#!/bin/sh

current_workspace=$(i3-msg -t get_workspaces | jq -c '.[] | select(.focused) | .num')
max_workspace=$(i3-msg -t get_workspaces | jq -c '.[-1].num')
next_workspace=$(( ($max_workspace + $current_workspace - 1 + $1) % ($max_workspace) + 1 ))
i3-msg workspace "${next_workspace}"

