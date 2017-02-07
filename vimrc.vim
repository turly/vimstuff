"turly's minimal-ish vimrc
"Cobbled together from various sources since 2001 !
"
set nocompatible

" See https://github.com/VundleVim/Vundle.vim
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim' " let Vundle manage Vundle, required

Plugin 'Tagbar'
nmap <F8> :TagbarToggle<CR>

Plugin 'itchyny/lightline.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal

set encoding=utf-8    " Needed for patched powerline fonts (internal to vim I think)
let mapleader = ","
set background=dark
if has("gui_running")
    set guioptions-=T           " no clunky toolbar (bozo icons)
    set guioptions+=c           " no Windows dialogs
    " This will stop at the first fontname that exists.
    set guifont=Anonymous\ Pro\ for\ Powerline\ 11,Anonymice_Powerline:h11
    set lines=42
    set columns=100
    "set number
    "set ruler
    set cursorline
else
    set ttyfast                 "tf:    improves redrawing for newer computers
    set t_Co=256                " This is may or may not needed.
    "set mouse=a                " Enabling this allows mouse-clicks BUT NOT PASTING
    let &runtimepath.=',~/vimfiles'     " get .../colors and .../after here
endif

colorscheme bluish

set laststatus=2
let g:lightline = {
      \ 'component': {
      \   'readonly': '%{&readonly?"\ue0a2":""}',
      \ },
      \ 'separator': { 'left': "\ue0b0", 'right': "\ue0b2" },
      \ 'subseparator': { 'left': "\ue0b1", 'right': "\ue0b3" }
      \ }

" Prefer LF line endings
set fileformat=unix
set fileformats=unix,dos

let c_gnu=1
let c_ansi_typedefs=1
let c_comment_strings=1
let c_no_if0_fold=1     " bug? in syntax/c.vim causes problems if '#endif' for '#if 0' is not on column zero 

syntax on
"We don't want the syntax menu, just say we've already installed it.
"let did_install_syntax_menu=1  " doesn't seem to work on vim8.0

" These need to appear AFTER syntax has been enabled
hi PreProc gui=italic
hi Comment gui=italic 

set switchbuf=useopen       "swb:   Jumps to first window that contains
                            "specified buffer instead of duplicating an open window

"Only ignore case when we type lower case when searching
set ignorecase
set smartcase
"Silent bell
set visualbell
set hidden  " allow background buffers to be in a modified state (when tag jumping etc.)
set confirm " comfirm before deleting buffer with unsaved changes
"Show menu with possible tab completions
set wildmenu
"Ignore these files when completing names and in Explorer
set wildignore=.svn,CVS,.git,*.o,*.a,*.class,*.mo,*.la,*.so,*.obj,*.swp,*.jpg,*.png,*.xpm,*.gif
set wildmode=list:longest    "filename completion

" Ctrl-P/Ctrl-N ins-completion options - current buffer, current window,
" loaded buffer, unloaded buffers - add 't' for tags, but NOT included file
set complete=.,w,b,u,t
set tabstop=4
set shiftwidth=4

set autoindent
set showcmd
set expandtab
set backspace=indent,eol,start
"set hlsearch
set notimeout
" Turn off paste for middle mouse button click (scroll wheel accidentally pasting stuff!)
map <MiddleMouse> <Nop>
imap <MiddleMouse> <Nop>

" Min lines to keep above or below the cursor
set scrolloff=2

set showmatch
"set noswapfile
if isdirectory ("C:/Temp")
    set backupdir=C:/Temp
    set directory=C:/Temp
endif

if filereadable ("c:/cygwin-1.7.31-3/bin/ctags.exe")
    let g:tagbar_ctags_bin= 'c:/cygwin-1.7.31-3/bin/ctags'
elseif filereadable ("c:/cygwin/bin/ctags.exe")
    let g:tagbar_ctags_bin= 'c:/cygwin/bin/ctags'
endif

set tags=tags
if isdirectory ($DOS_CSP)
    if filereadable (expand ("$DOS_CSP/phnx_tags_dos"))
        set tags=$DOS_CSP/phnx_tags_dos
    else
        set tags=$DOS_CSP/phnx_tags
    endif
endif

" F5 - Tag identifier under cursor.
nmap <F5> :tjump <C-r><C-w><CR>
" same in insert mode - warning, will take you into Normal mode.
map! <F5> <Esc>:tjump <C-r><C-w><CR>
"Ctrl+\ - Open the definition in a new tab
map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
"Alt+] - Open the definition in a vertical split
"map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
autocmd BufReadPost *
    \ if line("'\"") > 0 && line("'\"") <= line("$") |
    \   exe "normal g`\"" |
    \ endif

" Ctrl-Enter - tag in new tab 
"nmap <C-Enter> <C-w><C-]><C-w>T

" opens each buffer in its own tab page
"autocmd BufAdd,BufNewFile * nested tab sball

"highlight shell scripts as per POSIX, not original Bourne shell
let g:is_posix = 1

" ,n to turn off search highlighting
nmap <silent> <leader>n :silent :nohlsearch<CR>
" ,l to toggle visible whitespace
nmap <silent> <leader>l :set list!<CR>
" ,n to toggle line numbers
nmap <silent> <leader>n :set number!<CR>
"Shift-tab to insert a hard tab
"imap <silent> <S-tab> <C-v><tab>

" ,f to insert a new line with '#ifdef OCTEON_TARGET'
nmap <silent> <leader>fo o#ifdef OCTEON_TARGET
nmap <silent> <leader>eo o#endif /* OCTEON_TARGET  */
nmap <silent> <leader>fl o#ifdef __LINUX__
nmap <silent> <leader>el o#endif /* __LINUX__  */

" When a popup menu is visible, make ENTER select the item instead of
" inserting a newline
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" I'm old-school and have never gotten used to this folding lark
set nofoldenable

" Make shift-insert work like in Xterm
map <S-Insert> <MiddleMouse>
map! <S-Insert> <MiddleMouse>

" Hide the mouse pointer while typing
set mousehide

nnoremap ,cd :cd %:p:h<CR>:pwd<CR>  " ,cd to chdir to current file (prints dir afterwards)

if exists('+shellslash')
    set shellslash      " Get Windows Vim to use forward slashes instead of backslashes
    function! DosExpandCurrentFile()        " Full DOS pathname of current file
        return substitute(expand("%:p"), "/", "\\", "g")
    endfun
    command! Ctcou echom system ("cleartool co -unr -nmaster -nc " . DosExpandCurrentFile())
    command! Cvtree echom system ("clearvtree " . DosExpandCurrentFile())

    function! CleartoolUnCo()               " Cleartool UnCheckout
        let choice = confirm ("Uncheckout " . expand ("%.p") . " ?", "&Yes\n&No", 2)
        if choice == 1
            echom system ("cleartool unco -keep " . DosExpandCurrentFile())
        endif
    endfunction
    command! Ctunco call CleartoolUnCo()

    function! FixupCs()                     " Fixup configspec
      " Fixup Configspec - change
      "     Checked in "/dir/file" version "\main\47".
      " -> 
      "     element /dir/file    /main/47
      execute '%s/^Checked in "/element /g'
      execute '%s/" version "/    /g'
      execute '%s/\\/\//g'
      execute '%s/".//g'
    endfunction
    command! Fixcs call FixupCs()

endif   " shellslash

" I keep on pressing capital-W / capital-Q
command! WQ wq
command! Wq wq
command! W w
command! Q q

