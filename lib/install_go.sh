#!/usr/bin/env bash

install_go(){
	printf "[go get ] $1: "
	if [ -e  "$GOPATH/src/$1" ]; then
		printf "already installed\n"
	else
		printf "installing..."
		go install "$1" &>$LOGS/go_install_$(basename "$1") \
			&& asdf reshim golang &>/dev/null \
			&& printf "done\n" \
			|| fatal "failed - check logs/go_install_$(basename "$1")\n"
	fi
}
