#!/usr/bin/env bash

# Dotfiles init script.
# This should be run every time to update dotfiles.
# It should not mess anything up if run multiple times.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source lib/index.sh

cat <<_
  ____        _    __ _ _           _ 
 |  _ \  ___ | |_ / _(_) | ___  ___| |
 | | | |/ _ \| __| |_| | |/ _ \/ __| |
 | |_| | (_) | |_|  _| | |  __/\__ \_|
 |____/ \___/ \__|_| |_|_|\___||___(_)
 Logging to logs/init
_

# Prompt for optional stuff
comment "Options:"
feature CFG_SSH "Install SSH keys"
feature CFG_GUI "Install GUI tools/fonts"

comment "Dependencies:"
install_apt python3
install_apt python3-dev
install_apt python3-pip
install_apt git
link .gitconfig
install_apt software-properties-common # for apt-add-repository

if [ "$CFG_GUI" = true ]; then
	comment "Powerline patched fonts: "
	link .fonts

	comment "Chrome:"
	add_ppa_chrome
	install_apt google-chrome-stable
fi

if [ "$CFG_SSH" = true ]; then
	comment "Install SSH keys: "
	install_ssh_keys
fi

comment "Shell configuration:"
link .bashrc
link .profile
link .bash_stuff
[ "$CFG_GUI" = true ] && dconf_load "/org/gnome/terminal/" "gnome_terminal_settings"
fix_local_perms # python needs this for some reason
install_pip thefuck

comment "i3wm:"
install_apt i3
link .config/i3

comment "neovim:"
add_ppa "neovim-ppa/unstable"
install_apt neovim
link .config/nvim

comment "Node.js:"
install_nvm
install_nodejs
nvm_init
install_npm yarn
install_npm webpack
install_npm babel
install_npm eslint

comment "Other stuff:"
install_apt htop
install_apt nload
install_apt tree
install_apt golang
install_apt xclip
install_apt default-jdk
install_apt silversearcher-ag
