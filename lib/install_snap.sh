#!/usr/bin/env bash


install_snap(){
	# Install a package and log the installation
	printf "[snap   ] $1: "
	if __check_snap_installed "$1"; then
		printf "already installed\n"
	else
		printf "installing... "
		if (sudo snap install $2 "$1") &>"$LOGS/$1_snap_install"; then
			printf "done\n"
		else
			fatal "failed - check logs/${1}_install\n"
		fi
	fi
}

__check_snap_installed(){
	snap info "$1" | grep -e "^installed:" >/dev/null
}
