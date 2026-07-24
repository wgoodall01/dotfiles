#!/usr/bin/env bash

# Dotfiles init script.
# This should be run every time to update dotfiles.
# It should not mess anything up if run multiple times.
#
# macOS only.
#
# NOTE: This script does not install system packages. The old apt-based
# dependency and utility lists were removed along with the rest of the Linux
# support; install what you need with Homebrew yourself. Language runtimes and
# CLIs are pinned in links/.config/mise/config.toml and installed with mise.

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


if [[ "$(uname)" != "Darwin" ]]; then
	printf "\nERROR: These dotfiles are macOS-only.\n"
	exit 1
fi

if [[ ! -e "$DIR/config.sh" ]]; then
	printf "\nERROR: No configuraiton file.\n"
	printf "Run 'cp config.sh.example config.sh' and edit it.\n"
	exit 1
fi

comment "Configuration options"
source $DIR/config.sh
printf "[config ] Enable SSH key decryption      : %s\n" "$CFG_SSH"
printf "[config ] Decrypt Pushover config        : %s\n" "$CFG_PUSHOVER"

if [ "$CFG_SSH" = true ]; then
	comment "Install SSH keys"
	install_ssh_keys
fi

comment "Git config"
link .config/git

comment "Shell configuration"
link .bashrc
link .inputrc # for anything that uses readline
link .config/nushell
install_fzf

# NOTE: ~/.profile, ~/.bash_profile and ~/.zprofile are deliberately NOT linked.
# The allGood monorepo's scripts/provision.sh manages a block inside each of
# them (Homebrew shellenv, postgresql, and `mise activate`), and it replaces the
# file wholesale when it does -- which would clobber a symlink into this repo.

comment "mise"
# Link only the config file, not the whole directory -- mise writes its own
# state (settings, trusted-config records) into ~/.config/mise alongside it.
link .config/mise/config.toml
setup_mise
mise_install

comment "Powerline"
link .config/powerline-shell
install_pip powerline-shell

comment "neovim"
link .ctags
link .config/nvim
nvim_run +PlugInstall
nvim_run +PlugUpdate

comment "Pushover"
if [[ "$CFG_PUSHOVER" == "true" ]]; then
	# NOTE: pushover-cli itself is no longer installed here -- it used to come
	# from asdf's golang plugin. If you want it back, mise can build it directly:
	#   mise use -g "go:github.com/adrianrudnik/pushover-cli@latest"
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
	printf "[skip   ] Pushover disabled in config.sh\n"
fi
