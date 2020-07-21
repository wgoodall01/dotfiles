# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

enable_debug=false

# On osx, use gdate.
datecmd="date"
[[ -e "/usr/local/bin/gdate" ]] && datecmd="/usr/local/bin/gdate"

time_millis(){
	rawtime="$($datecmd "+%s%N")"
	echo "$((rawtime / 1000000))"
}
start_time="$(time_millis)"
last_time="$start_time"
line_length=0

print_line(){
	if shopt -q login_shell; then
		clear_line
		line_length=${#1}
		printf "$1"
	fi
}



hr() {
	local COLS;
	COLS="$(tput cols)";
	if (( COLS <= 0 )) ; then
		COLS="${COLUMNS:-80}"
	fi

    local WORD="─"
    if [[ -n "$WORD" ]] ; then
        local LINE=''
        while (( ${#LINE} < COLS ))
        do
            LINE="$LINE$WORD"
        done

        echo "${LINE:0:$COLS}"
    fi
}

pbcopy() {
	xclip -selection clipboard
}

pbpaste() {
	xclip -selection clipboard -o
}

clear_line(){
	printf "\r"
	printf '%0.s ' $(seq 1 $((line_length + 1)))
	printf "\r"
}

time_diff(){
	if $enable_debug; then
		current="$(time_millis)"
		startdiff="$((current - start_time))"
		lastdiff="$((current - last_time))"
		printf "[@%6d]  [+%6d]    $1\n" "$startdiff" "$lastdiff"
		last_time="$current"
	else
		print_line "[ $1 ]"
	fi;
}

time_end(){
	if ! $enable_debug; then
		clear_line
	else
		current="$(time_millis)"
		printf "\n Total time: $((current - start_time)) ms\n"
		hr
		printf "\n"
	fi;
}

# if ! $enable_debug; then
# 	printf "| "
# 	((line_length += 2))
# fi;

time_diff "start"


# Source global env
[ -e /etc/environment ] && source /etc/environment

# Set PATH with local bins
export PATH="$HOME/.local/bin:$PATH"

# Path for ubuntu snaps
export PATH="$PATH:/snap/bin"

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

time_diff "environment"

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
[[ $(uname) != "Darwin" ]] && shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Aliasses
alias ll='ls -alFh'
alias la='ls -A'
alias l='ls -CF'
alias g="git"
alias ".."="cd .."
alias "..."="cd ../.."
alias "...."="cd ../../.."
alias "tree"="tree -I node_modules"
alias "gcla"="gcloud alpha interactive"
alias "open"="xdg-open"
alias "yx"="yarn run --silent"
alias "fd"="fdfind"

# Keybinds
function __fzf_edit__ () {
	local file;
	file="$(__fzf_select__)"
	if [[ "$?" == "0"  && "${#file}" != "0" ]]; then
		# slice the string, __fzf_select__ adds a space at the end.
		$EDITOR "${file:0:-1}"
	fi
}
bind -m vi-insert -x '"\C-o": __fzf_edit__'

time_diff "aliasses"

# Utility commands
lsmake(){
	if [[ -e "./Makefile" ]]; then
		grep $'^[^\t].*:$' Makefile | cut -d ':' -f 1
	fi;

	if [[ -e "./package.json" ]]; then
		node <<-'EOF'
			const p = require("./package.json");
			const s = p.scripts;
			if(typeof s === "undefined"){
				console.log("No scripts in package.json")
			}else{
				Object.keys(s).forEach(k => console.log(`${k} : ${s[k]}`)) 
			}
		EOF
	fi;
}

time_diff "lsmake"

function _update_ps1() {
    PS1=$(powerline-shell $?)
}

if [[ $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi

time_diff "powerline-shell"

# Load ssh env
source ~/.ssh/environment

time_diff "ssh env"

time_diff "thefuck"

# Alias nvim to vim
alias vim=nvim

# Set $EDITOR, etc
export EDITOR=$(which nvim)
export MANPAGER="nvim -c 'set ft=man' -"

# Set $CLICOLOR
export CLICOLOR=1

time_diff "clicolor, editor"

# Add hub wrapper for git
eval "$(hub alias -s)"

time_diff "hub"

# Set Go env vars
export GOPATH="$HOME/Dev/go"
export GO111MODULE="on"
export PATH="$PATH:$GOPATH/bin"

time_diff "go"

source ~/.asdf/asdf.sh
source ~/.asdf/completions/asdf.bash

if command -v sccache >/dev/null; then
	# use local sccache
	export RUSTC_WRAPPER="sccache"
fi

time_diff "asdf"

# Path for global yarn modules
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# Projdir

if [[ ! -e ~/.projdir ]]; then echo ~ > ~/.projdir; fi

pjd(){
	case "$1" in 
		"set") 
			pwd > ~/.projdir;;
		"pwd") 
			if [[ -e ~/.projdir ]]; then 
				cat ~/.projdir
			else 
				printf "Projdir does not exist yet.\n"
			fi;;
		"")    
			if [[ -e ~/.projdir ]]; then 
				cd $(cat ~/.projdir)
			else 
				printf "Projdir does not exist yet.\n"
			fi;;
		"to") 
			dir="$HOME/Dev/$2"
			if [[ -d "$dir" ]]; then
				cd "$dir"
				pjd set "$dir"
			else
				printf "~/Dev/$2 is not a directory.\n"
			fi;;
		*)	
			cat <<-EOF
			usage: pjd [<command>] [<dir>]

			pjd without any command CDs to the directory in ~/.projdir.

			Commands:
			  set       Set the ~/.projdir to the current directory.
			  pwd       Prints the contents of ~/.projdir.
			  to <dir>  Creates ~/Dev/<dir>, sets ~/.projdir, and cds to it.

			EOF
			;;
	esac
}

#Automatically cd to projdir
pjd

time_diff "cd projdir"

# cd relative to ~/Dev
dcd(){
	cd ~/Dev/$*
}

# cd relative to Projdir
pcd(){
	cd $(pjd pwd)/$*
}

# Shortcut to update/install dotfiles
update-dotfiles(){
	~/Dev/dotfiles/update.sh
}

install-dotfiles(){
	~/Dev/dotfiles/init.sh
}

# Shortcut to mount vmware shared folders
mount-shared-folders(){
	sudo mount -t fuse.vmhgfs-fuse .host:/ /mnt/hgfs -o allow_other
}

# I always wind up looking up the boilerplate for this, so have this on hand in the shell
touch-shell(){
	file="$1"

	# Check if the file already exists. If so, actually touch it.
	if [[ -f "$file" ]]; then
		touch "$file"
	else
		# Create the file if it doesn't already exist.
		cat >$file <<-"EOF"
			#!/usr/bin/env bash
			set -euo pipefail  
			DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
		EOF
	fi

	# Set as executable
	chmod +x "$file"
}

# Run a command for any change to non-gitignored files in the working directory
onchange(){
	ag -l | entr -s "echo $(hr) && ($*)"
}

# Shortcut to run a Docker container like a command
docli(){
	# Run a container, and:
	#	- delete it when it finishes
	#	- forward process signals to it
	#	- run interactively, and allocate it a TTY
	docker run\
		--rm\
		--sig-proxy=true\
		-it\
		"$@"
}

# Install FZF bash keybinds and config
export FZF_DEFAULT_COMMAND='ag --hidden --ignore .git -g ""'
export FZF_DEFAULT_OPTS='--inline-info'
export FZF_CTRL_T_OPTS="--preview '[[ \$(file --mime {}) =~ binary ]] && echo {} is a binary file || (highlight -O ansi -l {} || cat {}) 2> /dev/null | head -500'"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash ] && source "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash

time_diff "path, travis"

# The next line updates PATH, enables shell completion for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.bash.inc" ]; then source "$HOME/google-cloud-sdk/path.bash.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.bash.inc" ]; then source "$HOME/google-cloud-sdk/completion.bash.inc"; fi

# Enable conda
if [ -f "/opt/conda/etc/profile.d/conda.sh" ]; then source "/opt/conda/etc/profile.d/conda.sh"; fi

time_diff "gcloud setup"

time_end

(	
	flock -x 42
	if ! ssh-add -l &>/dev/null; then
		# Prompt for SSH key, if askpass is installed.
		askpass="$(which ssh-askpass)"
		if [[ "$askpass" != "" ]]; then
			# use askpass
			SSH_ASKPASS="$askpass" ssh-add &>/dev/null </dev/null
		else
			# prompt to do it manually.
			printf "No SSH keys in ssh-agent - run 'ssh-add'\n"
			NAGGED=true
		fi
	fi
) 42>"$HOME/.w_ssh_ask_pass.lock"

if [ "$NAGGED" = true ]; then
	hr
fi


