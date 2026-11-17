#!/bin/sh
if [ "$1" = "true" ]
	then echo "Turninng ON menu_visible"
elif [ "$1" = "false" ]
	then echo "Turninng OFF menu_visible"
else
	echo "Nothing changed! Use true or false as argument!"
	exit 1
fi
sed -ri "s/\"menu_visible\": [^,]+,/\"menu_visible\": $1,/" ~/.config/sublime-text-3/Local/Session.sublime_session
