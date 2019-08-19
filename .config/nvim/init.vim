call plug#begin('~/.local/share/nvim/plugged')

Plug 'ntpeters/vim-better-whitespace'
Plug 'rking/ag.vim'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/asyncomplete-buffer.vim'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'prabirshrestha/asyncomplete-neosnippet.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'sheerun/vim-polyglot'
Plug 'Shougo/denite.nvim'
Plug 'Shougo/defx.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'Shougo/neomru.vim'
Plug 'Shougo/neosnippet.vim'
Plug 'Shougo/neoyank.vim'
Plug 'thomasfaingnaert/vim-lsp-snippets'
Plug 'thomasfaingnaert/vim-lsp-neosnippet'
Plug 'tomasr/molokai'
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

call plug#end()

set clipboard+=unnamed
set noswapfile
set number

" neosnippet
imap <C-k> <Plug>(neosnippet_expand_or_jump)
smap <C-k> <Plug>(neosnippet_expand_or_jump)
xmap <C-k> <Plug>(neosnippet_expand_target)

" asyncomplete
call asyncomplete#register_source(asyncomplete#sources#buffer#get_source_options({
  \ 'name': 'buffer',
  \ 'whitelist': ['*'],
  \ 'completor': function('asyncomplete#sources#buffer#completor'),
  \ 'config': {
  \    'max_buffer_size': 5000000,
  \  },
  \ }))

call asyncomplete#register_source(asyncomplete#sources#neosnippet#get_source_options({
  \ 'name': 'neosnippet',
  \ 'whitelist': ['*'],
  \ 'completor': function('asyncomplete#sources#neosnippet#completor'),
  \ }))

" denite
nmap <silent> <C-u><C-t> :<C-u>Denite filetype<CR>
nmap <silent> <C-u><C-f> :<C-u>Denite file/rec<CR>
nmap <silent> <C-u><C-j> :<C-u>Denite line<CR>
nmap <silent> <C-u><C-g> :<C-u>Denite grep<CR>
nmap <silent> <C-u><C-]> :<C-u>DeniteCursorWord grep<CR>
nmap <silent> <C-u><C-u> :<C-u>Denite file_mru<CR>
nmap <silent> <C-u><C-y> :<C-u>Denite neoyank<CR>
nmap <silent> <C-u><C-r> :<C-u>Denite -resume<CR>

autocmd FileType denite call s:denite_my_settings()
function! s:denite_my_settings() abort
  nnoremap <silent><buffer><expr> <CR> denite#do_map('do_action')
  nnoremap <silent><buffer><expr> d denite#do_map('do_action', 'delete')
  nnoremap <silent><buffer><expr> p denite#do_map('do_action', 'preview')
  nnoremap <silent><buffer><expr> q denite#do_map('quit')
  nnoremap <silent><buffer><expr> i denite#do_map('open_filter_buffer')
  nnoremap <silent><buffer><expr> <Space> denite#do_map('toggle_select').'j'
endfunction

autocmd FileType denite-filter call s:denite_filter_my_settings()
function! s:denite_filter_my_settings() abort
  imap <silent><buffer> <C-o> <Plug>(denite_filter_quit)
endfunction

call denite#custom#kind('file', 'default_action', 'split')

call denite#custom#var('file/rec', 'command', ['ag', '--follow', '--nocolor', '--nogroup', '-g', ''])

call denite#custom#var('grep', 'command', ['ag'])
call denite#custom#var('grep', 'default_opts', ['-i', '--vimgrep'])
call denite#custom#var('grep', 'recursive_opts', [])
call denite#custom#var('grep', 'pattern_opt', [])
call denite#custom#var('grep', 'separator', ['--'])
call denite#custom#var('grep', 'final_opts', [])

" defx
autocmd FileType defx call s:defx_my_settings()
function! s:defx_my_settings() abort
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
nnoremap <Leader>- :Defx -split=vertical -winwidth=35 -direction=topleft<CR>

" airline
let g:airline_powerline_fonts = 1
let g:airline_theme='simple'

" vim-lsp
if executable('solargraph')
  " gem install solargraph
  au User lsp_setup call lsp#register_server({
    \ 'name': 'solargraph',
    \ 'cmd': {server_info->[&shell, &shellcmdflag, 'solargraph stdio']},
    \ 'initialization_options': {"diagnostics": "true"},
    \ 'whitelist': ['ruby'],
    \ })
endif

if executable('gopls')
  au User lsp_setup call lsp#register_server({
    \ 'name': 'gopls',
    \ 'cmd': {server_info->['gopls', '-mode', 'stdio']},
    \ 'whitelist': ['go'],
    \ })
  autocmd BufWritePre *.go silent LspDocumentFormatSync
endif

color molokai
