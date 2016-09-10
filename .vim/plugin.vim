set runtimepath+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'
Plugin 'w0ng/vim-hybrid'
Plugin 'Shougo/unite.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'vim-scripts/AnsiEsc.vim'
Plugin 'bronson/vim-trailing-whitespace'
Plugin 'mattn/emmet-vim'
Plugin 'othree/html5.vim'
Plugin 'hail2u/vim-css3-syntax'
Plugin 'pangloss/vim-javascript'
Plugin 'kchmck/vim-coffee-script'
Plugin 'leafgarland/typescript-vim'
Plugin 'tpope/vim-endwise'
Plugin 'slim-template/vim-slim'
Plugin 'tpope/vim-haml'
Plugin 'fatih/vim-go'
Plugin 'hdima/python-syntax'
Plugin 'andviro/flake8-vim'
Plugin 'hynek/vim-python-pep8-indent'
call vundle#end()

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
