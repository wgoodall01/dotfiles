# SSH agent: warn if no keys loaded

let has_keys = (do { ^ssh-add -l } | complete | get exit_code) == 0

if not $has_keys {
    let bg = "\e[48;2;90;0;0m"   # dark red, matches prompt untracked style
    let fg = "\e[38;2;255;255;255m"
    let reset = "\e[0m"
    print $"($bg)($fg) ssh: no keys loaded — run `ssh-add` ($reset)"
}
