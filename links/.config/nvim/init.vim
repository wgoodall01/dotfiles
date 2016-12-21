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
  call system('xclip -i -selection clipboard', @@)
endfunction
function! ClipboardPaste()
  let @@ = system('xclip -o -selection clipboard')
endfunction

vnoremap <silent> y y:call ClipboardYank()<cr>
vnoremap <silent> d d:call ClipboardYank()<cr>
nnoremap <silent> p :call ClipboardPaste()<cr>p
