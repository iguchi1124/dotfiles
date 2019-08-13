call plug#begin('~/.vim/plugged')

Plug 'ntpeters/vim-better-whitespace'
Plug 'rking/ag.vim'
Plug 'google/vim-jsonnet'
Plug 'tomasr/molokai'
Plug 'sheerun/vim-polyglot'

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

set background=dark
colorscheme molokai

filetype plugin indent on
syntax enable
