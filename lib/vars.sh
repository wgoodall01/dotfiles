#!/usr/bin/env bash


# ANSI term colors
ANSI_RED="\e[91m"
ANSI_RESET="\e[39m"


TIMESTAMP=$(date -d "today" +"%Y-%m-%d_%H-%M-%S")

# Dir of backups
BACKUPS=$DIR/backups/$TIMESTAMP
mkdir -p $BACKUPS

# Dir of logs
LOGS=$DIR/logs/$TIMESTAMP
mkdir -p $LOGS

# Load decryption password
if [ -f $DIR/password ]; then
	PASSWORD=$(<$DIR/password)
fi

