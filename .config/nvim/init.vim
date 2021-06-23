call plug#begin('~/.local/share/nvim/plugged')

Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'sheerun/vim-polyglot'
Plug 'tomasr/molokai'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sensible'

if has('nvim')
  Plug 'autozimu/LanguageClient-neovim', {
        \ 'branch': 'next',
        \ 'do': 'bash install.sh',
        \ }

  Plug 'Shougo/echodoc.vim'
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
endif

call plug#end()

set clipboard+=unnamed
set completeopt+=menuone
set noswapfile
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

if has('nvim')
  set number

  " deoplete.nvim
  let g:deoplete#enable_at_startup = 1

  " LanguageClient-neovim
  set hidden

  let g:LanguageClient_serverCommands = {
        \ 'c': ['clangd', '-background-index'],
        \ 'cpp': ['clangd', '-background-index'],
        \ 'go': ['gopls'],
        \ 'ruby': ['solargraph', 'stdio'],
        \ 'typescript': ['typescript-language-server', '--stdio'],
        \ 'typescript.tsx': ['typescript-language-server', '--stdio'],
        \ 'typescriptreact': ['typescript-language-server', '--stdio']
        \ }

  let g:LanguageClient_diagnosticsEnable = 0

  function! s:LspConfig()
    nnoremap <leader>ld :call LanguageClient#textDocument_definition()<CR>
    nnoremap <leader>lr :call LanguageClient#textDocument_rename()<CR>
    nnoremap <leader>lf :call LanguageClient#textDocument_formatting()<CR>
    nnoremap <leader>lt :call LanguageClient#textDocument_typeDefinition()<CR>
    nnoremap <leader>lx :call LanguageClient#textDocument_references()<CR>
    nnoremap <leader>la :call LanguageClient_workspace_applyEdit()<CR>
    nnoremap <leader>lc :call LanguageClient#textDocument_completion()<CR>
    nnoremap <leader>lh :call LanguageClient#textDocument_hover()<CR>
    nnoremap <leader>ls :call LanguageClient_textDocument_documentSymbol()<CR>
    nnoremap <leader>lm :call LanguageClient_contextMenu()<CR>
  endfunction()

  augroup lsp_config
    autocmd!
    autocmd FileType c,cpp,go,ruby,typescript,typescript.tsx,typescriptreact call s:LspConfig()
  augroup END

  " echodoc.vim
  set cmdheight=2
  let g:echodoc#enable_at_startup = 1
  let g:echodoc#type = 'signature'
endif

color molokai
