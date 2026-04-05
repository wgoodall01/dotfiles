# Bark AWS profile preset

def "!bark" [...cmd: string] {
    with-env { AWS_PROFILE: "wag_bark" } {
        ^($cmd | first) ...($cmd | skip 1)
    }
}
