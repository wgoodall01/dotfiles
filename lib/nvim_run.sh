#!/usr/bin/env bash

nvim_run(){
	# Run a nvim command, headlessly.
	printf "[nvim   ] run '$1'... "
	nvim --headless $1 +qall &>"$LOGS/nvim_run_$1"\
		&& printf "done.\n"\
		|| fatal "failed - check logs/nvim_run_$1"
}
