# Describe a command, like `? Symbol` in the Wolfram Language: show its help,
# and for custom commands, where it's defined and its source.
def "?" [...command: string] {
    let name = ($command | str join ' ')
    if ($name | is-empty) {
        print "Usage: ? <command>  (e.g. `? from md`)"
        return
    }

    let known = (
        (scope commands | where name == $name | is-not-empty)
        or (scope aliases | where name == $name | is-not-empty)
    )

    if not $known {
        # Not a command or alias — maybe an external binary.
        let found = (which --all $name)
        if ($found | is-empty) {
            error make --unspanned {msg: $"`($name)` is not a known command, alias, or binary"}
        }
        print ($found | table)
        return
    }

    print (help ...$command)

    # Built-ins have no viewable source; custom commands and aliases do.
    let src = (try { view source $name })
    if $src != null {
        let file = (try { view source $name | metadata | get source })
        if $file != null and ($file | path exists) {
            print $"(ansi green)Defined in(ansi reset): ($file)"
            print ""
        }
        print ($src | nu-highlight)
    }
}
