# Environment variables and PATH

# Homebrew
if ("/opt/homebrew/bin/brew" | path exists) {
    $env.PATH = ($env.PATH | prepend "/opt/homebrew/bin" | prepend "/opt/homebrew/sbin")
}

# ~/.local/bin
$env.PATH = ($env.PATH | prepend ('~/.local/bin' | path expand))

# Editor
$env.EDITOR = "nvim"
$env.MANPAGER = "nvim +Man!"

# Colors
$env.CLICOLOR = "1"

# Cargo
let cargo_bin = ('~/.cargo/bin' | path expand)
if ($cargo_bin | path exists) {
    $env.PATH = ($env.PATH | prepend $cargo_bin)
}

# mise (language runtimes and CLIs) is activated from `allgood.nu` in this same
# autoload directory, which the allGood monorepo's scripts/provision.sh
# generates -- it inlines the output of `mise activate nu` there. We don't
# activate it here as well, because activating twice duplicates Nushell's
# env-conversion hooks.
#
# If you're on a machine without the monorepo, generate the equivalent with:
#   mise activate nu | save autoload/mise.nu
