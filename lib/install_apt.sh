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
			fatal "failed - check logs/${1}_install\n"
		fi
	fi
}

add_apt(){

	if [[ "$2" == "ppa" ]]; then
		export name="ppa:$1"
		export search="$1"
	else
		export name="$1"
		export search="$1"
	fi
	

	printf "[apt    ] $1: "

	if grep -F "$search" /etc/apt/sources.list /etc/apt/sources.list.d/* &>/dev/null; then
		# PPA already added
		printf "already added.\n"
	else
		# Install PPA
		if sudo apt-add-repository "$name" -y &>> $LOGS/ppa && sudo apt update &>> $LOGS/ppa; then
			printf "done.\n"
		else
			fatal "failed - check logs/ppa\n"
		fi
	fi
}

add_ppa(){
	add_apt "$1" ppa
}

add_apt_key_url(){
	printf "[aptkey ] $1: "
	printf "\n\n\n>>>>> $1" >> $LOGS/apt_key_url
	curl -fsSL "$1" \
		| sudo apt-key add - &>$LOGS/apt_key_url \
		&& printf "done\n"\
		|| fatal "Error: apt_key_url: check \$LOGS/apt_key_url"
}
		
