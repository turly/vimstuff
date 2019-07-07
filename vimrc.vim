"turly's minimal-ish vimrc
"Cobbled together from various sources since 2001 !
"
set nocompatible
set modelines=0
set nomodeline                      " Be safe! See CVE-2019-12735

if exists('+shellslash')            " DOS
    set shellslash                  " Get Windows Vim to use forward slashes instead of backslashes
    set shell=C:/cygwin-2.10.0/bin/bash
    "set shellcmdflag=--login\ -c
    set shellcmdflag=-c
    set shellxquote=\"              " bash wants '"' instead of Windows default '('
    let $CHERE_INVOKING=1           " bash opens in working directory
    if isdirectory ("C:/Temp")
        set backupdir=C:/Temp
        set directory=C:/Temp       " swap files
        let TMPDIR='C:/Temp'
    endif
endif


" See https://github.com/VundleVim/Vundle.vim
" To update: vim -c VundleUpdate -c quitall
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim' " let Vundle manage Vundle, required

Plugin 'Tagbar'
nmap <F8> :TagbarToggle<CR>

"Plugin 'ipod825/TagJump'

Plugin 'itchyny/lightline.vim'

" All of your Plugins must be added before the following line
call vundle#end()            " required
filetype plugin indent on    " required
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal

" Experiment with vim infinite undo
"set undofile
"set undodir=~/.vim/undodir

set encoding=utf-8    " Needed for patched powerline fonts (internal to vim I think)
let mapleader = ","
set background=dark
set number

if has("gui_running")
    set guioptions-=T           " no clunky toolbar (bozo icons)
    set guioptions+=c           " no Windows dialogs
    " This will stop at the first fontname that exists.
    set guifont=Go\ Mono\ for\ Powerline\ 11,Anonymous\ Pro\ for\ Powerline\ 11,Anonymice_Powerline:h11
    set lines=42
    set columns=100
    " Tab name is filename only with modification '+' if appropriate
    set guitablabel=%t\ %M
    " Turn all buffers into tabs
    nmap <silent> <leader>t :tab sball<CR>
    "set ruler
else
    set ttyfast         "tf:    improves redrawing for newer computers
    set t_Co=256        " 256 colors
    set mouse=a         " Enabling this allows mouse-clicks (COPY/PASTE with SHIFT-[right-]clicks)
    let &runtimepath.=',~/vimfiles'     " get .../colors and .../after here
    if (has("termguicolors"))           " 24-bit xterm colors
        set termguicolors
    endif
    if &term == "xterm" || &term == "xterm-256color"
        " Set terminal title to be filename - full path  [user@host]
        if !empty($CLEARCASE_ROOT) 
            autocmd BufEnter * let &titlestring = ' [' . $CLEARCASE_ROOT . ']  ' . expand("%:t") . '  -  ' . expand("%:p") . '   [' . $USER . '@' . hostname() . ']'
        else
            autocmd BufEnter * let &titlestring = expand("%:t") . '  -  ' . expand("%:p") . '   [' . $USER . '@' . hostname() . ']'
        endif
        set title

        " From http://vim.wikia.com/wiki/Configuring_the_cursor
        let &t_SI .= "\<Esc>[3 q"		" blinking underscore for insert mode
        let &t_EI .= "\<Esc>[2 q"		" solid block otherwise
        " 1 or 0 -> blinking block
        " 2 -> solid block
        " 3 -> blinking underscore
        " 4 -> solid underscore
        " 5 -> blinking vertical bar
        " 6 -> solid vertical bar
    endif
endif

"Ctrl-F2 toggles cursorline
map <C-F2> :set cursorline!<CR>
colorscheme bluish
autocmd InsertEnter * highlight CursorLine guibg=#303050 ctermbg=23
autocmd InsertLeave * highlight CursorLine guibg=#383838 ctermbg=237

set laststatus=2
let g:lightline = {
      \ 'component': {
      \   'readonly': '%{&readonly?"\ue0a2":""}',
      \   'tagbar': '%{tagbar#currenttag("[%s]", "", "f")}',
      \ },
      \ 'active': {
      \   'left': [ [ 'mode', 'paste' ], [ 'readonly', 'filename'], ['modified', 'tagbar'] ],
      \ },
      \ 'separator': { 'left': "\ue0b0", 'right': "\ue0b2" },
      \ 'subseparator': { 'left': "\ue0b1", 'right': "\ue0b3" }
      \ }

" Buffer shenanigans
" move among buffers with CTRL
map <C-J> :bnext<CR>
map <C-K> :bprev<CR>
" Ctrl-E "Edit Buffer" shows buffer list and you just type the number
nnoremap <C-e> :set nomore <Bar> :ls <Bar> :set more <CR>:b<Space>

" Prefer LF line endings
set fileformat=unix
set fileformats=unix,dos
set pastetoggle=<F3>    " Turns off autoindent, etc when pasting code into vim

set formatoptions+=j " Delete comment character when joining commented lines

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
"https://vi.stackexchange.com/questions/11393/disable-case-sensitive-auto-completion-while-smartcase-search-is-enabled
au InsertEnter * set noignorecase
au InsertLeave * set ignorecase
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
set nrformats-=octal

set autoindent
set showcmd
set expandtab       " but see au BufReadPost *.c,*.h below
set backspace=indent,eol,start
set nohlsearch
set notimeout
" Turn off paste for middle mouse button click (scroll wheel accidentally pasting stuff!)
map <MiddleMouse> <Nop>
imap <MiddleMouse> <Nop>

" Min lines to keep above or below the cursor
set scrolloff=2

set showmatch
"set noswapfile
if filereadable ("c:/cygwin-2.10.0/bin/ctags.exe")
    let g:tagbar_ctags_bin= 'c:/cygwin-2.10.0/bin/ctags'
elseif filereadable ("c:/cygwin-1.7.31-3/bin/ctags.exe")
    let g:tagbar_ctags_bin= 'c:/cygwin-1.7.31-3/bin/ctags'
endif

" When running ctags, add --extra=+f to get filenames.  V. handy for large
" projects - can then just say :tj foo.c  - et voila.  See also "gf" (below.)
set tags=tags
if isdirectory ($DOS_CSP)
    set tags=$DOS_CSP/phnx_tags

    "Cygwin cscope + Windows gVim doesn't want to co-operate for some reason, works fine standalone
    "Tried using Ausun Wang's cswrapper from http://www.vim.org/scripts/script.php?script_id=1783
    "function! AddCscope()
    "    set csprg=y:/bin/cygwin/cswrapper.exe
    "    cscope add $DOS_CSP/cscope.out
    "endfun
    "command! Addcs call AddCscope()     " Invoke only when needed, my cscope.out is 350 MB!

endif

" gf - go to file under cursor - if filename is in taglist, use tags.
" http://vim.1045645.n5.nabble.com/cscope-best-practices-td5717670.html
nnoremap <expr> gf empty(taglist('^'.expand('<cfile>').'$')) ? "gf" : ":tj <C-R><C-F><CR>"

" F5 - TagJump identifier under cursor.
nmap <F5> :tjump <C-r><C-w><CR>
" same in insert mode - warning, will take you into Normal mode.
map! <F5> <Esc>:tjump <C-r><C-w><CR>
"Ctrl+\ - Open the definition in a new tab
"map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
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

" ,N to turn off search highlighting
nmap <silent> <leader>N :silent :nohlsearch<CR>
" ,l to toggle visible whitespace
nmap <silent> <leader>l :set list!<CR>
" ,n to toggle line numbers
nmap <silent> <leader>n :set number!<CR>
" ,b to make all buffers into tabs
"nmap <silent> <leader>b :bufdo tab split<CR>
"Shift-tab to insert a hard tab
"imap <silent> <S-tab> <C-v><tab>

" ,fo to insert a new line with '#ifdef OCTEON_TARGET'
nmap <silent> <leader>fo o#ifdef OCTEON_TARGET
nmap <silent> <leader>eo o#endif	/* OCTEON_TARGET  */
nmap <silent> <leader>fl o#ifdef __LINUX__
nmap <silent> <leader>el o#endif	/* __LINUX__  */
nmap <silent> <leader>fa o#ifdef __ARM__
nmap <silent> <leader>ea o#endif	/* __ARM__  */
nmap <silent> <leader>fb o#if __BYTE_ORDER__ == __BIG_ENDIAN
nmap <silent> <leader>eb o#endif	/* __BYTE_ORDER__  */
nmap <silent> <leader>f0 o#if 0
nmap <silent> <leader>f1 o#if 1
nmap <silent> <leader>ef o#endif
nmap <silent> <leader>ee o#else

" A bunch of background-colour alterations to change the background color
" to differentiate windows
nmap <silent> <leader>1 :hi Normal ctermbg=232 guibg=#080808<CR>
nmap <silent> <leader>2 :hi Normal ctermbg=234 guibg=#1c1c1c<CR>
nmap <silent> <leader>3 :hi Normal ctermbg=235 guibg=#262626<CR>
nmap <silent> <leader>4 :hi Normal ctermbg=236 guibg=#303030<CR>

" When a popup menu is visible, make ENTER select the item instead of
" inserting a newline
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Only interested in manual folding
set nofoldenable
" F2 - Toggle fold at #if to the matching #else or #endif.  Use zo / zc to open/close fold
"      ...and to avoid searching inside folds, use:  set fdo-=search
set fdo-=search     " by default, no searching inside folds
nnoremap <F2> V%zf
" Space toggles fold if there's one there
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>


" Make shift-insert work like in Xterm
map <S-Insert> <MiddleMouse>
map! <S-Insert> <MiddleMouse>

" Hide the mouse pointer while typing
set mousehide

nnoremap ,cd :cd %:p:h<CR>:pwd<CR>  " ,cd to chdir to current file (prints dir afterwards)

if 1                                        " Clearcase
    function! DosExpandCurrentFile()        " Full DOS pathname of current file
        if exists('+shellslash')            " DOS
            return substitute(expand("%:p"), "/", "\\", "g")
        else
            return expand("%:p")
        endif
    endfun
    function! CleartoolCheckout()
        echom system ("cleartool co -unr -nmaster -nc '" . DosExpandCurrentFile() . "'")
        if &modified == 1
            echoerr "ERROR: Not auto-loading file as buffer has been modified"
        else
            exe 'e!'
        endif
    endfun
    command! Ctcou call CleartoolCheckout()
    command! Cvtree echom system ("clearvtree '" . DosExpandCurrentFile() . "'")

    function! CleartoolUnCo()               " Cleartool UnCheckout
        let choice = confirm ("Uncheckout " . expand ("%.p") . " ?", "&Yes\n&No", 2)
        if choice == 1
            echom system ("cleartool unco -keep '" . DosExpandCurrentFile() . "'")
        endif
    endfunction
    command! Ctunco call CleartoolUnCo()

    function! FixupCs()                     " Fixup configspec
      " Fixup Configspec - change
      "     Checked in "/dir/file" version "\main\47".
      " ->
      "     element /dir/file    /main/47
      execute 'g/cleartool: Warning: Version checked in is not selected by view./d'
      execute '%s/^Checked in "/element /g'
      execute '%s/" version "/    /g'
      execute '%s/\\/\//g'
      execute '%s/".//g'
    endfunction
    command! Fixcs call FixupCs()

endif                                       " Clearcase 

" Header files generally live one folder up inside a 'h' dir
set path+=../h
command! Trimws execute '%s/\s*$//g'   " trim trailing whitespace

" I keep on pressing capital-W / capital-Q
command! WQ wq
command! Wq wq
command! W w
command! Q q

map Q nop   " Disable "Entering Ex mode" cruft


" Stop auto-adding comment leaders 
au FileType * set fo-=c fo-=r fo-=o

" Some people's C source uses hard tabs - ensure I do the same when editing those files
function! CheckRealTabs()
    let hards = 0
    let softs = 0
    for line in getline(1, 384)             " Checking first 400-odd lines should be fine
        if !len (line) || line =~# '^\s*$'  " empty or just whitespace-only line doesn't count
            continue
        endif
        if line =~# '^\t'                   " begins with a TAB
            let hards += 1
        elseif line =~# '^ '                " begins with a space
            let softs += 1
        endif
    endfor
    "echo 'hards: ' . hards . ', softs: ' . softs
    if (hards > softs)
        set noexpandtab
    endif
endfunction

au BufReadPost *.c,*.h call CheckRealTabs()

