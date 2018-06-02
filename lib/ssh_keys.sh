#!/usr/bin/env bash

install_ssh_keys(){
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
			fatal "There was a decryption error - check logs/${f}_decrypt. Missing pw file?"
		fi

		printf "\n"
	done

	rm -rf $tmp
}
