" Basic -----------------------------{{{

" Vi default options unused
set nocompatible

" allow mouse use
set mouse=a

" view tabulation, end of line and other hidden characters
syntax on
set list
set listchars=tab:▸\ ,eol:.

" status line content for each window :
" file + filetype + current line + total line
set statusline=%f\ -\ FileType:\ %y%=%c,\ [%l/%L]

" display status line
set laststatus=2

" highlight corresponding patterns during a search
set hlsearch incsearch

" line number
set number

" put the new window right of the current one
set splitright

" tabulation
set tabstop=2 softtabstop=2 expandtab shiftwidth=2 smarttab

" smart searchs : if no uppercase letter, search will be case-insensitive
set smartcase

" never be case sensitive
set ignorecase

" display number of selected lines in visual mode
set showcmd

function! CheckDependencies()
  if v:version < 800
    echoe "Your VimRC needs Vim 8.0 to be functionnal"
    quit
  elseif v:version < 801
    echoe "Your VimRC needs Vim 8.1 to be fully supported"
  endif

  if exists("g:NERDTree") == v:false ||
  \ exists("g:NERDTreeMapOpenInTab") == v:false ||
  \ exists("g:NERDTreeMapOpenInTabSilent") == v:false ||
  \ exists("g:NERDTreeNaturalSort") == v:false ||
  \ exists("g:NERDTreeMouseMode") == v:false ||
  \ exists("g:NERDTreeHighlightCursorline") == v:false ||
  \ exists(":NERDTreeToggle") == v:false ||
  \ exists("*g:NERDTree.IsOpen") == v:false
    echoe "Your VimRC needs NERDTree plugin to be functionnal"
  endif
endfunction

augroup vimenter_group
  autocmd!

  " clear jump list
  autocmd VimEnter * clearjump

  autocmd VimEnter * :call CheckDependencies()
augroup END

" }}}
" Color --------------------------{{{
"   Scheme --------------------{{{

" Red -> 196
" Orange -> 202
" Purple -> 62 - 140
" Blue -> 69 - 105 - 111
" Green -> 42
" White -> 147 - 153
" Dark-Gray -> 235 - 236 - 237
" Black -> 232

set background=dark
highlight clear
if exists("syntax_on")
  syntax reset
endif

" custom highlight groups
highlight       CurrentBuffer  term=bold         cterm=bold          ctermfg=232   ctermbg=140
highlight       RedHighlight                                         ctermfg=232   ctermbg=DarkRed

" predefined highlight groups
if v:version >= 801
  set wincolor=NormalAlt

  augroup colorscheme_group
    autocmd!
    autocmd WinEnter set wincolor=NormalAlt
  augroup END

  highlight     Normal         term=bold         cterm=bold          ctermfg=176   ctermbg=232
  highlight     NormalAlt      term=NONE         cterm=NONE          ctermfg=153   ctermbg=232
else
  highlight     Normal         term=NONE         cterm=NONE          ctermfg=153   ctermbg=232
endif

highlight       ModeMsg        term=NONE         cterm=NONE          ctermfg=105   ctermbg=232
highlight       MoreMsg        term=NONE         cterm=NONE          ctermfg=111   ctermbg=232
highlight       Question       term=NONE         cterm=NONE          ctermfg=111   ctermbg=232
highlight       NonText        term=NONE         cterm=NONE          ctermfg=105   ctermbg=232
highlight       Comment        term=NONE         cterm=NONE          ctermfg=140   ctermbg=232
highlight       Constant       term=NONE         cterm=NONE          ctermfg=69    ctermbg=232
highlight       Special        term=NONE         cterm=NONE          ctermfg=105   ctermbg=232
highlight       Identifier     term=NONE         cterm=NONE          ctermfg=111   ctermbg=232
highlight       Statement      term=NONE         cterm=NONE          ctermfg=196   ctermbg=232
highlight       PreProc        term=NONE         cterm=NONE          ctermfg=140   ctermbg=232
highlight       Type           term=NONE         cterm=NONE          ctermfg=111   ctermbg=232
highlight       Visual         term=reverse      cterm=reverse                     ctermbg=232
highlight       LineNr         term=NONE         cterm=NONE          ctermfg=42    ctermbg=232
highlight       Search         term=reverse      cterm=reverse       ctermfg=42    ctermbg=232
highlight       IncSearch      term=reverse      cterm=reverse       ctermfg=42    ctermbg=232
highlight       Tag            term=NONE         cterm=NONE          ctermfg=111   ctermbg=232
highlight       Error                                                ctermfg=232   ctermbg=196
highlight       ErrorMsg       term=bold         cterm=bold          ctermfg=196   ctermbg=232
highlight       Todo           term=standout                         ctermfg=232   ctermbg=69
highlight       StatusLine     term=NONE         cterm=NONE          ctermfg=111   ctermbg=236
highlight       StatusLineNC   term=NONE         cterm=NONE          ctermfg=69    ctermbg=235
highlight       Folded         term=NONE         cterm=NONE          ctermfg=232   ctermbg=202
highlight       VertSplit      term=NONE         cterm=NONE          ctermfg=140   ctermbg=232
highlight       CursorLine     term=bold,reverse cterm=bold,reverse  ctermfg=105   ctermbg=232
highlight       MatchParen     term=bold         cterm=bold          ctermfg=62    ctermbg=147
highlight! link WarningMsg     ErrorMsg
highlight  link String         Constant
highlight  link Character      Constant
highlight  link Number         Constant
highlight  link Boolean        Constant
highlight  link Float          Number
highlight  link Function       Identifier
highlight  link Conditional    Statement
highlight  link Repeat         Statement
highlight  link Label          Statement
highlight  link Operator       Statement
highlight  link Keyword        Statement
highlight  link Exception      Statement
highlight  link Include        PreProc
highlight  link Define         PreProc
highlight  link Macro          PreProc
highlight  link PreCondit      PreProc
highlight  link StorageClass   Type
highlight  link Structure      Type
highlight  link Typedef        Type
highlight  link SpecialChar    Special
highlight  link Delimiter      Special
highlight  link SpecialComment Special
highlight  link Debug          Special

"   }}}
"   Good practices -------------------------{{{

" highlight unused spaces before the end of the line
function! ExtraSpaces()
  let ExtraSpaces = matchadd("RedHighlight", '\v +$')
endfunction

" highlight characters which overpass 80 columns
function! OverLength()
  let OverLength = matchadd("RedHighlight", '\v%80v.*')
endfunction

augroup good_practices_group
  autocmd!
  autocmd BufEnter * :call ExtraSpaces() | call OverLength()
augroup END

"   }}}
" }}}
" Buffers -----------------------------{{{

" allow to switch between buffers without writting them
set hidden

" avoid tabpage usage
cnoreabbrev tabnew silent tabonly
cnoreabbrev tabe silent tabonly
cnoreabbrev tabed silent tabonly
cnoreabbrev tabedi silent tabonly
cnoreabbrev tabedit silent tabonly
cnoreabbrev tab silent tabonly
cnoreabbrev tabf silent tabonly
cnoreabbrev tabfi silent tabonly
cnoreabbrev tabfin silent tabonly
cnoreabbrev tabfind silent tabonly

" - quit current window & delete buffer inside, IF there are 2 non-NERDTree
"   windows or more,
" - come back to the previous listed buffer and delete current buffer IF
"   there are 1 non-NERDTree window (OR 1 non-NERDTree window + 1 NERDTree
"   window),
" - quit Vim IF there are 1 non-NERDTree window (OR 1 non-NERDTree window +
"   1 NERDTree window) AND no previous listed buffer.
function! Quit()
  if &modified == 0
    if len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) > 1
      let l:first_buf = bufnr("%")
      if winnr('$') == 1 || (winnr('$') == 2 && g:NERDTree.IsOpen())
        execute "normal! \<C-O>"
      else
        quit
      endif
      execute "silent bdelete" . l:first_buf
    else
      quit
    endif
  else
    echo "Current buffer has unsaved modifications"
  endif
endfunction

function! WQuit()
  write
  call Quit()
endfunction

" allow intuitive usage of Quit and WQuit functions
cnoreabbrev q call Quit()
cnoreabbrev qu call Quit()
cnoreabbrev qui call Quit()
cnoreabbrev quit call Quit()
cnoreabbrev bd call Quit()
cnoreabbrev bde call Quit()
cnoreabbrev bdel call Quit()
cnoreabbrev bdele call Quit()
cnoreabbrev bdelet call Quit()
cnoreabbrev bdelete call Quit()
cnoreabbrev wq call WQuit()
cnoreabbrev wbd call WQuit()

" disable intuitive usage of unused commands
cnoreabbrev Q quit
cnoreabbrev WQ wq
cnoreabbrev BD bdelete
cnoreabbrev TAB tab
cnoreabbrev TABN tabnew
cnoreabbrev TABE tabedit
cnoreabbrev TABF tabfind

" resize the command window, display listed buffers and hilight current
" buffer
function DisplayBuf(prompt_hitting)
  let l:buf_nb = len(filter(range(1, bufnr('$')), 'buflisted(v:val)'))

  if a:prompt_hitting == v:false
    let l:buf_nb = l:buf_nb + 1
  endif

  execute "set cmdheight=" . l:buf_nb
  for l:buf in filter(range(1, bufnr('$')), 'buflisted(v:val)')
    let l:result = " " . buf . ": \"" . bufname(l:buf) . "\""
    let l:result = l:result .
      \ repeat(" ", winwidth(0) - 1 - strlen(l:result)) . "\n"
    if l:buf == bufnr("%")
      echohl CurrentBuffer | echon l:result | echohl None
    else
      echon l:result
    endif
  endfor
endfunction

" go to the next/previous undisplayed listed buffer
function! BufNav(direction)
  let l:cycle = []
  if a:direction == 1
    let l:cycle = range(bufnr('%'), bufnr('$')) + range(1, bufnr('%'))
  elseif a:direction == -1
    let l:cycle = range(bufnr('%'), 1, -1) + range(bufnr('$'), bufnr('%'), -1)
  endif

  for l:buf in filter(l:cycle, 'buflisted(v:val)')
    if len(win_findbuf(l:buf)) == 0
      execute "silent " . l:buf . "buffer"
      break
    endif
  endfor
endfunction

" timer variables
let s:timer = 0
let s:callback_time = 1000
let s:nb_period = 50

function! ResetTimer()
  let s:timer = 0
endfunction

function! s:ResizeCmdWin(timer_id)
  let s:timer = s:timer + s:callback_time
  if s:timer >= s:nb_period * s:callback_time
    set cmdheight=1
  endif
endfunction

" resize the command window when listed buffers is undisplayed
call timer_start(s:callback_time, function('s:ResizeCmdWin'), {'repeat': -1})

" }}}
" NERDTree ---------------------------------------{{{

" close Vim if NERDTree is the only window remaining in it
function! CloseLonelyNERDTreeWindow()
  if winnr('$') == 1 && g:NERDTree.IsOpen()
    quit
  endif
endfunction

" if another buffer tries to replace NERDTree, put it in the other window,
" and bring back NERDTree.
function! BringBackNERDTree()
  if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' &&
  \ winnr('$') > 1 && (g:NERDTree.IsOpen() == v:false)
    let buf = bufnr()
    buffer#
    execute "normal! \<C-W>w"
    execute 'buffer'.buf
  endif
endfunction

augroup nerdtree_group
  autocmd!
  autocmd BufEnter * :call CloseLonelyNERDTreeWindow()
  autocmd BufEnter * :call BringBackNERDTree()

  " avoid commandline for NERDTree buffers
  autocmd BufEnter * :if bufname('%') =~ 'NERD_tree_\d\+' |
    \ nnoremap <buffer> : <Esc> | endif
augroup END

" unused NERDTree tabpage commands
let g:NERDTreeMapOpenInTab = ''
let g:NERDTreeMapOpenInTabSilent = ''

" sort files by number order
let g:NERDTreeNaturalSort = v:true

" highlight line where the cursor is
let g:NERDTreeHighlightCursorline = v:true

" single mouse click opens directories and files
let g:NERDTreeMouseMode = 3

" }}}
" Mapping -------------------------------------{{{

" leader key
let mapleader = "²"

" search and replace between visual mode and line command mode
vnoremap : :s/\%V//g<Left><Left><Left>

" copy the unnamed register's content in the command line
" unnamed register = any text deleted or yank (with y)
cnoremap <leader>p <C-R><C-O>"

" open .vimrc in a vertical split window
nnoremap <leader>& :vsplit $MYVIMRC<CR>

" compile .vimrc
nnoremap <leader>é :source $MYVIMRC<CR>

" stop highlighting from the last search
nnoremap <leader>" :nohlsearch<CR>

" open NERDTree in a vertical split window
nnoremap <leader>' :NERDTreeToggle<CR>

" buffer menu
nnoremap <leader>( :call DisplayBuf(v:true)<CR>:buffer<Space>

" buffer navigation
nnoremap <Tab> :call ResetTimer() <bar> :call BufNav(1) <bar>
  \ :call DisplayBuf(v:false)<CR>
nnoremap <S-Tab> :call ResetTimer() <bar> :call BufNav(-1) <bar>
  \ :call DisplayBuf(v:false)<CR>

" make space more useful
nnoremap <space> za

" }}}
" FileType-specific -----------------------------------{{{
"   Vimscript ---------------{{{

augroup filetype_vimscript_group
  autocmd!
  autocmd FileType vim setlocal foldmethod=marker
augroup END

"   }}}
" }}}
