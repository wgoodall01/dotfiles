#!/usr/bin/env bash

dconf_load(){
	printf "[dconf  ] $1 << $2: "
	eval $(dbus-launch --auto-syntax) #for when outside of X
	if dconf load "$1" <res/$2 &>$LOGS/dconf_$2; then
		printf "done\n"
	else
		fatal "failed. check logs/dconf_$1\n"
	fi
}
