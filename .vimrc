call plug#begin('~/.vim/plugged')

Plug 'ntpeters/vim-better-whitespace'
Plug 'rking/ag.vim'
Plug 'tomasr/molokai'
Plug 'tpope/vim-sensible'

call plug#end()

set clipboard+=unnamed
set noswapfile
set number

autocmd QuickFixCmdPost *grep* cwindow

filetype plugin indent on

syntax on
color molokai

if filereadable("$HOME/.vimrc_local")
  source $HOME/.vimrc_local
endif
