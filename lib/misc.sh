#!/usr/bin/env bash

shopt -s nullglob

# Start file logging
exec &> >(tee -a "$LOGS/init")

# Prompt for sudo
sudo printf ""

comment(){
	printf "\n          $ANSI_RED$1$ANSI_RESET\n"
}

fatal(){
	printf "$ANSI_RED"
	printf "\n\n[  FATAL]: $1"
	printf "$ANSI_RESET"
	exit 1
}

