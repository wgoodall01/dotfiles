#/usr/bin/env bash

function install_n(){
	printf "[install] n: "
	if n --version &>/dev/null; then
		printf "already installed\n"
	else
		printf "installing... "

		export PATH="$PATH:$HOME/n/bin"

		rm -rf ~/n\
			&& curl -L https://git.io/n-install 2>$LOGS/n_install >/tmp/n-install.sh\
			&& chmod 700 /tmp/n-install.sh\
			&& /tmp/n-install.sh -yn latest &> $LOGS/n_install

		if [ "$?" -eq "0" ]; then
			printf "done\n"
		else
			fatal "fail - check logs/n_install\n"
		fi
	fi
}

function install_npm(){
	printf "[install] $1: "
	if [ -d ~/n/lib/node_modules/$1 ]; then
 		printf "already installed\n"
 	else
		if npm install -g $1 &>$LOGS/${1}_install; then
 			printf "done\n"
 		else
 			fatal "failed - check logs/${1}_install\n"
 		fi
 	fi
}



