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

# ASDF shims
$env.PATH = ($env.PATH | prepend ('~/.asdf/shims' | path expand))
