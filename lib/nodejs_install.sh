#/usr/bin/env bash

function install_nvm(){

	printf "[install] nvm: "
	if [ -e ~/.nvm ]; then
		printf "already installed\n"
	else
		printf "installing... "
		curl https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh 2>/dev/null | bash &> $LOGS/nvm_install
		if [ "$?" -eq "0" ]; then
			printf "done\n"
			
			# Load nvm
			NVM_DIR=~/.nvm
			[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
		else
			fatal "fail - check logs/nvm_install\n"
		fi
	fi
}

function install_nodejs(){
	printf "[install] nodejs: "
	
	# Load nvm
	NVM_DIR=~/.nvm
	source "$NVM_DIR/nvm.sh"
	
	if which node &>/dev/null && [[ "$(which node)" == *"$NVM_DIR"* ]]; then
		printf "already installed\n"
	else

		# Install nodejs stable
		printf "installing... "
		if nvm install stable &>$LOGS/node_install; then
			printf "done\n"
		else
			fatal "failed - check logs/node_install\n"
		fi
	fi

}

function nvm_init(){
	#Init nvm for some reason
	[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
	NVM_CURRENT=$NVM_DIR/versions/node/$(nvm current)
}

function install_npm(){
	printf "[install] $1: "
	if [ -d $NVM_CURRENT/lib/node_modules/$1 ]; then
		printf "already installed\n"
	else
		if $NVM_CURRENT/bin/npm install -g $1 &>$LOGS/${1}_install; then
			printf "done\n"
		else
			fatal "failed - check logs/${1}_install\n"
		fi
	fi
}



