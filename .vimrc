call plug#begin('~/.vim/plugged')

Plug 'google/vim-jsonnet'
Plug 'ntpeters/vim-better-whitespace'
Plug 'rking/ag.vim'
Plug 'scrooloose/nerdtree'
Plug 'sheerun/vim-polyglot'
Plug 'tomasr/molokai'

call plug#end()

set backspace=indent,eol,start
set cursorline
set encoding=utf-8
set expandtab
set hlsearch
set laststatus=2
set noswapfile
set nowrap
set number
set pastetoggle=<C-G>
set shiftwidth=2
set showmode
set softtabstop=2
set tabstop=4

autocmd QuickFixCmdPost *grep* cwindow
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

let NERDTreeShowHidden=1

map <C-e> :NERDTreeToggle<CR>

filetype plugin indent on

syntax on
color molokai
