#!/usr/bin/env bash


install_apt(){
	# Install a package and log the installation
	printf "[install] $1: "
	if dpkg -s $1 &>/dev/null; then
		printf "already installed\n"
	else
		printf "installing... "
		if sudo apt-get install -y $1 &>$LOGS/$1_install; then
			printf "done\n"
		else
			printf "failed - check logs/${1}_install"
		fi
	fi
}

