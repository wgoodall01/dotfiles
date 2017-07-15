#!/usr/bin/env bash

install_pip(){
	printf "[install] $1: "
	if $DIR/lib/py_installed.py $1 &>/dev/null; then
		printf "already installed\n"
	else
		printf "installing... "
		if pip3 install --ignore-installed --user $1 &>$LOGS/$1_install; then
			printf "done\n"
		else
			fatal "failed - check logs/${1}_install\n"
		fi
	fi
}

fix_local_perms(){
	printf "[perms  ] Fix .local perms: "
	if sudo chown -R ${USER}:${USER} ~/.local ~/.cache &> $LOGS/chown; then
		printf "done\n"
	else
		fatal "failed - check logs/chown for details\n"
	fi
}
