call plug#begin('~/.vim/plugged')

Plug 'google/vim-searchindex'
Plug 'sheerun/vim-polyglot'
Plug 'tomasr/molokai'
Plug 'tpope/vim-sensible'

" vim-lsp
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'mattn/vim-lsp-settings'

call plug#end()

set clipboard=unnamed,unnamedplus
set completeopt=menuone
set noswapfile
set number
set scrolloff=4
set sh=zsh

let mapleader = ","

let g:lsp_diagnostics_enabled = 0
let g:lsp_document_code_action_signs_enabled = 0

function! s:LspConfig() abort
  nmap <buffer> gd <plug>(lsp-definition)
  nmap <buffer> <leader>rn <plug>(lsp-rename)
endfunction

augroup lsp_install
  au!
  autocmd User lsp_buffer_enabled call s:LspConfig()
augroup END

function! s:GitGrep(pattern) abort
  setlocal grepprg=git\ grep\ -nI
  silent exec 'grep '.a:pattern.' | cw'
  redr!
endfunction

command! -nargs=? Ggrep call s:GitGrep(<q-args>)

autocmd QuickFixCmdPost vimgrep cw

color molokai
