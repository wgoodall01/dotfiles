let s:editor_root=expand('~/.config/nvim/')

" Stuff for Plug
set nocompatible
filetype off
call plug#begin(s:editor_root . 'plugged')

" Misc Utilities
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'ap/vim-css-color'
Plug 'godlygeek/tabular'

" Easymotion - Abbreviations and stuff
Plug 'easymotion/vim-easymotion'
let g:EasyMotion_do_mapping = 0 " Disable default mappings
let g:EasyMotion_smartcase = 1 " Smartcase--ignore case for lowercase
nmap s <Plug>(easymotion-overwin-f2)

" Editorconfig config
Plug 'editorconfig/editorconfig-vim'
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

" Auto reload files
set autoread

" vim-go config
Plug 'fatih/vim-go', {'for':'go'}
" Don't auto-update go tools with :GoInstallBinaries
let g:go_get_update = 0

" Config for most languages
Plug 'sheerun/vim-polyglot'

" Neoformat - format on save, should use prettier for most things.
Plug 'sbdchd/neoformat'
let g:neoformat_cpp_clangformat = {
			\'args': ['--style="{IndentWidth: 4, TabWidth: 4, UseTab: Always, PointerAlignment: Left}"'],
			\'exe': 'clang-format',
			\ }

let g:neoformat_enabled_javascript = ['prettier']
let g:neoformat_enabled_css = ['prettier']
let g:neoformat_enabled_scss = ['prettier']
let g:neoformat_enabled_yaml = ['prettier']
let g:neoformat_enabled_cpp = ['clangformat']
let g:neoformat_only_msg_on_error = 1

let g:neoformat_on_save = 1
function MaybeNeoformat()
	if g:neoformat_on_save
		Neoformat
	endif
endfunction

augroup fmt
	autocmd!
	autocmd BufWritePre * | call MaybeNeoformat()
augroup END

" Disable neoformat for t11e/homeland
augroup t11e_homeland_no_neoformat
	autocmd!
	autocmd BufNewFile,BufRead */t11e/homeland/* let g:neoformat_on_save = 0
augroup END

" Set columns for cs-1332
augroup cs_1332_line_length
	autocmd!
	autocmd BufNewFile,BufRead */Dev/cs-1332/* set textwidth=80 colorcolumn=+1
augroup END

" add ':date' to insert $(date)
command Date r ! date -Iseconds

" Lightline
Plug 'itchyny/lightline.vim'
let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'fugitive#head'
      \ },
      \ }

" fzf for opening files
Plug '~/.fzf'
Plug 'junegunn/fzf.vim'
function! s:find_git_root()
  return system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
endfunction
let g:fzf_layout = { 'down': '~20%' }
command! Files call fzf#vim#files(s:find_git_root(), {'options': '--prompt " /"'})
noremap <silent> <c-p> :Files<CR>
noremap <silent> <c-l> :Commands<CR>

" Linting config
Plug 'w0rp/ale'
let g:ale_lint_on_text_changed = 'never'
highlight SpellBad ctermbg=DarkMagenta ctermfg=White
highlight SpellCap ctermfg=DarkGray

" Colorcolumn colors
highlight ColorColumn ctermbg=darkgray

" Completions config
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-go', { 'do': 'make', 'for':'go' }
Plug 'zchee/deoplete-jedi', {'for':'python'}
Plug 'tweekmonster/deoplete-clang2', {'for':'cpp'}
let g:deoplete#enable_at_startup = 1
" set completeopt-=preview
" inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

" Language server client for autocomplete
Plug 'autozimu/LanguageClient-neovim', { 'branch': 'next', 'do': 'bash install.sh' }
let g:LanguageClient_autoStart = 1
let g:LanguageClient_useVirtualText = 0
let g:LanguageClient_serverCommands = {
	\ 'javascript': ['javascript-typescript-stdio', '-l', '/tmp/tslog'],
	\ 'typescript': ['javascript-typescript-stdio', '-l', '/tmp/tslog'],
	\ 'rust': ['rls']
	\ }
noremap <silent> <Leader>c :call LanguageClient_contextMenu()<CR>

" Java autocomplete config
Plug 'artur-shaik/vim-javacomplete2', {'for':'java'}
autocmd FileType java let g:deoplete#auto_complete_delay=1000
autocmd FileType java setlocal omnifunc=javacomplete#Complete

" Set tabs as \t and 4 spaces wide
set tabstop=4
set softtabstop=0 noexpandtab
set shiftwidth=4

" TTY config
set ttyfast
set mouse=a

" always show sign column
set signcolumn=yes

" reduce idle update time
set updatetime=400

" Enable numbering
set number

" scrolloff -- number of lines to keep above/below cursor at all times
set scrolloff=5

" set cursor line
set cursorline
hi CursorLine	cterm=NONE ctermbg=234 ctermfg=NONE

" smartcase -- treat lowercase as mixed case in searches
set smartcase
set ignorecase

" Fix vim for webpack watcher
set backupcopy=yes

" Then load in all the plugins to runtimepath
call plug#end()
filetype plugin indent on

