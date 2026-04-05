# pjd - Project directory manager
# Manages a "project directory" bookmark stored in ~/.projdir

def projdir-file [] {
    '~/.projdir' | path expand
}

def projdir-get [] {
    let f = (projdir-file)
    if ($f | path exists) {
        open $f | str trim
    } else {
        error make {msg: "Projdir not set yet. Run `pjd set` first."}
    }
}

# cd to projdir
def --env pjd [] {
    cd (projdir-get)
}

# Set projdir to current directory
def "pjd set" [] {
    $env.PWD | save -f (projdir-file)
}

# Print projdir path
def "pjd pwd" [] {
    projdir-get
}

# cd to ~/Dev/<dir> and set projdir
def --env "pjd to" [dir: string] {
    let target = ($"~/Dev/($dir)" | path expand)
    if ($target | path exists) {
        cd $target
        pjd set
    } else {
        error make {msg: $"~/Dev/($dir) is not a directory."}
    }
}

# cd to git root of projdir
def --env "pjd root" [] {
    cd (projdir-get)
    cd (^git rev-parse --show-toplevel | str trim)
}
