let s:editor_root=expand('~/.config/nvim/')

" Stuff for Plug
set nocompatible
filetype off
call plug#begin(s:editor_root . 'plugged')

" Utilities
Plug 'ctrlpvim/ctrlp.vim'
Plug 'jiangmiao/auto-pairs'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'editorconfig/editorconfig-vim'

" Autocomplete 
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'zchee/deoplete-go', { 'do': 'make' }
Plug 'ternjs/tern_for_vim', { 'do': 'yarn' }
Plug 'zchee/deoplete-jedi'
Plug 'artur-shaik/vim-javacomplete2'

" Language support
Plug 'digitaltoad/vim-pug'
Plug 'fatih/vim-go'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'

call plug#end()
filetype plugin indent on

" Editorconfig config
let g:EditorConfig_exclude_patterns = ['fugitive://.*']

" JS config
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

" Java config
autocmd FileType java setlocal omnifunc=javacomplete#Complete

" Airline config
let g:airline_powerline_fonts=1

" Set crtlp to find dotfiles
let g:ctrlp_show_hidden = 1
let g:ctrlp_custom_ignore = '\v[\/](node_modules|target|dist)|(\.(swp|ico|git|svn|DS_Store))$'

" Completions config
let g:deoplete#enable_at_startup = 1
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

" Set tabs as \t and 4 spaces wide
set tabstop=4
set softtabstop=0 noexpandtab
set shiftwidth=4

" TTY config
set ttyfast
set mouse=a

" Enable numbering
set number

" Fix vim for webpack watcher
set backupcopy=yes
