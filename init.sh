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
printf "[config ] Enable SSH key decryption      : %s\n" "$CFG_SSH"
printf "[config ] Install cloud utils            : %s\n" "$CFG_CLOUD"
printf "[config ] Enable GUI app configuration   : %s\n" "$CFG_GUI"
printf "[config ] Enable HiDPI GUI support       : %s\n" "$CFG_GUI_HIDPI"
printf "[config ] Language support for Node.js   : %s\n" "$CFG_LANG_NODEJS"
printf "[config ] Language support for Golang    : %s\n" "$CFG_LANG_GOLANG"
printf "[config ] Language support for Ruby      : %s\n" "$CFG_LANG_RUBY"
printf "[config ] Language support for Java      : %s\n" "$CFG_LANG_JAVA"
printf "[config ] Language support for C++       : %s\n" "$CFG_LANG_CPP"
printf "[config ] Language support for Rust      : %s\n" "$CFG_LANG_RUST"
printf "[config ] Environment support for Conda  : %s\n" "$CFG_CONDA"

comment "Dependencies"
install_apt git
install_apt gnupg # for ./crypto.sh
install_apt gdebi # install debs, resolve deps
install_apt curl
install_apt build-essential
install_apt libssl-dev
install_apt libffi-dev
install_apt python
install_apt python-dev
install_apt python3
install_apt python3-dev
install_apt python3-pip
install_apt software-properties-common # for apt-add-repository

if [ "$CFG_GUI" = true ]; then
	comment "i3wm"
	install_apt xorg
	install_apt compton
	install_apt dconf-cli
	install_apt dbus-x11
	install_apt i3
	link .config/i3
	if [ "$CFG_GUI_HIDPI" = true ]; then
		printf "[copy   ] Add /etc/X11/Xresources/set-dpi ..."
		(
			sudo cp "$DIR/res/x11-set-dpi" "/etc/X11/Xresources/set-dpi" &&\
			sudo chown root:root "/etc/X11/Xresources/set-dpi" &&\
			sudo chmod 0644 "/etc/X11/Xresources/set-dpi" &&\
			printf "done.\n" 
		)   || fatal "Could not copy set-dpi to /etc/X11/Xresources"
		printf "[copy   ] Add /etc/gdm3/custom.conf ..."
		(
			sudo cp "$DIR/res/gdm3-custom.conf" "/etc/gdm3/custom.conf" &&\
			sudo chown root:root "/etc/gdm3/custom.conf" &&\
			sudo chmod 0644 "/etc/gdm3/custom.conf" &&\
			printf "done.\n" 
		)   || fatal "Could not copy gdm3-custom.conf to /etc/gdm3/custom.conf"
	fi

	comment "Alacritty"
	add_ppa "mmstick76/alacritty"
	install_apt alacritty
	link .config/alacritty
	link .fonts

	comment "Cursor theme"
	install_apt dmz-cursor-theme
	printf "[alternt] Updating default cursor... "
	(sudo update-alternatives --set x-cursor-theme "/usr/share/icons/DMZ-White/cursor.theme" && printf "done.\n") \
		|| fatal "Failed to update alternatives for cursor theme."

	comment "Firefox"
	install_apt firefox

	comment "Disable ACPI sleep, suspend, hibernate"
	printf "[acpi   ] Mask sleep..."
	(\
		sudo systemctl mask sleep.target suspend.target hibernate.target hybrid-sleep.target &>"$LOGS/disable_acpi_sleep" \
		&& printf "done.\n" \
	) || fatal "Failed to disable ACPI sleep";

	comment "GUI utilities"
	install_apt xclip
	install_pip i3ipc
	install_apt x11-xserver-utils
	install_apt meld
	install_apt ssh-askpass-gnome
	install_snap insomnia
fi

if [ "$CFG_SSH" = true ]; then
	comment "Install SSH keys"
	install_ssh_keys
fi

comment "Git config"
install_apt hub
link .config/git
# NB: DO NOT SYMLINK ~/.config/hub
#     IT CONTAINS AUTH TOKENS

comment "Shell configuration"
link .bashrc
link .profile
link .bash_stuff
link .inputrc # for anything that uses readline
install_apt highlight
install_fzf

if [ "$CFG_CLOUD" = true ]; then
	comment "Cloud CLIs"
	gcloud_install
	install_snap heroku --classic
	install_apt docker.io
	add_docker_user_group
fi

comment "Powerline"
link .config/powerline-shell
install_pip powerline-shell

comment "asdf:"
install_asdf

if [[ "$CFG_LANG_NODEJS" == "true" ]]; then
	comment "Node.js"
	link ".default-npm-packages"
	install_asdf_plugin nodejs "https://github.com/asdf-vm/asdf-nodejs.git"
	install_asdf_node_keys
	install_asdf_lang nodejs "12.12.0"
fi

if [[ "$CFG_LANG_GOLANG" == "true" ]]; then
	comment "Golang"
	install_asdf_plugin golang https://github.com/kennyp/asdf-golang.git
	set_go_env
	install_asdf_lang golang "1.14.4"
	install_go golang.org/x/tools/cmd/gorename
	install_go golang.org/x/tools/gopls@latest
fi

if [[ "$CFG_LANG_RUBY" == "true" ]]; then
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
fi

if [[ "$CFG_LANG_JAVA" == "true" ]]; then
	comment "Java"
	install_asdf_plugin java "https://github.com/skotchpine/asdf-java"
	install_asdf_plugin maven
	install_asdf_lang java "openjdk-10.0.2"
fi

if [[ "$CFG_LANG_CPP" == "true" ]]; then
	comment "C++"
	install_apt cmake # For deoplete-clang
	install_apt clang # /
fi

if [[ "$CFG_LANG_RUST" == "true" ]]; then
	comment "Rust"
	install_asdf_plugin rust 
	install_asdf_lang rust "1.45.0"

fi

if [[ "$CFG_CONDA" == "true" ]]; then
	comment "Conda"
	add_apt_key_url "https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc"
	add_apt "deb [arch=amd64] https://repo.anaconda.com/pkgs/misc/debrepo/conda stable main"
	install_apt conda
fi

comment "neovim"
install_apt neovim
link .config/nvim
install_pip neovim
install_apt editorconfig
install_apt clang-format
nvim_run +PlugInstall
if [[ "$CFG_LANG_GOLANG" == "true" ]]; then 
	nvim_run +GoInstallBinaries
fi

comment "Utilities"
install_apt unp
install_apt entr
install_apt htop
install_apt tig
install_apt nload
install_apt tree
install_apt silversearcher-ag
install_apt fd-find
install_apt mosh
install_apt aria2
install_apt nginx-core
install_snap shellcheck



