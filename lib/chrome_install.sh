#!/usr/bin/env bash

add_ppa_chrome(){
	printf "[ppa    ] chrome: "
	if [ ! -f /etc/apt/sources.list.d/google-chrome.list ]; then
		wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub \
			| sudo apt-key add - &>$LOGS/chrome_ppa &&\
		sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" \
			>> /etc/apt/sources.list.d/google-chrome.list' &>$LOGS/chrome_ppa &&\
		sudo apt-get update &>$LOGS/chrome_ppa
		if [ "$?" -eq "0" ]; then
			printf "done.\n"
		else
			printf "failed - check logs/chrome_ppa\n"
		fi
	else
		printf "already installed\n"
	fi
}
