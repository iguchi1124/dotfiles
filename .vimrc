call plug#begin('~/.vim/plugged')

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
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

" fzf.vim
function! s:FzfGitRoot()
  let root = split(system('git rev-parse --show-toplevel'), '\n')[0]
  return v:shell_error ? '' : root
endfunction

function! s:FzfWarn(message)
  echohl WarningMsg
  echom a:message
  echohl None
  return 0
endfunction

function! s:FzfGitGrep(pattern, bang)
  let root = s:FzfGitRoot()
  if empty(root)
    return s:FzfWarn('Not in git repo')
  endif

  call fzf#vim#grep(
        \ 'git grep --line-number -- '.shellescape(a:pattern), 0,
        \ fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), a:bang)
endfunction

command! -bang -nargs=* GGrep call s:FzfGitGrep(<q-args>, <bang>0)

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
