#!/usr/bin/env bash


link(){
	# If the file is already a link, do nothing
	# If the file isn't a link, back it up and symlink it.
	
	printf "[link   ] $1: "

	if [[ -h ~/$1 ]] && [[ "$(readlink ~/$1)" == "$DIR/links/$1" ]]; then
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
		
		ln -s "$DIR/links/$1" "$HOME/$1"
		printf "done"
	fi

	printf "\n"
}
