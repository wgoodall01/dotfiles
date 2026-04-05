# Starship prompt integration
# Moved from vendor/autoload/starship.nu

export-env { $env.STARSHIP_SHELL = "nu"; load-env {
    STARSHIP_SESSION_KEY: (random chars -l 16)
    PROMPT_MULTILINE_INDICATOR: (
        ^/opt/homebrew/bin/starship prompt --continuation
    )

    PROMPT_INDICATOR: ""

    PROMPT_COMMAND: {||
        (
            let cmd_duration = if $env.CMD_DURATION_MS == "0823" { 0 } else { $env.CMD_DURATION_MS };
            ^/opt/homebrew/bin/starship prompt
                --cmd-duration $cmd_duration
                $"--status=($env.LAST_EXIT_CODE)"
                --terminal-width (term size).columns
                ...(
                    if (which "job list" | where type == built-in | is-not-empty) {
                        ["--jobs", (job list | length)]
                    } else {
                        []
                    }
                )
        )
    }

    config: ($env.config? | default {} | merge {
        render_right_prompt_on_last_line: true
    })

    PROMPT_COMMAND_RIGHT: {||
        (
            let cmd_duration = if $env.CMD_DURATION_MS == "0823" { 0 } else { $env.CMD_DURATION_MS };
            ^/opt/homebrew/bin/starship prompt
                --right
                --cmd-duration $cmd_duration
                $"--status=($env.LAST_EXIT_CODE)"
                --terminal-width (term size).columns
                ...(
                    if (which "job list" | where type == built-in | is-not-empty) {
                        ["--jobs", (job list | length)]
                    } else {
                        []
                    }
                )
        )
    }
}}
