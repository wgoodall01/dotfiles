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
augroup t11e_homeland_no_homeland
	autocmd!
	autocmd BufNewFile,BufRead */t11e/homeland/* let g:neoformat_on_save = 0
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
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
function! s:find_git_root()
  return system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
endfunction
let $FZF_DEFAULT_COMMAND='ag --hidden -g ""'
let $FZF_DEFAULT_OPTS='--inline-info'
let g:fzf_layout = { 'down': '~20%' }
command! Files call fzf#vim#files(s:find_git_root(), {'options': '--prompt " /"'})
noremap <silent> <c-p> :Files<CR>
noremap <silent> <c-l> :Commands<CR>

" Completions config
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-go', { 'do': 'make', 'for':'go' }
Plug 'zchee/deoplete-jedi', {'for':'python'}
Plug 'tweekmonster/deoplete-clang2', {'for':'cpp'}
let g:deoplete#enable_at_startup = 1
set completeopt-=preview
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

" Java autocomplete config
Plug 'artur-shaik/vim-javacomplete2', {'for':'java'}
autocmd FileType java let g:deoplete#auto_complete_delay=1000
autocmd FileType java setlocal omnifunc=javacomplete#Complete

" Set tabs as \t and 4 spaces wide
set tabstop=4
set softtabstop=0 noexpandtab
set shiftwidth=4

" For makefiles, force indenting with tabs
autocmd FileType make set noexpandtab shiftwidth=4 softtabstop=0

" For YAML, use 2-space indents
autocmd FileType yaml setlocal ts=2 sts=2 sw=2 expandtab

" TTY config
set ttyfast
set mouse=a

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

