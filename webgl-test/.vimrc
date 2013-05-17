set nocompatible

set rtp+=~/vimfiles/bundle/vundle/
call vundle#rc()

Bundle 'scrooloose/nerdtree'
Bundle 'gmarik/vundle'
Bundle 'kien/ctrlp.vim'
let g:ctrlp_cmd = 'CtrlPMixed'			" search anything (in files, buffers and MRU files at the same time.)
let g:ctrlp_working_path_mode = 'ra'	" search for nearest ancestor like .git, .hg, and the directory of the current file
let g:ctrlp_match_window_bottom = 0		" show the match window at the top of the screen
let g:ctrlp_max_height = 10				" maxiumum height of match window
let g:ctrlp_switch_buffer = 'et'		" jump to a file if it's open already
let g:ctrlp_use_caching = 1				" enable caching
let g:ctrlp_clear_cache_on_exit=0  		" speed up by not removing clearing cache evertime
let g:ctrlp_show_hidden = 1				" show me dotfiles
let g:ctrlp_mruf_max = 250 				" number of recently opened files


" nmap <C-r> :MyCtrlPTag<cr>
" imap <C-r> <esc>:MyCtrlPTag<cr>

func! MyPrtMappings()
    let g:ctrlp_prompt_mappings = {
        \ 'AcceptSelection("e")': ['<c-t>'],
        \ 'AcceptSelection("t")': ['<cr>', '<2-LeftMouse>'],
        \ }
endfunc

func! MyCtrlPTag()
    let g:ctrlp_prompt_mappings = {
        \ 'AcceptSelection("e")': ['<cr>', '<2-LeftMouse>'],
        \ 'AcceptSelection("t")': ['<c-t>'],
        \ }
    CtrlPBufTag
endfunc

let g:ctrlp_buffer_func = { 'exit': 'MyPrtMappings' }
com! MyCtrlPTag call MyCtrlPTag()

" TODO: add javascript and some other languages who doesn't have ctags support
" coffee: https://gist.github.com/michaelglass/5210282
" go: http://stackoverflow.com/a/8236826/462233 
" objc:  http://www.gregsexton.org/2011/04/objective-c-exuberant-ctags-regex/
" rust: https://github.com/mozilla/rust/blob/master/src/etc/ctags.rust
let g:ctrlp_buftag_types = {
\ 'go'     	   : '--language-force=go --golang-types=ftv',
\ 'coffee'     : '--language-force=coffee --coffee-types=cmfvf',
\ 'markdown'   : '--language-force=markdown --markdown-types=hik',
\ 'objc'       : '--language-force=objc --objc-types=mpci',
\ 'rc'         : '--language-force=rust --rust-types=fTm'
\ }

Bundle 'kchmck/vim-coffee-script'
Bundle 'vim-scripts/EasyGrep'
Bundle 'roman/golden-ratio'
Bundle 'Lokaltog/powerline'
set rtp+=~/.vim/bundle/powerline/powerline/bindings/vim
set encoding=utf-8
set guifont=Consolas\ for\ Powerline\ FixedD:h9
let g:Powerline_symbols="fancy"
" https://github.com/eugeneching/consolas-powerline-vim -Patched for powerline

Bundle 'xolox/vim-session'
let g:session_autosave=1
let g:session_autoload=1
let g:session_default_to_last = 1


:color monokai
:syntax on
set incsearch
set backspace=indent,eol,start
set hlsearch
set number
set guioptions-=m  "remove menu bar
set guioptions-=T  "remove toolbar
set guioptions-=R  "remove right-hand scroll bar
set guioptions-=L  "remove right-hand scroll bar
set guioptions-=r  "remove right-hand scroll bar
set guioptions-=l  "remove right-hand scroll bar


set hidden
set tabstop=2
set shiftwidth=2
set expandtab

filetype plugin indent on " Enable filetype-specific indenting and plugins
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set autoindent
set showmatch
set nowrap
set backupdir=~/tmp
set directory=~/tmp " Don't clutter my dirs up with swp and tmp files
set autoread
set laststatus=2  " Always show status line.
set relativenumber
set gdefault " assume the /g flag on :s substitutions to replace all matches in a line
set autoindent " always set autoindenting on
set scrolloff=3

let mapleader = "\<Space>"

map <C-s> <esc>:w<CR>
imap <C-s> <esc>:w<CR>

map <leader>r :source ~/.vimrc<CR>
map <leader>w <C-w>
map <leader>s <esc><esc>:w<CR>
nnoremap <leader>p :CtrlP<CR>

" To enable the saving and restoring of screen positions.
" let g:screen_size_restore_pos = 1

" To save and restore screen for each Vim instance.
" This is useful if you routinely run more than one Vim instance.
" For all Vim to use the same settings, change this to 0.
" let g:screen_size_by_vim_instance = 1

" restore window functionality

if has("gui_running")
  function! ScreenFilename()
    if has('amiga')
      return "s:.vimsize"
    elseif has('win32')
      return $HOME.'\_vimsize'
    else
      return $HOME.'/.vimsize'
    endif
  endfunction

  function! ScreenRestore()
    " Restore window size (columns and lines) and position
    " from values stored in vimsize file.
    " Must set font first so columns and lines are based on font size.
    let f = ScreenFilename()
    if has("gui_running") && g:screen_size_restore_pos && filereadable(f)
      let vim_instance = (g:screen_size_by_vim_instance==1?(v:servername):'GVIM')
      for line in readfile(f)
        let sizepos = split(line)
        if len(sizepos) == 5 && sizepos[0] == vim_instance
          silent! execute "set columns=".sizepos[1]." lines=".sizepos[2]
          silent! execute "winpos ".sizepos[3]." ".sizepos[4]
          return
        endif
      endfor
    endif
  endfunction

  function! ScreenSave()
    " Save window size and position.
    if has("gui_running") && g:screen_size_restore_pos
      let vim_instance = (g:screen_size_by_vim_instance==1?(v:servername):'GVIM')
      let data = vim_instance . ' ' . &columns . ' ' . &lines . ' ' .
            \ (getwinposx()<0?0:getwinposx()) . ' ' .
            \ (getwinposy()<0?0:getwinposy())
      let f = ScreenFilename()
      if filereadable(f)
        let lines = readfile(f)
        call filter(lines, "v:val !~ '^" . vim_instance . "\\>'")
        call add(lines, data)
      else
        let lines = [data]
      endif
      call writefile(lines, f)
    endif
  endfunction

  if !exists('g:screen_size_restore_pos')
    let g:screen_size_restore_pos = 1
  endif
  if !exists('g:screen_size_by_vim_instance')
    let g:screen_size_by_vim_instance = 1
  endif
  autocmd VimEnter * if g:screen_size_restore_pos == 1 | call ScreenRestore() | endif
  autocmd VimLeavePre * if g:screen_size_restore_pos == 1 | call ScreenSave() | endif
endif

