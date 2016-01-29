set number
set cursorline
set laststatus=2
set cmdheight=2
set showmatch
set helpheight=999
set list
set listchars=tab:▸\ ,eol:↲,extends:❯,precedes:❮

set backspace=indent,eol,start
set whichwrap=b,s,h,l,<,>,[,]
set scrolloff=8
set sidescrolloff=16
set sidescroll=1

set confirm
set hidden
set autoread
set nobackup
set noswapfile

set hlsearch
set incsearch
set ignorecase
set smartcase
set wrapscan
set gdefault

set expandtab
set tabstop=2
set tabstop=2
set softtabstop=2
set autoindent
set smartindent

set clipboard=unnamed,unnamedplus
set mouse=a
set shellslash

set wildmenu wildmode=list:longest,full
set history=10000

set noerrorbells

imap { {}<LEFT>
imap [ []<LEFT>
imap ( ()<LEFT>

if has("autocmd")
    autocmd BufReadPost *
    \ if line("'\"") > 0 && line ("'\"") <= line("$") |
    \   exe "normal! g'\"" |
    \ endif
endif

syntax on
