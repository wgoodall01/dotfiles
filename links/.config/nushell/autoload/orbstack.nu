# OrbStack keeps its binaries in ~/.orbstack/bin. Append to PATH.
$env.PATH = $env.PATH | append ('~/.orbstack/bin/' | path expand)
