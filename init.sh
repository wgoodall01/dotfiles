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
printf "[config ] [lang] Node.js   : %s\n" "$CFG_LANG_NODEJS"
printf "[config ] [lang] Golang    : %s\n" "$CFG_LANG_GOLANG"
printf "[config ] [lang] Ruby      : %s\n" "$CFG_LANG_RUBY"
printf "[config ] [lang] Java      : %s\n" "$CFG_LANG_JAVA"
printf "[config ] [lang] Python    : %s\n" "$CFG_LANG_PYTHON"
printf "[config ] [lang] C++       : %s\n" "$CFG_LANG_CPP"
printf "[config ] [lang] Rust      : %s\n" "$CFG_LANG_RUST"
printf "[config ] [lang] Zig       : %s\n" "$CFG_LANG_ZIG"
printf "[config ] Environment support for Conda  : %s\n" "$CFG_CONDA"
printf "[config ] Environment support for Nix    : %s\n" "$CFG_NIX"

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
install_apt pipx
install_apt python3-dev
install_apt python3-pip
install_apt software-properties-common # for apt-add-repository

comment "Local services"
link .config/systemd

if [[ "$CFG_OPEN_VM_TOOLS" == "true" ]]; then
	comment "Open VM Tools"
	install_apt open-vm-tools
fi

if [ "$CFG_GUI" = true ]; then
	comment "i3wm"
	link .local/bin/dpi
	link .local/bin/lock
	install_apt xorg
	install_apt compton
	install_apt udevil
	install_apt dconf-cli
	install_apt dbus-x11
	install_apt hsetroot
	install_apt i3
	link .config/i3

	run "gdm3" "Add /etc/gdm3/custom.conf" \
		sudo cp "$DIR/res/gdm3-custom.conf" "/etc/gdm3/custom.conf"
	run "gdm3" "Chown /etc/gdm3/custom.conf" \
		sudo chown root:root "/etc/gdm3/custom.conf"
	run "gdm3" "Chmod /etc/gdm3/custom.conf" \
		sudo chmod 0644 "/etc/gdm3/custom.conf"

	comment "Alacritty"
	install_apt alacritty
	link .config/alacritty
	link .fonts

	comment "Cursor theme"
	install_apt dmz-cursor-theme
	run "alternt" "Update default cursor..." \
		sudo update-alternatives --set \
			x-cursor-theme "/usr/share/icons/DMZ-White/cursor.theme"

	comment "Firefox"
	install_apt firefox-esr

	comment "GUI utilities"
	install_apt xclip
	install_apt python3-i3ipc
	install_apt x11-xserver-utils
	install_apt meld
	install_apt ssh-askpass-gnome

	if [[ "$CFG_PARALLELS" == "true" ]]; then
		comment "Parallels Tools"
		run 'service' 'Enable prlcc service' \
			systemctl --user enable --now prlcc.service
		run 'service' 'Enable prlcp service' \
			systemctl --user enable --now prlcp.service
	fi


	if [[ "$CFG_OPEN_VM_TOOLS" == "true" ]]; then
		comment "VM tools (GUI)"
		install_apt open-vm-tools-desktop
		run "ACPI" "Mask sleep" \
			sudo systemctl mask sleep.target suspend.target \
				hibernate.target hybrid-sleep.target
	fi


	if [[ "$CFG_GROUPWARE" == "true" ]]; then
		comment "Groupware"
		install_snap telegram-desktop
		install_snap slack --classic

		add_apt_key_url "https://zoom.us/linux/download/pubkey"
		install_deb_url zoom "https://zoom.us/client/latest/zoom_amd64.deb"

		run "zoom" "Set DPI scaling" \
			sed -i 's/scaleFactor=1/scaleFactor=1.25/g' "$HOME/.config/zoomus.conf"
	fi

	if [[ "$CFG_JETBRAINS" == "true" ]]; then
		comment "JetBrains"
		install_snap intellij-idea-ultimate --classic
		install_snap clion --classic
	fi
fi

if [ "$CFG_SSH" = true ]; then
	comment "Install SSH keys"
	install_ssh_keys
fi

comment "Git config"
link .config/git
function install_gh_cli() {
	curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg 2>/dev/null \
	&& sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
}
run "gh" "Add 'gh' CLI repository" install_gh_cli
install_apt gh

comment "Shell configuration"
link .bashrc
link .profile
link .inputrc # for anything that uses readline
install_apt highlight
install_fzf

comment "asdf:"
install_asdf

if [ "$CFG_CLOUD" = true ]; then
	comment "Cloud CLIs"
	install_asdf_plugin gcloud
	install_asdf_plugin awscli
	add_docker_user_group

	add_apt_key_url "https://download.docker.com/linux/debian/gpg"
	add_apt "deb [arch=$(dpkg --print-architecture)] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
	install_apt docker-ce docker-compose-plugin
fi

comment "Powerline"
link .config/powerline-shell
install_pip powerline-shell

if [[ "$CFG_LANG_PYTHON" == "true" ]]; then
	comment "Python"
	install_pip "black" 
fi

if [[ "$CFG_LANG_NODEJS" == "true" ]]; then
	comment "Node.js"
	link ".default-npm-packages"
	install_asdf_plugin nodejs "https://github.com/asdf-vm/asdf-nodejs.git"
	nodejs_major_version="18"
	nodejs_version="$(asdf list-all nodejs | grep -E "^$nodejs_major_version\\." | tail -n1)"
	install_asdf_lang nodejs "$nodejs_version"
fi

if [[ "$CFG_LANG_GOLANG" == "true" ]]; then
	comment "Golang"
	install_asdf_plugin golang https://github.com/kennyp/asdf-golang.git
	install_asdf_lang golang "1.17.6"
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
	install_asdf_plugin java
	install_asdf_plugin maven
	install_asdf_lang java "openjdk-18"
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
	install_apt lld # LLVM linker, for performance
	RUSTC_WRAPPER="" install_asdf_lang rust "nightly"
	install_asdf_plugin rust-analyzer
	install_asdf_lang rust-analyzer nightly
fi

if [[ "$CFG_LANG_ZIG" == "true" ]]; then
	comment "Zig"
	install_asdf_plugin "zig"
	install_asdf_lang zig "0.10.1"
fi

if [[ "$CFG_CONDA" == "true" ]]; then
	comment "Conda"
	add_apt_key_url "https://repo.anaconda.com/pkgs/misc/gpgkeys/anaconda.asc"
	add_apt "deb [arch=$(dpkg --print-architecture)] https://repo.anaconda.com/pkgs/misc/debrepo/conda stable main"
	install_apt conda
fi

comment "neovim"
install_apt neovim
install_apt exuberant-ctags
link .ctags
link .config/nvim
install_apt python3-neovim
install_apt editorconfig
install_apt clang-format
nvim_run +PlugInstall
nvim_run +PlugUpdate

comment "Pushover"
if [[ "$CFG_LANG_GOLANG" == "true" ]]; then
	install_go github.com/adrianrudnik/pushover-cli@latest

	if [[ ! -f ~/.config/pushover-cli/config.json ]]; then
		printf "[push   ] Decrypt config..." \
			&& mkdir -p "$HOME/.config/pushover-cli/" \
			&& ./crypto.sh decrypt \
				"$DIR/enc/.config/pushover-cli/config.json" \
				~/.config/pushover-cli/config.json \
				>/dev/null \
			&& printf "done.\n" \
			|| fatal "failed to decrypt pushover config"
	else
		printf "[push   ] config already present\n"
	fi


else
	printf "[skip   ] Skipping because we don't have golang\n"
fi

comment "Utilities"
install_apt openssh-server
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
install_apt shellcheck
link .local/bin/ngrok
