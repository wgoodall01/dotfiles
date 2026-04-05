# FZF integration keybindings for Nushell
# Ctrl+T: fuzzy-find files with fd+fzf, insert selection into commandline
# Ctrl+R: fuzzy-find command history with fzf

$env.config.keybindings ++= [
    {
        name: fzf_file
        modifier: control
        keycode: char_t
        mode: [emacs vi_insert vi_normal]
        event: {
            send: executehostcommand
            cmd: "
                let result = (fd --type f --hidden --follow --exclude .git | fzf --multi --bind=tab:toggle+down --height=40% --reverse | decode utf-8 | str trim)
                if ($result | is-not-empty) {
                    commandline edit --insert $result
                }
            "
        }
    }
{
        name: fzf_history
        modifier: control
        keycode: char_r
        mode: [emacs vi_insert vi_normal]
        event: {
            send: executehostcommand
            cmd: "
                let result = (history | get command | reverse | uniq | str join (char nl) | fzf --height=40% --reverse | decode utf-8 | str trim)
                if ($result | is-not-empty) {
                    commandline edit --replace $result
                }
            "
        }
    }
]
