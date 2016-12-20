" Set tabs as \t and 4 spaces wide
set tabstop=4
set softtabstop=0 noexpandtab
set shiftwidth=4

" Enable numbering
set relativenumber number
autocmd InsertEnter * :set norelativenumber
autocmd InsertLeave * :set   relativenumber 
