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
printf "[config ] GUI: Install groupware         : %s\n" "$CFG_GROUPWARE"
printf "[config ] Language support for Node.js   : %s\n" "$CFG_LANG_NODEJS"
printf "[config ] Language support for Golang    : %s\n" "$CFG_LANG_GOLANG"
printf "[config ] Language support for Ruby      : %s\n" "$CFG_LANG_RUBY"
printf "[config ] Language support for Java      : %s\n" "$CFG_LANG_JAVA"
printf "[config ] Language support for Python    : %s\n" "$CFG_LANG_PYTHON"
printf "[config ] Language support for C++       : %s\n" "$CFG_LANG_CPP"
printf "[config ] Language support for Rust      : %s\n" "$CFG_LANG_RUST"
printf "[config ] Environment support for Conda  : %s\n" "$CFG_CONDA"

comment "Dependencies"
install_apt git
install_apt git-lfs
install_apt gnupg # for ./crypto.sh
install_apt gdebi # install debs, resolve deps
install_apt curl
install_apt build-essential
install_apt libssl-dev
install_apt libffi-dev
install_apt python3
install_apt python3-dev
install_apt python3-pip
install_apt software-properties-common # for apt-add-repository

if [ "$CFG_GUI" = true ]; then
	comment "i3wm"
	link .local/bin/dpi
	install_apt xorg
	install_apt compton
	install_apt udevil
	install_apt dconf-cli
	install_apt dbus-x11
	install_apt hsetroot
	install_apt i3
	link .config/i3
	printf "[copy   ] Add /etc/gdm3/custom.conf ..."
	(
		sudo cp "$DIR/res/gdm3-custom.conf" "/etc/gdm3/custom.conf" &&\
		sudo chown root:root "/etc/gdm3/custom.conf" &&\
		sudo chmod 0644 "/etc/gdm3/custom.conf" &&\
		printf "done.\n" 
	)   || fatal "Could not copy gdm3-custom.conf to /etc/gdm3/custom.conf"

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

	comment "VM tools"
	install_apt open-vm-tools-desktop

	if [[ "$CFG_GROUPWARE" == "true" ]]; then
		comment "Groupware"
		install_snap zoom-client
		install_snap teams
		install_snap telegram-desktop
		install_snap slack --classic
		install_deb_url webex 'https://binaries.webex.com/WebexDesktop-Ubuntu-Official-Package/Webex.deb'
		install_deb_url roam-research 'https://roam-electron-deploy.s3.us-east-2.amazonaws.com/roam-research_0.0.13_amd64.deb'
	fi
fi

if [ "$CFG_SSH" = true ]; then
	comment "Install SSH keys"
	install_ssh_keys
fi

comment "Git config"
install_apt hub
link .config/git
# NB: DO NOT SYMLINK ~/.config/hub. IT CONTAINS AUTH TOKENS. OOPS.

comment "Shell configuration"
link .bashrc
link .profile
link .inputrc # for anything that uses readline
install_apt highlight
install_fzf

if [ "$CFG_CLOUD" = true ]; then
	comment "Cloud CLIs"
	install_asdf_plugin gcloud
	install_asdf_plugin awscli
	install_apt docker.io
	add_docker_user_group
fi

comment "Powerline"
link .config/powerline-shell
install_pip powerline-shell

comment "asdf:"
install_asdf

if [[ "$CFG_LANG_PYTHON" == "true" ]]; then
	comment "Python"
	install_pip "black"
fi

if [[ "$CFG_LANG_NODEJS" == "true" ]]; then
	comment "Node.js"
	link ".default-npm-packages"
	install_asdf_plugin nodejs "https://github.com/asdf-vm/asdf-nodejs.git"
	install_asdf_node_keys
	install_asdf_lang nodejs "lts-fermium"
fi

if [[ "$CFG_LANG_GOLANG" == "true" ]]; then
	comment "Golang"
	install_asdf_plugin golang https://github.com/kennyp/asdf-golang.git
	set_go_env
	install_asdf_lang golang "1.14.4"
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
fi

if [[ "$CFG_LANG_JAVA" == "true" ]]; then
	comment "Java"
	install_apt ca-certificates-java
	install_snap intellij-idea-ultimate
	install_asdf_plugin java
	install_asdf_plugin maven
	install_asdf_lang java "openjdk-11.0.2"
fi

if [[ "$CFG_LANG_CPP" == "true" ]]; then
	comment "C++"
	install_apt cmake # For deoplete-clang
	install_apt clang # /
fi

if [[ "$CFG_LANG_RUST" == "true" ]]; then
	comment "Rust"
	install_asdf_plugin rust https://github.com/code-lever/asdf-rust
	link .default-cargo-crates
	link .cargo
	install_apt lld # LLVM linker, for performance
	RUSTC_WRAPPER="" install_asdf_lang rust "nightly"
	link .local/bin/rust-analyzer
fi

if [[ "$CFG_CONDA" == "true" ]]; then
	comment "Conda"
	add_apt_key_url "https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc"
	add_apt "deb [arch=amd64] https://repo.anaconda.com/pkgs/misc/debrepo/conda stable main"
	install_apt conda
fi

comment "neovim"
install_apt neovim
install_apt exuberant-ctags
link .ctags
link .config/nvim
install_pip neovim
install_apt editorconfig
install_apt clang-format
nvim_run +PlugInstall
nvim_run +PlugUpdate
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
install_apt fd-find
install_apt jq
install_apt ripgrep
install_apt mosh
install_apt aria2
install_apt nginx-core
install_snap shellcheck
