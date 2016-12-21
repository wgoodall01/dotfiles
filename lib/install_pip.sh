#!/usr/bin/env bash

install_pip(){
	printf "[install] $1: "
	if pip3 show $1 &>/dev/null; then
		printf "already installed\n"
	else
		printf "installing... "
		if sudo pip3 install --ignore-installed --user $1 &>$LOGS/$1_install; then
			printf "done\n"
		else
			printf "failed - check logs/${1}_install"
		fi
	fi
}

fix_local_perms(){
	printf "[perms  ] Fix .local perms: "
	if sudo chown -R ${USER}:${USER} ~/.local &> $LOGS/chown; then
		printf "done\n"
	else
		printf "failed - check logs/chown for details"
	fi
}
