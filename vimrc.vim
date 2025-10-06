"turly's minimal-ish vimrc
"Cobbled together from various sources since 2001 !

set nocompatible
set modelines=0
set nomodeline                      " Be safe! See CVE-2019-12735

let s:using_clearcase_p = 0

if exists('+shellslash')            " DOS / Cygwin
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
    if executable ("cleartool")
        let s:using_clearcase_p = 1
    endif
endif

" NO PLUGINS HERE

" Experiment with vim infinite undo
"set undofile
"set undodir=~/.vim/undodir

set encoding=utf-8    " Needed for patched powerline fonts (internal to vim I think)
let mapleader = ","
set number
set textwidth=0

if has("gui_running")
    set guioptions-=T           " no clunky toolbar (bozo icons)
    set guioptions+=c           " no Windows dialogs
    " This will stop at the first fontname that exists.
    set guifont=JetBrainsMono-Regular:h12,DejaVuSansMonoPowerline:h12,Go\ Mono\ for\ Powerline\ 11,Anonymice_Powerline:h11
    set lines=48
    set columns=128
    set colorcolumn=120         " gutter
    " Tab name is filename only with modification '+' if appropriate
    set guitablabel=%t\ %M
    " Turn all buffers into tabs
    nmap <silent> <leader>t :tab sball<CR>
    "set ruler
    "Allow huge Buffers menu and gazillions of tabs
    let &menuitems=50
    let &tabpagemax=50
else                            " TTY
    set ttyfast                 " tf:    improves redrawing for newer computers
    set mouse=a                 " Enabling this allows mouse-clicks (COPY/PASTE with SHIFT-[right-]clicks)
    let &runtimepath.=',~/vimfiles'     " get .../colors and .../after here
    if (has("termguicolors"))           " 24-bit xterm colors
        set termguicolors
    endif
    if has('mouse_sgr')         " Wide terminals
        set ttymouse=sgr
    endif
    " Some systems don't seem to have proper termcaps - hardcode the escape sequences for italic on/off
    let &t_ZH="\e[3m"
    let &t_ZR="\e[23m"
    " Also switch cursors based on insert mode
    let &t_SI="\e[5 q"
    let &t_EI="\e[0 q"

    set ttimeout
    set ttimeoutlen=128                     "millisecs for key sequences to complete
    set lazyredraw
    set title                               " set title of terminal window
    set titlestring=%(%{hostname()}\ \ %)
    set titlestring+=%(%{expand('%:p')}\ \ %)
endif

if s:using_clearcase_p
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

" Bozo find name of function/struct/class - really only works for the way I write C
let s:gfn_funcname = ''
let s:gfn_func_startline = 0
let s:gfn_func_endline = 0

function! GetFuncNameC(debug)
    let l:origline = line('.')
    let l:theline = 0
    let l:winview = winsaveview()
    " Search forward for a '}' on column zero marking the end of a function or struct / enum / whatever
    if (getline(l:origline)[0] == '}')  " already have a '}' on col zero of this line
        let l:end=l:origline
        norm 0
    else
        let l:end = search('^}', 'cW')  " Don't wrap, move the cursor, and c == accept match at cursor position
    endif
    if (l:end > 0)
        "From: https://stackoverflow.com/questions/39383253/how-can-i-find-the-position-of-matching-brace-or-bracket-in-vim-script
        "let l:skip_comments = 'synIDattr(synID(line("."), col("."), 0), "name") =~?' . '"string\\|comment\\|doxygen"'
        "let l:start = searchpair('{', '', '}', 'bW', l:skip_comments)  " search for matching open bracket

        let l:start = searchpair('{', '', '}', 'bW')  " search for matching open bracket
        if (a:debug) | echom 'orig: ' . l:origline . ' start:' . l:start . ' -> ' . getline(l:start) | endif
        if (a:debug) | echom 'end:' . l:end . ' -> ' . getline(l:end) | endif
        " search backwards from the '{' for a declaration starting on column 0 (could be on same line!)
        if (l:start != 0 && l:origline >= l:start && l:origline <= l:end)
            let l:ch = getline(l:start)[0]
            if ((l:ch >= 'a' && l:ch <= 'z') || (l:ch >= 'A' && l:ch <= 'Z') || (ch == '_'))  "iscsymf
                if (a:debug) | echom "start has iscymf" | endif
                let l:theline = l:start
            else
                let l:decl = search("^[^ \t#/]\\{2}[A-Za-z0-9_][^;]*\s*$", 'bcWn')
                if (a:debug) | echom 'decl:' . l:decl . ' -> ' . getline(l:decl) | endif
                if (l:decl && l:decl < l:start)
                    let l:theline = l:decl
                endif
            endif
        endif
    endif
    call winrestview(l:winview)
    let l:funcname = ""
    if (l:theline != 0)
        "echo '->' . l:theline . ': ' . getline(l:theline)
        let l:wordlist = split(getline(l:theline))
        let l:what = ""
        let l:prevword = ""
        let l:brackets = ""
        for l:word in l:wordlist
            if (a:debug) | echom l:word . ' ' . stridx(l:word, '(') | endif
            if (stridx(l:word, '__attribute__') >= 0 || stridx(l:word, '((') >= 0 || stridx (l:word, '))') >= 0)
                continue
            endif
            if (stridx(l:word, '/*') >= 0 || stridx(l:word, '//') >= 0)   " comment anywhere in this line? don't bother
                let l:funcname = l:prevword             " 'foo'
                break
            endif
            let l:bracketpos = stridx(l:word, '(')      " start of parameter list
            if (a:debug) | echom l:word . ' ' . l:bracketpos | endif
            if (l:bracketpos == 0)                      " int foo (int) - param list starts with a bracket
                let l:brackets = "()"
                let l:funcname = l:prevword             " 'foo'
                break
            elseif (l:bracketpos > 0)                   " int foo(int) - param list is embedded in string
                let l:brackets = "()"
                let l:what = l:prevword
                let l:funcname = l:word[0:l:bracketpos-1]
                break
            elseif (l:word[0] == '{')                   " struct or enum
                let l:funcname = l:prevword
                break
            endif
            let l:what = l:prevword
            let l:prevword = l:word
        endfor
        if (l:funcname == "")
            let l:funcname=l:prevword
        endif
        if (l:what != "")                               " 'struct', 'enum' or typename
            let l:what = l:what . ' '
        endif
        let l:funcname = l:what . l:funcname . l:brackets
    endif
    if (l:funcname != '')
        let s:gfn_func_startline = l:start
        let s:gfn_func_endline = l:end
    else                                                " Nothing on this line, don't check again unless we move
        let s:gfn_func_endline = l:origline
        let s:gfn_func_startline = l:origline
    endif
    return l:funcname
endfunction                                             " GetFuncNameC()

au BufEnter * let s:gfn_funcname = '' | let s:gfn_func_endline = -1
"let s:gfn_count = 0

function! GetFunctionName()         " no debug
    if (v:version > 700 && (&filetype == 'c' || &filetype == 'cpp'))
        let l:linenr = line('.')
        if (l:linenr < s:gfn_func_startline || l:linenr > s:gfn_func_endline)
            let s:gfn_funcname = GetFuncNameC(0)
   "" Debuggery
   "let s:gfn_count = s:gfn_count + 1
   "echohl ModeMsg
   "echo 'line: ' . l:linenr . ' fstart: ' . s:gfn_func_startline . ' fend: ' . s:gfn_func_endline . ' -> ' . s:gfn_funcname . ' count: ' . s:gfn_count
   "echohl None
        endif
    else        " not C, could be anything - make a (poor) best guess
        let s:gfn_funcname = getline(search("^[^ \t#/]\\{2}.*[^:]\s*$", 'bWn'))
    endif
    return s:gfn_funcname
endfun
function! ShowFuncName(debug)
  echohl ModeMsg
  echo 'fstart: ' . s:gfn_func_startline . ' fend: ' . s:gfn_func_endline . ' -> ' . s:gfn_funcname
  echo '->' . GetFuncNameC (a:debug)
  echohl None
endfun
map F :call ShowFuncName(1) <CR>

" Clearcase cruft

" Find Git Merge conflict
nnoremap <leader>gm /\v^\<\<\<\<\<\<\< \|\=\=\=\=\=\=\=$\|\>\>\>\>\>\>\> /<cr>

" move among buffers with CTRL
map <C-J> :bnext<CR>
map <C-K> :bprev<CR>
" Ctrl-E "Edit Buffer" shows buffer list and you just type the number
nnoremap <C-e> :set nomore <Bar> :ls <Bar> :set more <CR>:b<Space>

" Prefer LF line endings
set fileformat=unix
set fileformats=unix,dos
set pastetoggle=<F3>    " Turns off autoindent, etc when pasting code into vim
set formatoptions+=j    " Delete comment character when joining commented lines

let c_gnu=1
let c_ansi_typedefs=1
let c_comment_strings=1
let c_no_if0_fold=1     " bug? in syntax/c.vim causes problems if '#endif' for '#if 0' is not on column zero
let g:is_posix = 1      "highlight shell scripts as per POSIX, not original Bourne shell

"Vemacs! For insert mode, remap ^A/^E to move to the start/end of the current line
inoremap <C-e> <C-o>$
inoremap <C-a> <C-o>0

syntax on
set background=light
colorscheme github
" These need to appear AFTER syntax has been enabled
"hi PreProc      gui=italic      cterm=italic
hi Comment      gui=italic      cterm=italic
"hi CursorLine   guibg=Grey20    cterm=NONE      ctermbg=3 ctermfg=NONE
"In iTerm2 MacVim just setting the CursorLine's gui stuff seems to work -
"setting ctermbg doesn't.
hi CursorLine   guibg=Grey90     guifg=NONE     gui=bold    cterm=bold
"hi CursorColumn guibg=Grey20    cterm=NONE      ctermbg=23 ctermfg=NONE guifg=NONE
hi LineNr       guibg=NONE      guifg=darkgray  ctermbg=0

set colorcolumn=120
" Turn on CursorLine when we're in Insert mode
autocmd InsertEnter,InsertLeave * set cul!

set switchbuf=useopen       "swb:   Jumps to first window that contains
                            "specified buffer instead of duplicating an open window

"Only ignore case when we type lower case when searching
set ignorecase
set smartcase
"Whole word searching
nnoremap WW/ /\<\><left><left>
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
"set wildmode=longest:full,full    "filename completion
set wildmode=list:longest    "filename completion

" Ctrl-P/Ctrl-N ins-completion options - current buffer, current window,
" loaded buffer, unloaded buffers - add 't' for tags, but NOT included file
set complete=.,w,b,u,t
set tabstop=4
set shiftwidth=4
set nrformats-=octal    " Interpret octal as decimal when incrementing with Ctrl-A etc

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

" When running ctags, add --extra=+f to get filenames.  V. handy for large
" projects - can then just say :tj foo.c  - et voila.  See also "gf" (below.)
set tags=tags
if !empty ($PROJECT_TAGS) && isdirectory ($PROJECT_TAGS)
    set tags=$PROJECT_TAGS/phnx_tags
endif

" Cscope
if !empty ($CSCOPE_DB)
    if filereadable ($CSCOPE_DB)
        cscope add $CSCOPE_DB
    endif
endif
" ^\ s Find C symbol
" ^\ c Find functions calling this function
nmap <C-\>s :cs find s <C-R>=expand("<cword>")<CR><CR>
nmap <C-\>c :cs find c <C-R>=expand("<cword>")<CR><CR>

" gf - go to file under cursor - if filename is in taglist, use tags.
" http://vim.1045645.n5.nabble.com/cscope-best-practices-td5717670.html
nnoremap <expr> gf empty(taglist('^'.expand('<cfile>').'$')) ? "gf" : ":tj <C-R><C-F><CR>"
"Ctrl+\ - Open the definition in a new tab
"map <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>
"Alt+] - Open the definition in a vertical split
"map <A-]> :vsp <CR>:exec("tag ".expand("<cword>"))<CR>

" https://vim.fandom.com/wiki/Identify_the_syntax_highlighting_group_used_at_the_cursor
map <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
    \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
    \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<CR>


" Ctrl-Enter - tag in new tab
"nmap <C-Enter> <C-w><C-]><C-w>T

" opens each buffer in its own tab page
"autocmd BufAdd,BufNewFile * nested tab sball

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

if &background == "dark"
    " A bunch of background-colour alterations to change the background color
    " to differentiate editor windows
    nmap <silent> <leader>1 :hi Normal ctermbg=232 guibg=#080808<CR>
    nmap <silent> <leader>2 :hi Normal ctermbg=234 guibg=#1c1c1c<CR>
    nmap <silent> <leader>3 :hi Normal ctermbg=235 guibg=#262626<CR>
    nmap <silent> <leader>4 :hi Normal ctermbg=236 guibg=#303030<CR>
    nmap <silent> <leader>5 :hi Normal ctermbg=234 guibg=#1C2430<CR>
    nmap <silent> <leader>6 :hi Normal ctermbg=237 guibg=#2E3440<CR>
    " else make light versions of these
endif

" When a popup menu is visible, make ENTER select the item instead of inserting a newline
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Only interested in manual folding
set nofoldenable
" F2 - Toggle fold at #if to the matching #else or #endif.  Use zo / zc to open/close fold
"      ...and to avoid searching inside folds, use:  set fdo-=search
set fdo-=search     " by default, no searching inside folds
nnoremap <F2> V%zf
" Space toggles fold if there's one there
nnoremap <silent> <Space> @=(foldlevel('.')?'za':"\<Space>")<CR>

" Shift-Insert pastes from System Clipboard
nnoremap <S-Insert> "+P
map <S-Insert> "+gP

" Hide the mouse pointer while typing
set mousehide

nnoremap ,cd :cd %:p:h<CR>:pwd<CR>  " ,cd to chdir to current file (prints dir afterwards)

" Header files often live one folder up inside a 'h' dir
set path+=../h
command! Trimws execute '%s/\s*$//g'    " trim trailing whitespace - now done by default for C files
                                        " See the "BufWritePre" autocmd below
" I keep on pressing capital-W / capital-Q
command! WQ wq
command! Wq wq
command! W w
command! Q q

map Q nop   " Disable "Entering Ex mode" cruft

" From https://stackoverflow.com/questions/2600783/how-does-the-vim-write-with-sudo-trick-work
" Allow saving of files as sudo when I forgot to start vim using sudo.
cmap w!! w !sudo tee > /dev/null %


" Roll our own status line - based on https://gist.github.com/ericbn/f2956cd9ec7d6bff8940c2087247b132
"set noshowmode  " Avoid displaying stuff like '-- INSERT --' at the bottom of the screen

" Statusline with highlight groups (requires Powerline-style font)
set statusline=
set statusline+=%(%{&buflisted?bufnr('%'):''}\ \ %)
set statusline+=%t\  " Filename tail
set statusline+=%{&modified?'+\ ':''}
set statusline+=%{&readonly?'\ ':''}
set statusline+=%< " Truncate line here
set statusline+=%1*\  " Set highlight group to User1
set statusline+=%{strpart(GetFunctionName(),0,40)}
set statusline+=%= " Separation point between left and right aligned items
set statusline+=\ %{&filetype!=#''?toupper(&filetype):'NONE'}
set statusline+=\ \ %{strlen(&fenc)?&fenc:'none'}  " file encoding
set statusline+=%(\ \ %{&modifiable?(&expandtab?'et\ ':'noet\ ').&shiftwidth:''}%)
"set statusline+=%(\ %{(&bomb\|\|&fileencoding!~#'^$\\\|utf-8'?'\ '.&fileencoding.(&bomb?'-bom':''):'')
"  \.(&fileformat!=#(has('win32')?'dos':'unix')?'\ '.&fileformat:'')}%)
set statusline+=\ %* " Restore normal highlight
set statusline+=\ %2p%%\ %l:%-3c                       " percent of file, line X:column

" Logic for customizing the User1 highlight group is the following
" - if StatusLine colors are reverse, then User1 is not reverse and User1 fg = StatusLine fg
hi StatusLine cterm=reverse gui=reverse ctermfg=14 ctermbg=8 guifg=#93a1a1 guibg=#002732
hi StatusLineNC cterm=reverse gui=reverse ctermfg=11 ctermbg=0 guifg=#657b83 guibg=#073642
hi User1 ctermfg=14 ctermbg=0 guifg=#93a1a1 guibg=#073642

if has("autocmd")

  " Enable file type detection.
  " Use the default filetype settings, so that mail gets 'tw' set to 72,
  " 'cindent' is on in C files, etc.
  " Also load indent files, to automatically do language-dependent indenting.
  " Revert with ":filetype off".
  filetype plugin indent on

  " Put these in an autocmd group, so that you can revert them with:
  " ":augroup vimStartup | au! | augroup END"
  augroup vimStartup
    au!

    " When editing a file, always jump to the last known cursor position.
    " Don't do it when the position is invalid, when inside an event handler
    " (happens when dropping a file on gvim) and for a commit message (it's
    " likely a different one than last time).
    autocmd BufReadPost *
      \ if line("'\"") >= 1 && line("'\"") <= line("$") && &ft !~# 'commit'
      \ |   exe "normal! g`\""
      \ | endif

    "From https://vim.fandom.com/wiki/Remove_unwanted_spaces
    autocmd FileType c,cpp,java,php,vim autocmd BufWritePre <buffer> %s/\s\+$//e

    " Some people's C source uses hard tabs - ensure I do the same when editing those files
    function! CheckRealTabs()
        let l:hards = 0
        let l:softs = 0
        for l:line in getline(1, 384)               " Checking first 400-odd lines should be fine
            if !len (l:line) || l:line =~# '^\s*$'  " empty or just whitespace-only line doesn't count
                continue
            endif
            if l:line[0] == "\t"                    " begins with a TAB
                let l:hards += 1
            elseif l:line[0] == " "                 " begins with a space
                let l:softs += 1
            endif
        endfor
        "echo 'hards: ' . hards . ', softs: ' . softs
        if (l:hards > l:softs)
            setl noexpandtab
        endif
    endfunction

    au BufReadPost *.c,*.h call CheckRealTabs()

  augroup END
  " Stop auto-adding comment leaders
  au FileType * set fo-=c fo-=r fo-=o

endif " has("autocmd")

set laststatus=2

" Convert to CR Mac ending (Smalltalk.sources etc)
" e! +ff=mac
command! ToMac execute 'e! ++ff=mac'

" From https://gist.github.com/romainl/56f0c28ef953ffc157f36cc495947ab3
set grepprg=ag\ --vimgrep

function! Grep(...)
    return system(join([&grepprg] + [expandcmd(join(a:000, ' '))], ' '))
endfunction

command! -nargs=+ -complete=file_in_path -bar Grep  cgetexpr Grep(<f-args>)
command! -nargs=+ -complete=file_in_path -bar LGrep lgetexpr Grep(<f-args>)

cnoreabbrev <expr> grep  (getcmdtype() ==# ':' && getcmdline() ==# 'grep')  ? 'Grep'  : 'grep'
cnoreabbrev <expr> lgrep (getcmdtype() ==# ':' && getcmdline() ==# 'lgrep') ? 'LGrep' : 'lgrep'

augroup quickfix
    autocmd!
    autocmd QuickFixCmdPost cgetexpr cwindow
    autocmd QuickFixCmdPost lgetexpr lwindow
augroup END

" Map ]q for next QuickFix error, [q for previous, ]Q for last, [Q for first, ]^Q for next file, [^Q for prev file
nnoremap <silent> ]q :cnext<CR>
nnoremap <silent> [q :cprev<CR>
nnoremap <silent> ]Q :clast<CR>
nnoremap <silent> [Q :cfirst<CR>
nnoremap <silent> ]<C-Q> :cnfile<CR>
nnoremap <silent> [<C-Q> :cpfile<CR>
" Location List
nnoremap <silent> ]l :lnext<CR>
nnoremap <silent> [l :lprev<CR>
nnoremap <silent> ]L :llast<CR>
nnoremap <silent> [L :lfirst<CR>
nnoremap <silent> ]<C-L> :lnfile<CR>
nnoremap <silent> [<C-L> :lpfile<CR>
" Show/hide the QuickFix/LocationList window
nnoremap <Leader>co :copen<CR>
nnoremap <Leader>cc :cclose<CR>
nnoremap <Leader>lo :lopen<CR>
nnoremap <Leader>lc :lclose<CR>

