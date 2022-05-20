# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

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

# Push a notification to Pushover with pushover-cli
# And push a system notification as well.
push() {
	pushover-cli push "$*" >/dev/null
	notify-send "CLI Push" "$*"
}


# Set PATH with local bins
export PATH="$HOME/.local/bin:$PATH"

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
alias "yx"="yarn run --silent"

if [[ "$(uname)" != "Darwin" ]]; then 
	alias shutdown="systemctl poweroff"
	alias "fd"="fdfind"
	alias "open"="xdg-open"
	alias "pbcopy"="xclip -selection clipboard"
	alias "pbpaste"="xclip -selection clipboard -o"
fi

if [[ "$(uname)" == "Darwin" ]]; then
	alias make=gmake
fi

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

todo() {
	if [[ -n "$1" ]]; then
		(cd "$1" && rg -i todo)
		return
	fi

	if dir="$(git rev-parse --show-toplevel)"; then
		(cd "$dir" && rg -i todo)
		return
	fi

	rg -i todo
}

function _update_ps1() {
    PS1=$(powerline-shell $?)
}

if [[ $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi

# Alias nvim to vim
alias vim=nvim

# Set $EDITOR, etc
export EDITOR=$(which nvim)
export MANPAGER="nvim +Man!"

# Set $CLICOLOR
export CLICOLOR=1

# Set Java env vars
export JAVA_HOME="/usr/lib/jvm/default-java"

# Install ASDF hook
if [[ "$(uname)" == "Darwin" ]]; then
	source "$(brew --prefix asdf)/asdf.sh"
else
	source ~/.asdf/asdf.sh
fi

if command -v sccache >/dev/null; then
	# use local sccache
	export RUSTC_WRAPPER="sccache"
fi

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

# Remove ANSI codes from text
uncolor() {
	sed 's/\x1b\[[0-9;]*m//g'
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
			shopt -s inherit_errexit
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
export FZF_DEFAULT_COMMAND='fd'
export FZF_DEFAULT_OPTS='--inline-info'
export FZF_CTRL_T_OPTS="--preview '[[ \$(file --mime {}) =~ binary ]] && echo {} is a binary file || (highlight -O ansi -l {} || cat {}) 2> /dev/null | head -500'"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash ] && source "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.bash
[[ "$(uname)" == "Darwin" ]] && source /opt/homebrew/opt/fzf/shell/key-bindings.bash

# The next line updates PATH, enables shell completion for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.bash.inc" ]; then source "$HOME/google-cloud-sdk/path.bash.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.bash.inc" ]; then source "$HOME/google-cloud-sdk/completion.bash.inc"; fi

# Enable conda
if [ -f "/opt/conda/etc/profile.d/conda.sh" ]; then source "/opt/conda/etc/profile.d/conda.sh"; fi


# Path for fly.io flyctl
export FLYCTL_INSTALL="/home/wgoodall01/.fly"
export PATH="$FLYCTL_INSTALL/bin:$PATH"

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


