let b:ale_linters = {'rust': ['analyzer'] }
let b:ale_fixers = {'rust': ['rustfmt']}
let g:ale_rust_rustfmt_options = '--edition 2021'
let g:ale_rust_analyzer_config = { 'diagnostics': {'disabled': ['inactive-code']} }
