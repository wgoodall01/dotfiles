#!/usr/bin/env bash

shopt -s nullglob

# Start file logging
exec &> >(tee -a "$LOGS/init")

# Prompt for sudo
sudo printf ""

comment(){
	printf "\n          $ANSI_RED$1$ANSI_RESET\n"
}

fatal(){
	printf "$ANSI_RED"
	printf "\n\n[  FATAL]: $1"
	printf "$ANSI_RESET"
	exit 1
}


run() {
	label="$1"; shift
	message="$1"; shift
	cmd="$@"

	log_name="run__${label}__${message}"
	log_name="${log_name// /_}" # strip spaces
	log_name="${log_name//\//_}" # strip slashes
	log_file="$LOGS/$log_name"

	printf '[%-7s] %s...' "$label" "$message"
	(${cmd[@]} 2>&1 >>$log_file && printf 'done.\n') \
		|| fatal "Failed."
}
