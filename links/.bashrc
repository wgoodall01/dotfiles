# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

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
shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

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

# Utility commands
lsmake(){
	grep $'^[^\t].*:$' Makefile | cut -d ':' -f 1
}

# Setup powerline-shell
function _update_ps1() {
    PS1="$(~/.bash_stuff/powerline-shell/powerline-shell.py $? 2> /dev/null)"
}

if [ "$TERM" != "linux" ]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi

# Load ssh env
source ~/.ssh/environment

# Setup thefuck
eval $(thefuck --alias)
eval $(thefuck --alias oops)

# Source global env
source /etc/environment

# Add ~/.bash_stuff/bin to path
export PATH="$HOME/.bash_stuff/bin:$PATH"

# Add hub wrapper for git
eval "$(hub alias -s)"

# Misc nags
if ! ssh-add -l &>/dev/null; then
	printf "No SSH keys in ssh-agent - run 'ssh-add'\n"
	NAGGED=true
fi

if [ "$NAGGED" = true ]; then
	hr
fi

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

# Shortcut to update dotfiles
update-dotfiles(){
	~/Dev/dotfiles/update.sh
}

export NVM_DIR="/home/wgoodall01/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"


#t11e setup
export PATH="$PATH:$HOME/Dev/t11e/puppet/bin"
