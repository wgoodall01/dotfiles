#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

cd $DIR
git stash save # Save any changes
git pull # Get changes from remote
./init.sh # Run the updater script
git stash pop # Reapply any changes
