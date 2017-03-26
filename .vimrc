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

filetype plugin indent on
syntax enable

if dein#check_install()
  call dein#install()
endif
