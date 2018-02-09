#!/usr/bin/env bash

# Dotfiles init script.
# This should be run every time to update dotfiles.
# It should not mess anything up if run multiple times.

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $DIR
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
printf "[config ] Install cloud utils: $CFG_CLOUD\n"

comment "Dependencies:"
install_apt git
install_apt curl
install_apt python
install_apt python3
install_apt python3-dev
install_apt build-essential
install_apt libssl-dev
install_apt libffi-dev
install_apt python-dev
install_apt python-pip
install_apt python3-pip
link_custom $DIR/links/._gitconfig ~/.gitconfig
install_apt software-properties-common # for apt-add-repository
# fix_local_perms # python needs this for some reason

if [ "$CFG_GUI" = true ]; then
	comment "Powerline patched fonts: "
	link .fonts

	comment "i3wm:"
	install_apt xorg
	install_apt dconf-tools
	install_apt dconf-cli
	install_apt dbus-x11
	install_apt gnome-terminal
	install_apt i3
	link .config/i3

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
touch ~/.bash_platform && echo "[setup  ] Make empty bash_platform"
[ "$CFG_GUI" = true ] && dconf_load "/org/gnome/terminal/" "gnome_terminal_settings"
install_pip thefuck

if [ "$CFG_CLOUD" = true ]; then
	comment "Cloud CLIs:"
	gcloud_install
	docker_install
fi

comment "Powerline:"
# fix_local_perms
install_apt socat
install_pip psutil
install_apt "libgit2-dev=0.24.1-2"  # Lock these versions so they work together
install_pip "pygit2==0.24.0"        #
install_apt libffi-dev
install_pip pyuv
if [ "$CFG_GUI" = true ]; then
	install_pip i3ipc
	install_apt x11-xserver-utils
fi
install_pip powerline-status

comment "Node.js:"
install_n
install_npm webpack
install_npm babel-cli
install_npm eslint
install_npm prettier
install_npm nodemon

comment "Golang:"
add_ppa "longsleep/golang-backports"
install_apt golang
install_go github.com/nsf/gocode
install_go golang.org/x/tools/cmd/gorename
install_go github.com/golang/dep/cmd/dep

comment "Java:"
install_apt default-jdk

comment "neovim:"
add_ppa "neovim-ppa/unstable"
install_apt neovim
link .config/nvim
install_pip neovim
install_pip2 neovim
install_apt editorconfig
nvim +PlugInstall +qall
nvim +GoInstallBinaries

comment "Other stuff:"
install_apt cmake # For deoplete-clang
install_apt clang # /
install_apt dtrx
install_apt htop
install_apt nload
install_apt tree
install_apt meld
install_deb_url gitkraken "https://release.gitkraken.com/linux/gitkraken-amd64.deb"
install_apt xclip
install_apt unison
install_apt silversearcher-ag
install_apt aria2
