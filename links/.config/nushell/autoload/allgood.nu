# allGood aliases and environment presets

alias sf = ^('~/Dev/ag/m/apps/sfdc/node_modules/.bin/sf' | path expand)
alias ag = allgood

# agb - cd to allgood box run output
def --env agb [...args: string] {
    cd (^allgood box run ...$args | str trim)
}

# !prod - run command with prod Temporal/AWS env vars
def "!prod" [...cmd: string] {
    let creds = ('~/Dev/ag/creds/prod' | path expand)
    with-env {
        TEMPORAL_CLI_ADDRESS: "prod-us-west-2.wxrfl.tmprl.cloud:7233"
        TEMPORAL_CLI_NAMESPACE: "prod-us-west-2.wxrfl"
        TEMPORAL_CLI_TLS_CERT: $"($creds)/temporal_client_cert.crt"
        TEMPORAL_CLI_TLS_KEY: $"($creds)/temporal_client_key.key"
        AWS_PROFILE: "ag_prod"
        AG_DEPLOY_ENV: "prod"
        AG_PROFILE: "prod"
    } {
        ^($cmd | first) ...($cmd | skip 1)
    }
}

# !dev - run command with dev/stage Temporal/AWS env vars
def "!dev" [...cmd: string] {
    let creds = ('~/Dev/ag/creds/dev' | path expand)
    with-env {
        TEMPORAL_CLI_ADDRESS: "stage-us-west-2.wxrfl.tmprl.cloud:7233"
        TEMPORAL_CLI_NAMESPACE: "stage-us-west-2.wxrfl"
        TEMPORAL_CLI_TLS_CERT: $"($creds)/temporal_client_cert.crt"
        TEMPORAL_CLI_TLS_KEY: $"($creds)/temporal_client_key.key"
        AWS_PROFILE: "ag_dev"
        AG_DEPLOY_ENV: "stage"
        AG_PROFILE: "stage"
    } {
        ^($cmd | first) ...($cmd | skip 1)
    }
}
