call plug#begin('~/.local/share/nvim/plugged')

Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' } | Plug 'junegunn/fzf.vim'
Plug 'ntpeters/vim-better-whitespace'
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
  Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
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
function! s:fzf_git_root()
  let root = split(system('git rev-parse --show-toplevel'), '\n')[0]
  return v:shell_error ? '' : root
endfunction

function! s:fzf_warn(message)
  echohl WarningMsg
  echom a:message
  echohl None
  return 0
endfunction

function! s:fzf_git_grep(pattern, bang)
  let root = s:fzf_git_root()
  if empty(root)
    return s:fzf_warn('Not in git repo')
  endif

  call fzf#vim#grep(
        \ 'git grep --line-number -- '.shellescape(a:pattern), 0,
        \ fzf#vim#with_preview({'dir': systemlist('git rev-parse --show-toplevel')[0]}), a:bang)
endfunction

command! -bang -nargs=* GGrep call s:fzf_git_grep(<q-args>, <bang>0)

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

  function SetLSPShortcuts()
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

  augroup LSP
    autocmd!
    autocmd FileType c,cpp,go,ruby,typescript,typescript.tsx,typescriptreact call SetLSPShortcuts()
  augroup END

  " defx.nvim
  autocmd FileType defx call s:defx_my_settings()
  function! s:defx_my_settings() abort
    setlocal nonumber
    nnoremap <silent><buffer><expr> <CR> defx#do_action('open', 'wincmd w \| drop')
    nnoremap <silent><buffer><expr> c defx#do_action('copy')
    nnoremap <silent><buffer><expr> m defx#do_action('move')
    nnoremap <silent><buffer><expr> p defx#do_action('paste')
    nnoremap <silent><buffer><expr> l defx#do_action('open', 'wincmd w \| drop')
    nnoremap <silent><buffer><expr> o defx#do_action('open_or_close_tree')
    nnoremap <silent><buffer><expr> K defx#do_action('new_directory')
    nnoremap <silent><buffer><expr> N defx#do_action('new_file')
    nnoremap <silent><buffer><expr> M defx#do_action('new_multiple_files')
    nnoremap <silent><buffer><expr> C defx#do_action('toggle_columns', 'mark:indent:icon:filename:type:size:time')
    nnoremap <silent><buffer><expr> S defx#do_action('toggle_sort', 'time')
    nnoremap <silent><buffer><expr> d defx#do_action('remove')
    nnoremap <silent><buffer><expr> r defx#do_action('rename')
    nnoremap <silent><buffer><expr> ! defx#do_action('execute_command')
    nnoremap <silent><buffer><expr> x defx#do_action('execute_system')
    nnoremap <silent><buffer><expr> yy defx#do_action('yank_path')
    nnoremap <silent><buffer><expr> . defx#do_action('toggle_ignored_files')
    nnoremap <silent><buffer><expr> ; defx#do_action('repeat')
    nnoremap <silent><buffer><expr> h defx#do_action('cd', ['..'])
    nnoremap <silent><buffer><expr> ~ defx#do_action('cd')
    nnoremap <silent><buffer><expr> q defx#do_action('quit')
    nnoremap <silent><buffer><expr> j line('.') == line('$') ? 'gg' : 'j'
    nnoremap <silent><buffer><expr> k line('.') == 1 ? 'G' : 'k'
    nnoremap <silent><buffer><expr> <C-l> defx#do_action('redraw')
    nnoremap <silent><buffer><expr> <C-g> defx#do_action('print')
    nnoremap <silent><buffer><expr> cd defx#do_action('change_vim_cwd')
  endfunction

  nnoremap <silent>- :Defx `expand('%:p:h')` -show-ignored-files -search=`expand('%:p')`<CR>
  nnoremap <leader>- :Defx -show-ignored-files -split=vertical -winwidth=35 -direction=topleft<CR>

  " echodoc.vim
  set cmdheight=2
  let g:echodoc#enable_at_startup = 1
  let g:echodoc#type = 'signature'
endif

color molokai
