filetype plugin indent off

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
set shiftwidth=2
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

if has('vim_starting')
  set runtimepath+=~/.dotfiles/.vim/bundle/neobundle.vim/
endif

call neobundle#begin(expand('~/.dotfiles/.vim/bundle/'))

NeoBundleFetch 'Shougo/neobundle.vim'

NeoBundle 'altercation/vim-colors-solarized'

NeoBundle 'Shougo/unite.vim'
NeoBundle 'scrooloose/nerdtree'

NeoBundle 'vim-scripts/AnsiEsc.vim'
NeoBundle 'bronson/vim-trailing-whitespace'

NeoBundle 'mattn/emmet-vim'
NeoBundle 'othree/html5.vim'
NeoBundle 'hail2u/vim-css3-syntax'
NeoBundle 'taichouchou2/vim-javascript'
NeoBundle 'kchmck/vim-coffee-script'

NeoBundle 'vim-ruby/vim-ruby'
NeoBundle 'tpope/vim-endwise'

NeoBundle 'slim-template/vim-slim'
NeoBundle 'tpope/vim-haml'

call neobundle#end()

let NERDTreeShowHidden = 1
let file_name = expand("%:p")
if has('vim_starting') &&  file_name == ""
    autocmd VimEnter * execute 'NERDTree ./'
endif

nmap <silent> <C-e>      :NERDTreeToggle<CR>
vmap <silent> <C-e> <Esc>:NERDTreeToggle<CR>
omap <silent> <C-e>      :NERDTreeToggle<CR>
imap <silent> <C-e> <Esc>:NERDTreeToggle<CR>
cmap <silent> <C-e> <C-u>:NERDTreeToggle<CR>

let g:solarized_termcolors=256

syntax enable
set background=dark
colorscheme solarized

autocmd FileType html inoremap <silent> <buffer> </ </<C-x><C-o>

filetype plugin indent on
