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
			printf "failed - check logs/${1}_install\n"
		fi
	fi
}

add_ppa(){
	printf "[ppa    ] ppa:$1: "

		if grep $1 /etc/apt/sources.list /etc/apt/sources.list.d/* &>/dev/null; then
		# PPA already added
		printf "already added.\n"
	else
		# Install PPA
		if sudo apt-add-repository "ppa:$1" -y &>> $LOGS/ppa && sudo apt update &>> $LOGS/ppa; then
			printf "done.\n"
		else
			printf "failed - check logs/ppa\n"
		fi
	fi

}
		
