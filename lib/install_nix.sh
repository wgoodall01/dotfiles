#!/usr/bin/env bash

install_nix() {
	printf "[nix    ] install Nix (multi-user)... "

	if [[ ! -d /nix ]]; then
		sh <(curl -L https://nixos.org/nix/install --silent) --daemon \
			&>"$LOGS/nix_install" \
			</dev/null \
			&& printf "done.\n" \
			|| fatal "failed--check logs/nix_install for details"
	else
		printf "already installed.\n"
	fi
}
