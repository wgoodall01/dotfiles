#!/usr/bin/env bash

dconf_load(){
	printf "[dconf  ] $1 << $2: "
	if dconf load "$1" <res/$2 &>$LOGS/dconf_$2; then
		printf "done\n"
	else
		printf "failed. check logs/dconf_$1\n"
	fi
}
