let NERDTreeShowHidden = 1
let file_name = expand("%:p")
if has('vim_starting') && file_name == ''
  autocmd VimEnter * execute 'NERDTree ./'
endif

nmap <silent> <C-e>      :NERDTreeToggle<CR>
vmap <silent> <C-e> <Esc>:NERDTreeToggle<CR>
omap <silent> <C-e>      :NERDTreeToggle<CR>
imap <silent> <C-e> <Esc>:NERDTreeToggle<CR>
cmap <silent> <C-e> <C-u>:NERDTreeToggle<CR>
