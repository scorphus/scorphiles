#!/bin/bash
# This hook is run after this virtualenv is activated.
TITLE=$1
echo -ne "\033]0;$TITLE\007"
