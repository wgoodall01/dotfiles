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

" JS config
let g:node_host_prog = '/home/wgoodall01/.asdf/installs/nodejs/11.10.0/.npm/bin/neovim-node-host'
Plug 'pangloss/vim-javascript', {'for': ['javascript', 'javascript.jsx']}
Plug 'mxw/vim-jsx', {'for': ['javascript', 'javascript.jsx']}
Plug 'digitaltoad/vim-pug'
Plug 'ternjs/tern_for_vim', { 'do': 'yarn' }
let g:javascript_plugin_jsdoc = 1
let g:jsx_ext_required = 0
let g:tern#command = ["tern"]
let g:tern#arguments = ["--persistent"]
let g:tern#filetypes = [
			\ 'jsx',
			\ 'js',
			\ 'es6',
			\ ]
autocmd FileType javascript nnoremap <silent> <buffer> gb :TernDef<CR>
autocmd FileType javascript setlocal tabstop=2 expandtab shiftwidth=2 softtabstop=2
autocmd FileType css setlocal tabstop=2 expandtab shiftwidth=2 softtabstop=2

" Typescript config
Plug 'HerringtonDarkholme/yats.vim'
Plug 'leafgarland/typescript-vim'
Plug 'peitalin/vim-jsx-typescript'


" Neoformat - format on save, should use prettier for most things.
Plug 'sbdchd/neoformat'
let g:neoformat_javascript_prettier = {
			\'args': ['--parser babylon', '--single-quote', '--print-width 100', '--bracket-spacing false'],
			\'exe': 'prettier',
			\ }

let g:neoformat_css_prettier = {
			\'args': ['--parser css', '--single-quote', '--print-width 100', '--bracket-spacing false'],
			\'exe': 'prettier',
			\ }

let g:neoformat_scss_prettier = {
			\'args': ['--parser css', '--single-quote', '--print-width 100', '--bracket-spacing false'],
			\'exe': 'prettier',
			\ }

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

" Airline config
Plug 'vim-airline/vim-airline'
let g:airline_powerline_fonts=1

" Ctrlp - fast file seracher
Plug 'ctrlpvim/ctrlp.vim'
let g:ctrlp_show_hidden = 1
let g:ctrlp_custom_ignore = '\v[\/](node_modules|.next|target|dist|build|CMakeFiles)|(\.(swp|ico|git|svn|DS_Store))$'

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

