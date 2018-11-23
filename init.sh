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

comment "Configuration options"
source $DIR/config.sh
printf "[config ] Enable SSH key decryption: $CFG_SSH\n"
printf "[config ] Enable GUI app configuration: $CFG_GUI\n"
printf "[config ] Install cloud utils: $CFG_CLOUD\n"

comment "Dependencies"
install_apt git
install_apt gnupg # for ./crypto.sh
install_apt gdebi # install debs, resolve deps
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

if [ "$CFG_GUI" = true ]; then
	comment "i3wm"
	install_apt xorg
	install_apt dconf-tools
	install_apt dconf-cli
	install_apt dbus-x11
	install_apt i3
	link .config/i3
	install_apt xclip

	comment "lightdm"
	install_apt lightdm
	printf "[default] set /etc/X11/default-display-manager..."\
		&& sudo sh -c 'echo "/usr/sbin/lightdm" > "/etc/X11/default-display-manager"'\
		&& sudo dpkg-reconfigure -f noninteractive lightdm\
		&& printf 'done.\n'\
		|| fatal "couldn't change /etc/X11/default-display-manager to /usr/sbin/lightdm."

	comment "Gnome-terminal"
	install_apt gnome-terminal
	link .fonts
	dconf_load "/org/gnome/terminal/" "gnome_terminal_settings"

	comment "Chrome"
	add_apt_key_url "https://dl-ssl.google.com/linux/linux_signing_key.pub"
	add_apt "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main"
	install_apt google-chrome-stable

	comment "Other utils"
	install_apt xclip
	install_pip i3ipc
	install_apt x11-xserver-utils
	install_deb_url gitkraken "https://release.gitkraken.com/linux/gitkraken-amd64.deb"
	install_apt meld

fi

if [ "$CFG_SSH" = true ]; then
	comment "Install SSH keys"
	install_ssh_keys
fi

comment "Shell configuration"
link .bashrc
link .profile
link .bash_stuff
install_apt thefuck
touch ~/.bash_platform\
	&& echo "[setup  ] Make empty bash_platform"

if [ "$CFG_CLOUD" = true ]; then
	comment "Cloud CLIs"
	gcloud_install
	install_apt docker.io
	add_docker_user_group
fi

comment "Powerline"
install_apt socat
install_pip psutil
install_apt "libgit2-dev=0.26.0+dfsg.1-1.1build1"  # Lock these versions so they work together
install_pip "pygit2==0.26.0"                       #
install_apt libffi-dev
install_pip pyuv
install_pip powerline-status

comment "asdf:"
install_asdf

comment "Node.js"
link ".default-npm-packages"
install_asdf_plugin nodejs "https://github.com/asdf-vm/asdf-nodejs.git"
install_asdf_node_keys
install_asdf_lang nodejs "10.6.0"
# install_npm yarn
# install_npm webpack-cli
# install_npm babel-cli
# install_npm eslint
# install_npm prettier
# install_npm nodemon

comment "Golang"
install_asdf_plugin golang https://github.com/kennyp/asdf-golang.git
set_go_env
install_asdf_lang golang "1.10.3"
install_go github.com/nsf/gocode
install_go golang.org/x/tools/cmd/gorename
install_go github.com/golang/dep/cmd/dep

comment "Ruby"
link ".default-gems"
install_apt gcc-6
install_apt "g++-6"
install_apt autoconf  # you need all this stuff because asdf-ruby builds from source.
install_apt bison
install_apt build-essential
install_apt libssl1.0-dev
install_apt libyaml-dev
install_apt libreadline6-dev
install_apt zlib1g-dev
install_apt libncurses5-dev
install_apt libffi-dev
install_apt libgdbm5
install_apt libgdbm-dev
install_asdf_plugin ruby "https://github.com/asdf-vm/asdf-ruby.git"
CC="/usr/bin/gcc-6"\
	PKG_CONFIG_PATH="/usr/lib/openssl-1.0/" install_asdf_lang ruby "2.2.6" -patch <$DIR/res/ruby2x-openssl-patch

comment "Java"
install_asdf_plugin java "https://github.com/skotchpine/asdf-java"
install_asdf_lang java "openjdk-10.0.2"

comment "neovim"
install_apt neovim
link .config/nvim
install_pip neovim
install_pip2 neovim
install_apt editorconfig
nvim_run +PlugInstall
nvim_run +GoInstallBinaries

comment "Other stuff"
install_apt cmake # For deoplete-clang
install_apt clang # /
install_apt dtrx
install_apt htop
install_apt nload
install_apt tree
install_apt silversearcher-ag
install_apt mosh
install_apt aria2
install_apt nginx-core



