call plug#begin('~/.vim/plugged')

Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-sensible'

" vim-lsp
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'mattn/vim-lsp-settings'

call plug#end()

set clipboard+=unnamed
set completeopt+=menuone
set noswapfile
set number
set sh=zsh

let mapleader = ","

" vim-lsp
let g:lsp_diagnostics_enabled = 0
let g:lsp_document_code_action_signs_enabled = 0

function! s:LspConfig() abort
  nmap <buffer> <leader>ld <plug>(lsp-definition)
  nmap <buffer> <leader>lr <plug>(lsp-rename)
  nmap <buffer> <leader>lf <plug>(lsp-document-format)
endfunction

augroup lsp_install
  au!
  autocmd User lsp_buffer_enabled call s:LspConfig()
augroup END
