#!/usr/bin/env bash

shopt -s nullglob

# Start file logging
exec &> >(tee -a "$LOGS/init")

# Prompt for sudo
sudo printf ""

comment(){
	printf "\n          $1\n"
}

fatal(){
	printf "\n\n[  FATAL]: $1"
	exit 1
}

