#!/usr/bin/env bash


# ANSI term colors
if [ -t 1 ]; then
	ANSI_RED="\e[91m"
	ANSI_RESET="\e[39m"
else
	ANSI_RED=""
	ANSI_RESET=""
fi


TIMESTAMP=$(date -d "today" +"%Y-%m-%d_%H-%M-%S")

# Dir of backups
BACKUPS=$DIR/backups/$TIMESTAMP
mkdir -p $BACKUPS
rm -f "$DIR/backups/latest"
ln -s "$BACKUPS" "$DIR/backups/latest"

# Dir of logs
LOGS=$DIR/logs/$TIMESTAMP
mkdir -p $LOGS
rm -f "$DIR/logs/latest"
ln -s "$LOGS" "$DIR/logs/latest"

# Load decryption password
if [ -f $DIR/password ]; then
	PASSWORD=$(<$DIR/password)
fi

