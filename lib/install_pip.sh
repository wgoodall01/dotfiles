#!/usr/bin/env bash

install_pip(){
	printf "[pip3   ] $1: "
	if /usr/bin/env python3 "$DIR/lib/py_installed.py" "$1" &>/dev/null; then
		printf "already installed\n"
	else
		printf "installing... "
		if pip3 install --ignore-installed --user $1 &>$LOGS/pip3_$1_install; then
			printf "done\n"
		else
			fatal "failed - check logs/pip3_${1}_install\n"
		fi
	fi
}

install_pip2(){
	printf "[pip2   ] $1: "
	if /usr/bin/env python2 "$DIR/lib/py_installed.py" "$1" &>/dev/null; then
		printf "already installed\n"
	else
		printf "installing... "
		if pip install --ignore-installed --user $1 &>$LOGS/pip2_$1_install; then
			printf "done\n"
		else
			fatal "failed - check logs/pip2_${1}_install\n"
		fi
	fi
}

fix_local_perms(){
	printf "[perms  ] Fix .local perms: "
	if sudo chown -R ${USER}:${USER} ~/.local ~/.cache &> $LOGS/chown; then
		printf "done\n"
	else
		fatal "failed - check logs/chown for details\n"
	fi
}
