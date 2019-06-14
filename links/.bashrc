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


# Set defaults
STUFF_DIR="$HOME/.bash_stuff" # Set a default

# Source global env
[ -e /etc/environment ] && source /etc/environment

# Set PATH with bash_stuff and private bins (osx brew, mostly)
export PATH="./node_modules/.bin:$STUFF_DIR/bin:$HOME/bin:$HOME/.local/bin:$PATH"

# Path for ubuntu snaps
export PATH="$PATH:/snap/bin"

# Path for /usr/local/bin (osx needs this)
export PATH="/usr/local/bin:$PATH"

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

# Setup powerline-shell
function _update_ps1() {
    PS1="$($STUFF_DIR/powerline-shell/powerline-shell.py $? 2> /dev/null)"
}

if [ "$TERM" != "linux" ]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi

time_diff "powerline-shell"

# Load ssh env
source ~/.ssh/environment

time_diff "ssh env"

# Setup thefuck
# eval $(thefuck --alias) # cached below
alias fuck='TF_CMD=$(TF_ALIAS=fuck PYTHONIOENCODING=utf-8 TF_SHELL_ALIASES=$(alias) thefuck $(fc -ln -1)) && eval $TF_CMD; history -s $TF_CMD'

time_diff "thefuck"

# Set $EDITOR
export EDITOR=$(which nvim)

# Alias nvim to vim
alias vim=nvim

# Set $CLICOLOR
export CLICOLOR=1

time_diff "clicolor, editor"

# Add hub wrapper for git
eval "$(hub alias -s)"

time_diff "hub"

# Set Go env vars
export GOPATH="$HOME/Dev/go"
export PATH="$PATH:$GOPATH/bin"

time_diff "go"

source ~/.asdf/asdf.sh
source ~/.asdf/completions/asdf.bash

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
			elif [[ -e "$dir" ]]; then
				printf "~/Dev/$2 already exists, is not a directory."
			else
				mkdir -p "$dir"
				printf "$dir" >~/projdir
				cd "$dir"
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

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

#t11e setup
export PUPPET_VM_NFS_DISABLE=1
export PATH="$PATH:$HOME/Dev/t11e/bin"
export PATH="$PATH:$HOME/Dev/t11e/donkey/bin"

# added by travis gem
[ -f /home/wgoodall01/.travis/travis.sh ] && source /home/wgoodall01/.travis/travis.sh

time_diff "path, travis"

# The next line updates PATH, enables shell completion for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.bash.inc" ]; then source "$HOME/google-cloud-sdk/path.bash.inc"; fi
if [ -f "$HOME/google-cloud-sdk/completion.bash.inc" ]; then source "$HOME/google-cloud-sdk/completion.bash.inc"; fi

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
) 42>"$HOME/.bash_stuff/ssh_pass.lock"

if [ "$NAGGED" = true ]; then
	hr
fi


