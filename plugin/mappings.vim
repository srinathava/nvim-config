" echo the highlight group currently under cursor. (from vim.source...)
map  <F6>  :echo 'hi<' .synIDattr(synID(line("."),col("."),1),"name") .'>'<cr>
" source the selected text in vim (really useful)
" mnemonic: r for run
vmap <c-r> "ny:exec @n<cr>:<bs>
" make shift-down/up move only one line in visual mode.
vmap <s-down> <down>
vmap <s-up> <up>
" always want to go the character visually above the current character
" not the character in the previous _line_ (helpful when wrap on and 
" long lines exist) (taken from tips at vim.sourceforge.net)
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gk
nnoremap $ g$
nnoremap <Down> gj
nnoremap <Up> gk
vnoremap <Down> gj
vnoremap <Up> gk
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk
inoremap <C-l> <C-o>l
" the standard windows way of selecting the whole file 
" restores the original position. ofcourse this screws the 
" normal mode mapping which icrements the number under the cursor.
nnoremap <c-a> maggVGy`a

" a natural extension of the ctrl-a function to visual-block mode.
vnoremap <c-a> <c-v>:Inc 1<cr>

inoremap <C-j> <down>
inoremap <C-k> <up>
inoremap <C-l> <right>
inoremap <C-h> <left>
inoremap <C-o> <C-o>o

inoremap <C-q> <C-k>

tnoremap <C-w> <C-\><C-N><C-w>
augroup EnterTermMode
    au!
    autocmd BufWinEnter,WinEnter term://* startinsert
    autocmd BufWinLeave,WinLeave term://* stopinsert
    autocmd TermOpen * startinsert
augroup END

nnoremap <tab> za

" A neat trick to make n always search forward irrespective of whether the
" search was done using a / or a ?
noremap <expr> n 'Nn'[v:searchforward]
noremap <expr> N 'nN'[v:searchforward]
