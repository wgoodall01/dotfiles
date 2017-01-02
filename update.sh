#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR

if [[ "$(git log --branches --not --remotes)" ]]; then
	printf "Error: There are unpushed commits in the dotfiles repo.\n"
	printf "Refusing to run init.\n"
	exit 1
fi

if [[ ! -e "$DIR/config.sh" ]]; then
	printf "Error: Set up your config file!\n"
	printf "Run 'cp config.sh.example config.sh' and edit it.\n"
	exit 1
fi

printf "\n\n -- Saving any uncomitted changes:\n"
git stash save # Save any uncomitted changes

printf "\n\n -- Pull changes from remote:\n"
git pull # Get changes from remote

printf "\n\n -- Run updater script:\n"
./init.sh # Run the updater script

printf "\n\n -- Reapply uncomitted changes:\n"
git stash pop # Reapply any changes
