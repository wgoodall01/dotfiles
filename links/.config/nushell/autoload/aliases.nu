# Aliases and small utilities

# Navigation
alias g = git
alias ... = cd ../..
alias .... = cd ../../..

# Tools
alias vim = nvim
alias tree = ^tree -I node_modules

# macOS-specific
def gmake-alias [] {
    if (sys host | get name) == "Darwin" {
        alias make = gmake
    }
}

# todo - search for TODOs in codebase
def todo [dir?: string] {
    if $dir != null {
        ^rg -i todo $dir
    } else {
        let root = (do { ^git rev-parse --show-toplevel } | complete)
        if $root.exit_code == 0 {
            ^rg -i todo ($root.stdout | str trim)
        } else {
            ^rg -i todo .
        }
    }
}

# - (dash) - smart cd-or-edit: dir → cd+ls, file → $EDITOR
def --env "-" [...args: string] {
    if ($args | is-empty) {
        print "Usage: - <directory|file>"
        return
    }
    let target = $args.0
    if not ($target | path exists) {
        print $"'($target)' does not exist."
        return
    }
    if ($target | path type) == "dir" {
        cd $target
        ls -a
    } else {
        ^$env.EDITOR ...$args
    }
}

# touch-shell - create a new bash script with boilerplate
def touch-shell [file: string] {
    if ($file | path exists) {
        ^touch $file
    } else {
        "#!/usr/bin/env bash\nset -euo pipefail\nshopt -s inherit_errexit\nDIR=\"$( cd \"$( dirname \"$(readlink -f \"${BASH_SOURCE[0]}\")\" )\" >/dev/null 2>&1 && pwd )\"\n" | save $file
    }
    ^chmod +x $file
}

# onchange - watch for file changes and run command
def onchange [...cmd: string] {
    ^fd | ^entr -s ($cmd | str join " ")
}

# grep color aliases (for when shelling out)
alias grep = ^grep --color=auto
alias fgrep = ^fgrep --color=auto
alias egrep = ^egrep --color=auto

# `ll` muscle memory
alias ll = ls
