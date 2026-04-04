" 2-space indentation
set tabstop=2 expandtab shiftwidth=2 softtabstop=2

let g:ale_fixers = ['prettier', 'remove_trailing_lines', 'trim_whitespace']
let g:ale_linters_ignore = ['deno']
let g:ale_javascript_prettier_executable = 'prettier'

let g:ale_echo_msg_format = 'linter: %s'
