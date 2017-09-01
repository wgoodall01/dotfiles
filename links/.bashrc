# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

enable_debug=false

time_millis(){
	echo "$(date +%s%N) / 1000000" | bc
}
start_time="$(time_millis)"
last_time="$start_time"
time_diff(){
	if $enable_debug; then
		current="$(time_millis)"
		startdiff="$(echo "$current - $start_time" | bc)"
		lastdiff="$(echo "$current - $last_time" | bc)"
		printf "[@%6d]  [+%6d]    $1\n" "$startdiff" "$lastdiff"
		last_time="$current"
	else
		printf "## "
	fi;
}

time_end(){
	clear
}

time_diff "start"


# Set defaults
STUFF_DIR="$HOME/.bash_stuff" # Set a default
source ~/.bash_platform # This is for each platform

# Source global env
[ -e /etc/environment ] && source /etc/environment

# Set PATH with bash_stuff and private bins (osx brew, mostly)
export PATH="$STUFF_DIR/bin:$HOME/bin:$HOME/.local/bin:$PATH"

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
alias ext="dtrx"
alias ".."="cd .."
alias "..."="cd ../.."
alias "...."="cd ../../.."
alias "tree"="tree -I node_modules"

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

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*


time_diff "rvm"
export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo).

time_diff "n"

# Projdir

if [[ ! -e ~/.projdir ]]; then echo ~ > ~/.projdir; fi

pjd(){
	case "$1" in 
		"set") pwd > ~/.projdir;;
		"pwd") if [[ -e ~/.projdir ]]; then cat ~/.projdir; else printf "Projdir does not exist yet.\n"; fi;;
		"")    if [[ -e ~/.projdir ]]; then cd $(cat ~/.projdir); else printf "Projdir does not exist yet.\n"; fi;;
		*)     printf "Error: Bad command. 'set', 'pwd', or '' allowed.\n";;
	esac
}

#Automatically cd to projdir
pjd

time_diff "cd projdir"

# Shortcut to update/install dotfiles
update-dotfiles(){
	~/Dev/dotfiles/update.sh
}

install-dotfiles(){
	~/Dev/dotfiles/init.sh
}


# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

#t11e setup
export PUPPET_VM_NFS_DISABLE=1
export PATH="$PATH:$HOME/Dev/t11e/puppet/bin"
export PATH="$PATH:$HOME/Dev/t11e/donkey/bin"
export PATH="$PATH:$HOME/Dev/t11e/monkey/bin"

# added by travis gem
[ -f /home/wgoodall01/.travis/travis.sh ] && source /home/wgoodall01/.travis/travis.sh

time_diff "path, travis"

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/home/wgoodall01/google-cloud-sdk/path.bash.inc' ]; then source '/home/wgoodall01/google-cloud-sdk/path.bash.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/home/wgoodall01/google-cloud-sdk/completion.bash.inc' ]; then source '/home/wgoodall01/google-cloud-sdk/completion.bash.inc'; fi

time_diff "gcloud setup"

time_end

# Misc nags
if ! ssh-add -l &>/dev/null; then
	printf "No SSH keys in ssh-agent - run 'ssh-add'\n"
	NAGGED=true
fi

if [ "$NAGGED" = true ]; then
	hr
fi

