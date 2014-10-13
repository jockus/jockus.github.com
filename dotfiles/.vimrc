set nocompatible
let mapleader = ","

" Function to extract just the changelist number from a copied CL
function! ExtractChangelist()
  normal omsk"*pjV'sxkd2wkdd
endfunction
"nnoremap <leader>c :call ExtractChangelist()<CR>

" C++ quick compile
nnoremap <leader>b :!"C:/Program Files (x87)/mingw-w64/i686-4.9.1-posix-dwarf-rt_v3-rev0/mingw32/bin/g++" -o %:r.exe %

" Diary entry
nnoremap <leader>da `Do<C-R>=strftime("#%d/%m/%y:")<CR>o<CR>kI

" Checkout current
nnoremap <F12> :!p4 edit %<CR><CR>

" Scratch
nnoremap <F8> :Scratch<CR>
nnoremap <leader>8 :Scratch<CR>ggVGd"*p

" Handy shortcuts
nnoremap <F1> :Ex D:\perforce\joakim.hentula_UK12892\rp7_audio<CR>
nnoremap <F2> :Ex D:\perforce\joakim.hentula_UK12892\rp8_code\mainline<CR>

" Jump to position of mark by default
nnoremap ' `
nnoremap ` '

nnoremap <space> :

map <C-s> <esc>:w<CR>
imap <C-s> <esc>:w<CR>
map s <esc>:w<CR>

nnoremap <C-k> :bn<CR>
nnoremap <C-j> :bp<CR>

nnoremap <esc> :noh<return><esc>

set rtp+=~/vimfiles/bundle/vundle/
call vundle#rc()

Bundle 'gmarik/vundle'
Bundle 'kien/ctrlp.vim'
Bundle 'duff/vim-scratch'
Bundle 'octol/vim-cpp-enhanced-highlight'
let g:airline#extensions#tabline#enabled = 1
Bundle 'bling/vim-airline'
Bundle 'bling/vim-bufferline'
Bundle 'xolox/vim-session'
let g:session_autosave=1
let g:session_autoload=1
let g:session_default_to_last = 1

let g:ctrlp_cmd = 'CtrlPMixed'			" search anything (in files, buffers and MRU files at the same time.)
let g:ctrlp_working_path_mode = 'raw'	" search for nearest ancestor like .git, .hg, and the directory of the current file
let g:ctrlp_match_window_bottom = 1
let g:ctrlp_max_height = 10				" maxiumum height of match window
let g:ctrlp_switch_buffer = 'et'		" jump to a file if it's open already
let g:ctrlp_use_caching = 1
let g:ctrlp_clear_cache_on_exit=0
let g:ctrlp_show_hidden = 1
let g:ctrlp_mruf_max = 250

set encoding=utf-8
set guifont=Consolas:h10


colorscheme desert
syntax on
set incsearch
set backspace=indent,eol,start
set hlsearch
set number
set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=R  "remove scroll bar
set guioptions-=L  "remove scroll bar
set guioptions-=r  "remove scroll bar
set guioptions-=l  "remove scroll bar

" Yank and paste to clipboard by default
let &clipboard = has('unnamedplus') ? 'unnamedplus' : 'unnamed'

set hidden
set tabstop=4
set shiftwidth=4
set expandtab
set smartindent
set noswapfile

filetype plugin indent on
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set autoindent
set showmatch
set nowrap
set backupdir=~/tmp
set directory=~/tmp 
set autoread
set laststatus=2  " Always show status line.
" set relativenumber
set gdefault " assume the /g flag on :s substitutions to replace all matches in a line
set scrolloff=3
