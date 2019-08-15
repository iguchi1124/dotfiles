call plug#begin('~/.vim/plugged')

Plug 'google/vim-jsonnet'
Plug 'ntpeters/vim-better-whitespace'
Plug 'rking/ag.vim'
Plug 'sheerun/vim-polyglot'
Plug 'tomasr/molokai'
Plug 'Shougo/neomru.vim'
Plug 'Shougo/unite.vim'

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

filetype plugin indent on

nnoremap <silent> ,ub :<C-u>Unite buffer<CR>
nnoremap <silent> ,uf :<C-u>UniteWithBufferDir -buffer-name=files file<CR>
nnoremap <silent> ,ur :<C-u>Unite -buffer-name=register register<CR>
nnoremap <silent> ,um :<C-u>Unite file_mru<CR>
nnoremap <silent> ,uu :<C-u>Unite buffer file_mru<CR>
nnoremap <silent> ,ua :<C-u>UniteWithBufferDir -buffer-name=files buffer file_mru bookmark file<CR>

au FileType unite nnoremap <silent> <buffer> <expr> <C-j> unite#do_action('split')
au FileType unite inoremap <silent> <buffer> <expr> <C-j> unite#do_action('split')
au FileType unite nnoremap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')
au FileType unite inoremap <silent> <buffer> <expr> <C-l> unite#do_action('vsplit')

syntax on
color molokai
