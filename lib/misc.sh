#!/usr/bin/env bash

shopt -s nullglob

# Start file logging
exec &> >(tee -a "$LOGS/init")

# Prompt for sudo
sudo printf ""

comment(){
	printf "\n          $1\n"
}


feature(){
	printf "[feature] %-50s [y/n]:" "$2"
	read -n 1 -r
	printf "\n"
    [[ $REPLY =~ ^[Yy]$ ]] && RES=true || RES=false
	eval $1=$RES
}
