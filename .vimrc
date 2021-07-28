if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" ===== plugins list =====
call plug#begin('~/.vim/plugged')

Plug 'sheerun/vim-polyglot'
Plug 'greflm13/monokai-vibrant'
Plug 'itchyny/lightline.vim'

call plug#end()

" ===== vim builtin config =====
syntax enable
set termguicolors
set showtabline=2
set laststatus=2
set number
set noshowmode

" ===== colorscheme config =====
colorscheme monokai_vibrant

" ===== lightline config =====
let g:lightline = {
    \ 'colorscheme': 'monokai_vibrant',
    \ 'active': {
    \ 'left': [ ['mode'], ['filename'] ],
    \ 'right': [ ['filetype'] ]},
    \ 'inactive': {
    \ 'left': [ ['filename'] ],
    \ 'right': [] }
    \ }
let g:lightline.tab = {
 \ 'active' : [ 'filename', 'modified' ],
 \ 'inactive' : [ 'filename', 'modified' ] }
