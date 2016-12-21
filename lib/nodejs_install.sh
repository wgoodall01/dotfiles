#/usr/bin/env bash

install_nodejs(){

	printf "[install] nvm: "
	if [ -e ~/.nvm ]; then
		printf "already installed\n"
	else
		printf "installing... "
		curl https://raw.githubusercontent.com/creationix/nvm/v0.32.1/install.sh 2>/dev/null | bash &> $LOGS/nvm_install
		if [ "$?" -eq "0" ]; then
			printf "done\n"
			
			# Load nvm
			NVM_DIR=~/.nvm
			[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

			# Install nodejs stable
			printf "[install] nodejs stable: "
			if nvm install stable &>$LOGS/node_install; then
				printf "done\n"
			else
				printf "failed - check logs/node_install"
			fi

		else
			printf "fail - check logs/nvm_install\n"
		fi
	fi


}
