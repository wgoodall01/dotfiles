let s:editor_root=expand('~/.config/nvim/')

" Pin the python3 provider to a mise-managed python.
"
" Left unset, nvim searches $PATH for `pynvim-python` -- but mise rewrites $PATH
" per directory, so opening a file inside a project that pins a different python
" silently leaves nvim with no python3 provider at all (which breaks Coqtail).
" Every python mise installs gets pynvim from ~/.default-python-packages, so any
" of them works as the host; we just need a choice that doesn't depend on cwd.
" Guarded by executable() so a missing host degrades to the $PATH search rather
" than erroring.
" Prefer mise's `latest` symlink, so this keeps working across python upgrades
" without editing this file; fall back to any installed version.
if !exists('g:python3_host_prog')
	let s:pynvim_host = expand('~/.local/share/mise/installs/python/latest/bin/pynvim-python')
	if !executable(s:pynvim_host)
		let s:found = glob('~/.local/share/mise/installs/python/*/bin/pynvim-python', 1, 1)
		let s:pynvim_host = empty(s:found) ? '' : s:found[-1]
	endif
	if !empty(s:pynvim_host) && executable(s:pynvim_host)
		let g:python3_host_prog = s:pynvim_host
	endif
endif

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
set noshowmode
let g:lightline = {
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ],
      \             [ 'gitbranch', 'readonly', 'filename', 'modified' ] ]
      \ },
      \ 'component_function': {
      \   'gitbranch': 'FugitiveHead'
      \ },
      \ 'colorscheme': 'wombat',
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

" Copilot
Plug 'github/copilot.vim'
let g:copilot_workspace_folders = ['~/Dev/ag/m'] " Use monorepo to inform suggestions

" Coq
Plug 'whonore/Coqtail'

" CSV view
Plug 'hat0uma/csvview.nvim'
autocmd BufRead,BufNewFile *.csv lua require('csvview').setup()
nnoremap <Leader>c :CsvViewToggle<CR>


" Code analysis
let g:ale_lint_on_text_changed = 'never'
let g:ale_fix_on_save = 1
Plug 'dense-analysis/ale'
nnoremap <Leader>d :ALEGoToDefinition<CR>
nnoremap <Leader>u :ALEFindReferences<CR>
nnoremap <Leader>r :ALERename<CR>
nnoremap <Leader>e :ALEDetail<CR>
nnoremap <Leader>h :ALEHover<CR>
nnoremap <Leader>a :ALECodeAction<CR>
xnoremap <Leader>a :ALECodeAction<CR>

" Select last paste
nnoremap gp `[v`]

" Un-screw-up colorscheme
colorscheme vim
set notermguicolors

" Completions config
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
" Plug 'ervandew/supertab'
" let g:SuperTabDefaultCompletionType = "<c-n>"
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

" breakindent: indent soft-wrapped lines
set breakindent
set breakindentopt=shift:4,sbr
set showbreak=↪


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

" Colorcolumn colors
highlight ColorColumn ctermbg=black

" Then load in all the plugins to runtimepath
call plug#end()
filetype plugin indent on

