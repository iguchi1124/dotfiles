call plug#begin('~/.vim/plugged')

Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'sheerun/vim-polyglot'
Plug 'tomasr/molokai'
Plug 'tpope/vim-fugitive'
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

" lightline.vim
let g:lightline = {
      \   'active': {
      \     'left': [
      \       [ 'mode', 'paste' ],
      \       [ 'gitbranch', 'readonly', 'filename', 'modified' ]
      \     ]
      \   },
      \   'component_function': {
      \     'gitbranch': 'fugitive#head'
      \   },
      \ }

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

nmap <silent> <leader>ld <plug>(lsp-definition)
nmap <silent> <leader>lf <plug>(lsp-document-format)

color molokai
