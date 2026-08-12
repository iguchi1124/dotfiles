call plug#begin(expand('~/.vim/plugged'))

Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-sensible'

" vim-lsp
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'mattn/vim-lsp-settings'

call plug#end()

set clipboard=unnamed,unnamedplus
set completeopt=menuone,noselect
set number
set scrolloff=4
set sh=zsh
set undofile

let mapleader = ","

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
  set grepformat=%f:%l:%m
  silent exec 'grep '.a:pattern.' | cw'
  redr!
endfunction

command! -nargs=? Ggrep call s:GitGrep(<q-args>)

function! s:Rg(pattern) abort
  setlocal grepprg=rg\ --vimgrep\ --hidden\ --glob=!.git
  set grepformat=%f:%l:%c:%m
  silent exec 'grep '.a:pattern.' | cw'
  redr!
endfunction

command! -nargs=? Rg call s:Rg(<q-args>)

color sorbet
