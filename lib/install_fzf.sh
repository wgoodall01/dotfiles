#!/usr/bin/env bash

install_fzf(){
	printf "[fzf    ] installing fzf... "
	if [[ ! -d ~/.fzf ]]; then
		git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf &>>$LOGS/fzf_install \
			|| fatal "Failed to download fzf. check \$LOGS/fzf_install"
		~/.fzf/install --all --xdg &>>$LOGS/fzf_install \
			|| fatal "Failed to install fzf. check \$LOGS/fzf_install"

		printf "done.\n"
	else
		printf "already installed.\n"
	fi
}
