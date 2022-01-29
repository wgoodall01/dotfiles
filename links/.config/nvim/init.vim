let s:editor_root=expand('~/.config/nvim/')

" Stuff for Plug
set nocompatible
filetype off
call plug#begin(s:editor_root . 'plugged')

" Misc Utilities
Plug 'jiangmiao/auto-pairs'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-abolish'
Plug 'airblade/vim-gitgutter'
Plug 'ap/vim-css-color'
Plug 'godlygeek/tabular'

" Remap window movement keys
noremap <C-M-h> <C-w>h
noremap <C-M-j> <C-w>j
noremap <C-M-k> <C-w>k
noremap <C-M-l> <C-w>l

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

" Config for Pest grammars
Plug 'pest-parser/pest.vim'

" Config for most languages
Plug 'sheerun/vim-polyglot'
let g:polyglot_disabled = ['markdown', 'sh']

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

" Generate ctags automatically
Plug 'szw/vim-tags'

"fzf for opening files
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
function! s:find_git_root()
  return system('git rev-parse --show-toplevel 2> /dev/null')[:-2]
endfunction
let g:fzf_layout = { 'down': '~20%' }
command! Files call fzf#vim#files(s:find_git_root(), {'options': '--prompt " /"'})
noremap <silent> <c-p> :Files<CR>
noremap <silent> <c-l> :Tags<CR>

" Code analysis
let g:ale_lint_on_text_changed = 'never'
let g:ale_fix_on_save = 1
Plug 'dense-analysis/ale'
nnoremap gd :ALEGoToDefinition<CR>
nnoremap gu :ALEFindReferences<CR>

" Select last paste
nnoremap gp `[v`]

" Colorcolumn colors
highlight ColorColumn ctermbg=darkgray

" Completions config
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'ervandew/supertab'
let g:SuperTabDefaultCompletionType = "<c-n>"
let g:deoplete#enable_at_startup = 1
set completeopt-=preview 

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

" Clear to read errors
hi! link SpellBad Error
hi SpellCap ctermbg=BLUE gui=undercurl ctermfg=BLACK

" smartcase -- treat lowercase as mixed case in searches
set smartcase
set ignorecase

" Fix vim for webpack watcher
set backupcopy=yes

" Break lines at word boundary
set linebreak

" Then load in all the plugins to runtimepath
call plug#end()
filetype plugin indent on

