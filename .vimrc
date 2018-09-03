if &compatible
  set nocompatible
endif

let s:dein = expand('~/.cache/dein')
let s:config = expand('~/.vim')

execute 'set runtimepath^=' . fnamemodify(s:dein . '/repos/github.com/Shougo/dein.vim', ':p')

if dein#load_state(s:dein)
  call dein#begin(s:dein)
  call dein#load_toml(s:config . '/dein.toml')
  call dein#end()
  call dein#save_state()
endif

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

function s:createMissingDirectory()
  let dir = expand("<afile>:p:h:")
  if !isdirectory(dir) && confirm("Create a new directory [".dir."]?", "&Yes\n&No") == 1
    call mkdir(dir, "p")
    file %
  endif
endfunction

augroup create-missing-directory
  autocmd!
  autocmd BufNewFile * call s:createMissingDirectory()
augroup END

set background=dark
colorscheme molokai

filetype plugin indent on
syntax enable

if dein#check_install()
  call dein#install()
endif
