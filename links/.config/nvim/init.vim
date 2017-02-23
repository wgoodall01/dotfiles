let s:editor_root=expand('~/.config/nvim/')

" Stuff for Plug
set nocompatible
filetype off
call plug#begin(s:editor_root . 'plugged')

" Vundle plugins
Plug 'VundleVim/Vundle.vim'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'carlitux/deoplete-ternjs', { 'do': 'npm install -g tern' }
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'digitaltoad/vim-pug'
Plug 'jiangmiao/auto-pairs'
Plug 'fatih/vim-go'
Plug 'zchee/deoplete-go', { 'do': 'make' }

call plug#end()
filetype plugin indent on

" Airline config
let g:airline_powerline_fonts=1

" Set crtlp to find dotfiles
let g:ctrlp_show_hidden = 1
let g:ctrlp_custom_ignore = '\v[\/](node_modules|target|dist)|(\.(swp|ico|git|svn|DS_Store))$'

" Enable deoplete
let g:deoplete#enable_at_startup = 1

" Tern stuff
let g:tern#filetypes = [
                \ 'jsx',
                \ 'js',
                \ 'es6',
                \ ]

" Set tabs as \t and 4 spaces wide
set tabstop=4
set softtabstop=0 noexpandtab
set shiftwidth=4

" Enable numbering
set relativenumber number
autocmd InsertEnter * :set norelativenumber
autocmd InsertLeave * :set   relativenumber 

" Fix vim for webpack watcher
set backupcopy=yes

" X clipboard yank/paste
function! ClipboardYank()
  call system('pbcopy', @@)
endfunction
function! ClipboardPaste()
  let @@ = system('pbpaste')
endfunction

vnoremap <silent> y y:call ClipboardYank()<cr>
vnoremap <silent> d d:call ClipboardYank()<cr>
nnoremap <silent> p :call ClipboardPaste()<cr>p
