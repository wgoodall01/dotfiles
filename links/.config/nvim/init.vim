let s:editor_root=expand('~/.config/nvim/')

" Stuff for Vundle
set nocompatible
filetype off
set rtp+=~/.config/nvim/bundle/Vundle.vim
call vundle#begin(s:editor_root . '/bundle')

" Vundle plugins
Plugin 'VundleVim/Vundle.vim'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'git://github.com/tpope/vim-fugitive.git'
Plugin 'vim-airline/vim-airline'

call vundle#end()
filetype plugin indent on

" Airline config
let g:airline_powerline_fonts=1

" Set crtlp to find dotfiles
let g:ctrlp_show_hidden = 1
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git'

" Set tabs as \t and 4 spaces wide
set tabstop=4
set softtabstop=0 noexpandtab
set shiftwidth=4

" Enable numbering
set relativenumber number
autocmd InsertEnter * :set norelativenumber
autocmd InsertLeave * :set   relativenumber 


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
