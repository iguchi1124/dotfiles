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
set shellslash
set wildmenu wildmode=list:longest,full
set history=10000
set noerrorbells

" save last cursor position
autocmd BufReadPost * if line("'\"") > 0 && line ("'\"") <= line("$") | exe "normal! g'\"" | endif

" automatic closing parenthesis
inoremap { {}<LEFT>
inoremap ( ()<LEFT>

set runtimepath+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'

" color scheme
Plugin 'w0ng/vim-hybrid'

Plugin 'Shougo/unite.vim'
Plugin 'scrooloose/nerdtree'

Plugin 'vim-scripts/AnsiEsc.vim'
Plugin 'bronson/vim-trailing-whitespace'

" html/css/js
Plugin 'mattn/emmet-vim'
Plugin 'othree/html5.vim'
Plugin 'hail2u/vim-css3-syntax'
Plugin 'pangloss/vim-javascript'
Plugin 'kchmck/vim-coffee-script'

" typescript
Plugin 'leafgarland/typescript-vim'

" ruby
Plugin 'vim-ruby/vim-ruby'
Plugin 'tpope/vim-endwise'

" ruby template engine
Plugin 'slim-template/vim-slim'
Plugin 'tpope/vim-haml'

" go
Plugin 'fatih/vim-go'

" python
Plugin 'hdima/python-syntax'
Plugin 'andviro/flake8-vim'
Plugin 'hynek/vim-python-pep8-indent'

call vundle#end()

" nerdtree
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

" syntax highlighter
syntax on

set background=dark
colorscheme hybrid

" automatic closing html tags
autocmd FileType html inoremap <silent> <buffer> </ </<C-x><C-o>

" *.tsx same as a typescript files
autocmd BufNewFile,BufRead *.{ts,tsx} set filetype=typescript

filetype plugin indent on

