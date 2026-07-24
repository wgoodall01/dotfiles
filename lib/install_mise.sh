#!/usr/bin/env bash

# Check that mise is available, and put its tools on PATH for the rest of this
# script. We deliberately don't install mise here -- this script doesn't manage
# system packages.
setup_mise(){
	printf "[mise   ] check mise: "
	if ! command -v mise &>/dev/null; then
		fatal "mise is not installed. Run 'brew install mise', then re-run this script."
	fi
	printf "%s\n" "$(mise --version)"

	# Use shims rather than `mise activate`, because activation installs a shell
	# hook that only fires between interactive prompts.
	eval "$(mise activate bash --shims)"
}

# Install every tool pinned in the global config (links/.config/mise/config.toml,
# symlinked to ~/.config/mise/config.toml).
#
# Unlike asdf, mise needs no separate "plugin add" step -- it resolves each tool
# from its built-in registry on demand. We run this from $HOME so we pick up the
# global pins rather than any project config below the current directory.
mise_install(){
	printf "[mise   ] install pinned tools... "
	(cd "$HOME" && mise install) &>"$LOGS/mise_install_tools" \
		&& printf "done.\n" \
		|| fatal "failed--check logs/mise_install_tools for details"
}
