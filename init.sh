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


if [[ ! -e "$DIR/config.sh" ]]; then
	printf "\nERROR: No configuraiton file.\n"
	printf "Run 'cp config.sh.example config.sh' and edit it.\n"
	exit 1
fi

comment "Configuration options:"
source $DIR/config.sh
printf "[config ] Enable SSH key decryption: $CFG_SSH\n"
printf "[config ] Enable GUI app configuration: $CFG_GUI\n"

comment "Dependencies:"
install_apt python3
install_apt python3-dev
install_apt python3-pip
install_apt git
link_custom $DIR/links/._gitconfig ~/.gitconfig
install_apt software-properties-common # for apt-add-repository
fix_local_perms # python needs this for some reason

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
install_pip thefuck

comment "i3wm:"
install_apt i3
link .config/i3

comment "Powerline:"
# fix_local_perms
install_apt socat
install_pip psutil
install_apt "libgit2-dev=0.24.1-2"  # Lock these versions so they work together
install_pip "pygit2=0.24.0"         #
install_apt libffi-dev
install_pip pyuv
if [ "$CFG_GUI" = true ]; then
	install_pip i3ipc
	install_apt x11-xserver-utils
fi
install_pip powerline-status

comment "neovim:"
add_ppa "neovim-ppa/unstable"
install_apt neovim
link .config/nvim
install_pip neovim

comment "Node.js:"
install_nvm
install_nodejs
nvm_init
install_npm yarn
install_npm webpack
install_npm babel-cli
install_npm eslint

comment "Other stuff:"
install_apt htop
install_apt nload
install_apt tree
install_apt golang
install_apt gocode
install_apt xclip
install_apt default-jdk
install_apt silversearcher-ag
