#/usr/bin/env bash

function install_n(){

	printf "[install] n: "
	if n --version &>/dev/null; then
		printf "already installed\n"
	else
		printf "installing... "
		curl -L https://git.io/n-install 2> /dev/null | bash -s -- -y &> $LOGS/nvm_install
		npm install -g yarn &> $LOGS/yarn_install
		if [ "$?" -eq "0" ]; then
			printf "done\n"
		else
			fatal "fail - check logs/nvm_install\n"
		fi
	fi

	#install n
}

function install_npm(){
	printf "[install] $1: "
	if [ -d ~/n/bin/node_modules/$1 ]; then
 		printf "already installed\n"
 	else
		if npm install -g $1 &>$LOGS/${1}_install; then
 			printf "done\n"
 		else
 			fatal "failed - check logs/${1}_install\n"
 		fi
 	fi
}



