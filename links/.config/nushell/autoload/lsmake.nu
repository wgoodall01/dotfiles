# lsmake - list Makefile targets + package.json scripts in a single table
def lsmake [] {
    let makefile = if ("Makefile" | path exists) {
        open Makefile
        | lines
        | where {|line| $line =~ '^[a-zA-Z_-]+:' }
        | each {|line| {name: ($line | split row ":" | first), command: "", source: "Makefile"} }
    } else {
        []
    }

    let pkg = if ("package.json" | path exists) {
        open package.json
        | get -o scripts
        | default {}
        | transpose name command
        | each {|row| {name: $row.name, command: $row.command, source: "package.json"} }
    } else {
        []
    }

    $makefile | append $pkg | table --index false
}
