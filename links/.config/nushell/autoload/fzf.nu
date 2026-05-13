# FZF integration keybindings for Nushell
# Ctrl+T: fuzzy-find files/dirs with fd+fzf, insert selection into commandline
# Ctrl+R: fuzzy-find command history with fzf

def fzf-quote-one [p: string]: nothing -> string {
    if ($p =~ '^[a-zA-Z0-9/._~-]+$') {
        $p
    } else if ($p =~ '^[a-zA-Z0-9/._~ -]+$') {
        $"'($p)'"
    } else {
        mut hashes = "#"
        while ($p | str contains $"'($hashes)") {
            $hashes = $hashes + "#"
        }
        $"r($hashes)'($p)'($hashes)"
    }
}

def fzf-quote-paths [raw: string]: nothing -> string {
    $raw
    | split row (char -u '0000')
    | where {|p| ($p | is-not-empty)}
    | each {|p| fzf-quote-one $p}
    | str join ' '
}

# Split the commandline around the cursor, isolating any trailing partial word
# before the cursor so it can be passed to fzf --query and replaced with the result.
def fzf-split-before-cursor []: nothing -> record {
    let cmdline = (commandline)
    let cursor = (commandline get-cursor)
    let before = ($cmdline | str substring 0..<$cursor)
    let after = ($cmdline | str substring $cursor..)
    let ws_indices = ($before | split chars | enumerate | where {|x| $x.item =~ '\s'} | get index)
    let word_start = if ($ws_indices | is-empty) { 0 } else { ($ws_indices | last) + 1 }
    {
        prefix: ($before | str substring 0..<$word_start)
        query: ($before | str substring $word_start..)
        after: $after
    }
}

$env.config.keybindings ++= [
{
      name: fzf_file
      modifier: control
      keycode: char_t
      mode: [emacs vi_insert vi_normal]
      event: {
          send: executehostcommand
          cmd: "
              if ((commandline | str trim) | is-empty) {
                  let raw = (fd --type d --hidden --follow --exclude .git --print0 | fzf --read0 --print0 --bind=tab:toggle+down --height=40% --reverse | decode utf-8)
                  if ($raw | is-not-empty) {
                      commandline edit --replace (fzf-quote-paths $raw)
                  }
              } else {
                  let ctx = (fzf-split-before-cursor)
                  let raw = (fd --type f --hidden --follow --exclude .git --print0 | fzf --read0 --print0 --multi --bind=tab:toggle+down --height=40% --reverse --query $ctx.query | decode utf-8)
                  if ($raw | is-not-empty) {
                      let quoted = (fzf-quote-paths $raw)
                      commandline edit --replace ($ctx.prefix + $quoted + $ctx.after)
                      commandline set-cursor (($ctx.prefix | str length) + ($quoted | str length))
                  }
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
