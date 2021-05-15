#!/usr/bin/env bash

install_asdf(){
	printf "[asdf   ] install asdf... "
	if [[ ! -d ~/.asdf ]]; then
		git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.5.0 &>"$LOGS/asdf_dl"\
			&& printf "done.\n"\
			|| fatal "failed--check logs/asdf_dl for details"
	else
		printf "already installed.\n"
	fi

	source ~/.asdf/asdf.sh # add asdf to current namespace
}

install_asdf_plugin(){
	printf "[asdf   ] install plugin $1: "
	if ! asdf plugin-list | grep --silent "$1"; then
		asdf plugin-add "$1" "$2" &>"$LOGS/asdf_$1"\
			&& printf "done.\n"\
			|| fatal "failed--check logs/asdf_$1 for details"
	else
		printf "already installed.\n"
	fi
}

install_asdf_node_keys(){
	printf "[asdf   ] install keyring for nodejs..."\
	
	if [[ ! -e ~/.asdf/dotfiles-node-keyring-done ]]; then
		~/.asdf/plugins/nodejs/bin/import-release-team-keyring &> "$LOGS/asdf_node_keyring"\
			&& touch ~/.asdf/dotfiles-node-keyring-done\
			&& printf "done.\n"\
			|| fatal "couldn't install nodejs keyring for asdf--check logs/asdf_node_keyring for details."
	else
		printf "already installed.\n"
	fi
}

install_asdf_lang(){
	lang="$1"
	version="$2"
	printf "[asdf   ] install $lang $version..."
	installed="$(asdf current |& grep -v "Not installed" | awk -F' ' '{print $1 " @ " $2}')"
	logname="asdf_install_${lang}_${version}"
	if [[ ! "$installed" = *"$lang @ $version"* ]]; then
		asdf install "$lang" "$version" &>"$LOGS/$logname"\
			|| fatal "couldn't install $lang $version--check logs/$logname for details."
		asdf global "$lang" "$version" &>> "$LOGS/$logname"\
			|| fatal "couldn't set $lang $version as global--check logs/$logname"

		printf "done\n"
	else
		printf "already installed.\n"
	fi
}

install_npm(){
	printf "[npm    ] install $1: "
	if [[ ! -e "$HOME/.asdf/shims/$1" ]]; then
		npm install -g $1 &>"$LOGS/npm_install_$1"\
			&& printf "done.\n"\
			|| fatal "couldn't install--check logs/npm_install_$1 for details."
	else
		printf "already installed.\n"
	fi
}
