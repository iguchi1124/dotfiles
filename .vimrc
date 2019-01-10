if &compatible
  set nocompatible
endif

call plug#begin('~/.vim/plugged')

Plug 'ntpeters/vim-better-whitespace'
Plug 'fatih/vim-go'
Plug 'kchmck/vim-coffee-script'
Plug 'rking/ag.vim'
Plug 'elixir-editors/vim-elixir'
Plug 'leafgarland/typescript-vim'
Plug 'posva/vim-vue'
Plug 'dart-lang/dart-vim-plugin'
Plug 'google/vim-jsonnet'
Plug 'tomasr/molokai'
Plug 'pangloss/vim-javascript'

call plug#end()

set backspace=indent,eol,start
set cursorline
set expandtab
set hlsearch
set noswapfile
set nowrap
set number
set pastetoggle=<C-G>
set shiftwidth=2
set showmode
set softtabstop=2
set tabstop=4

autocmd QuickFixCmdPost *grep* cwindow

function s:CreateMissingDirectories()
  let dir = expand("<afile>:p:h:")
  if !isdirectory(dir) && confirm("Create a new directory [".dir."]?", "&Yes\n&No") == 1
    call mkdir(dir, "p")
    file %
  endif
endfunction

augroup create_missing_directories
  autocmd!
  autocmd BufNewFile * call s:CreateMissingDirectories()
augroup END

set background=dark
colorscheme molokai

filetype plugin indent on
syntax enable
