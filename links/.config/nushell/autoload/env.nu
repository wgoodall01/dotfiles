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

# Yarn / NPM global bin
$env.PATH = ($env.PATH | prepend ('~/.yarn/bin' | path expand))
$env.PATH = ($env.PATH | prepend ('~/.config/yarn/global/node_modules/.bin' | path expand))

# Cargo
let cargo_bin = ('~/.cargo/bin' | path expand)
if ($cargo_bin | path exists) {
    $env.PATH = ($env.PATH | prepend $cargo_bin)
}

# ASDF shims
$env.PATH = ($env.PATH | prepend ('~/.asdf/shims' | path expand))
