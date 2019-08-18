call plug#begin('~/.vim/plugged')

Plug 'ntpeters/vim-better-whitespace'
Plug 'tomasr/molokai'
Plug 'tpope/vim-sensible'

call plug#end()

set clipboard+=unnamed
set noswapfile
set number

color molokai

if filereadable("$HOME/.vimrc_local")
  source $HOME/.vimrc_local
endif
