#!/usr/bin/env bash

set_go_env(){
	# Set Go env vars
	export GOPATH="$HOME/Dev/go"
	export PATH="$PATH:$GOPATH/bin"
	export GO111MODULE="on"
	mkdir -p "$GOPATH"
}

install_go(){
	printf "[go get ] $1: "
	if [ -e  "$GOPATH/src/$1" ]; then
		printf "already installed\n"
	else
		printf "installing..."
		if go get "$1" &>$LOGS/goget_$(basename "$1"); then
			printf "done\n"
		else
			fatal "failed - check logs/goget_$(basename "$1")\n"
		fi
	fi
}
