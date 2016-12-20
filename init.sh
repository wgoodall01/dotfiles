#!/usr/bin/env bash

# Dotfiles init script.
# This should be run every time to update dotfiles.
# It should not mess anything up if run multiple times.

shopt -s nullglob

cat <<_
  ____        _    __ _ _           _ 
 |  _ \  ___ | |_ / _(_) | ___  ___| |
 | | | |/ _ \| __| |_| | |/ _ \/ __| |
 | |_| | (_) | |_|  _| | |  __/\__ \_|
 |____/ \___/ \__|_| |_|_|\___||___(_)
 Logging to logs/init
_

# Prompt for sudo
sudo printf ""


TIMESTAMP=$(date -d "today" +"%Y-%m-%d_%H-%M-%S")

# Dir of script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Dir of backups
BACKUPS=$DIR/backups/$TIMESTAMP
mkdir -p $BACKUPS

# Dir of logs
LOGS=$DIR/logs/$TIMESTAMP
mkdir -p $LOGS

ln_replace(){
	# If the file is already a link, do nothing
	# If the file isn't a link, back it up and symlink it.
	
	printf "[link   ] $1: "

	if [ -h ~/$1 ]; then
		# File exists and is a symlink
		printf "already linked"
	else
		LOC=~/$1
		mkdir -p $(dirname $LOC)

		if [ -e $LOC ]; then
			mkdir -p $(dirname $BACKUPS/$1)
			mv $LOC $BACKUPS/$1
			printf "backed up and "
		fi
		
		ln -s $DIR/links/$1 ~/$1
		printf "linked from $DIR/links/$1 to $LOC"
	fi

	printf "\n"
}

install(){
	# Install a package and log the installation
	printf "[install] $1: "
	if dpkg -s $1 &>/dev/null; then
		printf "already installed\n"
	else
		printf "installing... "
		if $(sudo apt-get install -y $1) &>$LOGS/$1_install; then
			printf "done\n"
		else
			printf "failed - check logs/${1}_install"
		fi
	fi
}

comment(){
	printf "\n          $1\n"
}

# Load decryption password
if [ -f $DIR/password ]; then
	PASSWORD=$(<$DIR/password)
fi

# Prompt for optional stuff
comment "Options:"
read -p "[feature] Install SSH keys? [y/n]: " -n 1 -r
[[ $REPLY =~ ^[Yy]$ ]] && CFG_SSH=true || CFG_SSH=false
printf "\n"

# Start file logging
exec &> >(tee -a "$LOGS/init")

if [ "$CFG_SSH" = true ]; then
	comment "SSH keys:"
	mkdir -p ~/.ssh
	tmp=$DIR/sshkey_tmp
	mkdir -p $tmp

	for f in $DIR/enc/.ssh/*; do
		f=$(basename $f) # Only get the filename
		printf "[decrypt] .ssh/$f: "	
		# Decrypt the file to temp
		if $DIR/crypto.sh decrypt $DIR/enc/.ssh/$f $tmp/$f &>$LOGS/${f}_decrypt; then
			if [ -f ~/.ssh/$f ] && cmp --silent $tmp/$f ~/.ssh/$f; then
				# Files match
				printf "already exists in .ssh"
			else
				if [ -f ~/.ssh/$f ]; then
					# File exists
					mkdir -p $BACKUPS/.ssh
					mv ~/.ssh/$f $BACKUPS/.ssh/$f
				fi
				
				mv $tmp/$f ~/.ssh/$f
				printf "decrypted to ~/.ssh/$f"

				if [[ ! $f =~ ^.*.pub$ ]]; then
					chmod 400 ~/.ssh/$f
					printf " with 'chmod 400'"
				fi
			fi


		else
			printf "There was a decryption error - check logs/${f}_decrypt. Missing pw file?"
		fi
		printf "\n"
	done

	rm -rf $tmp
fi


comment "Shell configuration:"
ln_replace .bashrc
ln_replace .profile

comment "i3wm:"
install i3
ln_replace .config/i3

comment "neovim:"
install neovim
ln_replace .config/nvim

comment "nvm and nodejs:"
printf "[install] nvm: "
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

comment "Other stuff:"
install htop
install nload
install tree
install git
install golang
install python3
install python3-pip
install xclip
install default-jdk

