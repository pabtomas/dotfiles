" TODO {{{1
" }}}
" Quality of Life {{{1

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

" always display the number of changes after a command
set report=0

" }}}
" Performance {{{1

" draw only when needed
set lazyredraw

" indicates terminal connection, Vim will be faster
set ttyfast

" max column where syntax is applied (default: 3000)
set synmaxcol=79

" avoid visual mod lags
set noshowcmd

" }}}
" Colors {{{1
"   Palette {{{2

if exists('s:red') | unlet s:red | endif | const s:red = 196
if exists('s:orange') | unlet s:orange | endif | const s:orange = 202
if exists('s:purple_1') | unlet s:purple_1 | endif | const s:purple_1 = 62
if exists('s:purple_2') | unlet s:purple_2 | endif | const s:purple_2 = 140
if exists('s:purple_3') | unlet s:purple_3 | endif | const s:purple_3 = 176
if exists('s:blue_1') | unlet s:blue_1 | endif | const s:blue_1 = 69
if exists('s:blue_2') | unlet s:blue_2 | endif | const s:blue_2 = 105
if exists('s:blue_3') | unlet s:blue_3 | endif | const s:blue_3 = 111
if exists('s:green') | unlet s:green | endif | const s:green = 42
if exists('s:white_1') | unlet s:white_1 | endif | const s:white_1 = 147
if exists('s:white_2') | unlet s:white_2 | endif | const s:white_2 = 153
if exists('s:grey_1') | unlet s:grey_1 | endif | const s:grey_1 = 235
if exists('s:grey_2') | unlet s:grey_2 | endif | const s:grey_2 = 236
if exists('s:black') | unlet s:black | endif | const s:black = 232

"   }}}
"   Scheme {{{2

let s:redhighlight_cmd =
  \ 'highlight RedHighlight ctermfg=Black ctermbg=DarkRed'

if &term[-9:] =~ '-256color'

  let s:redhighlight_cmd =
    \ 'highlight RedHighlight ctermfg=' . s:black . ' ctermbg=DarkRed'

  set background=dark
  highlight clear
  if exists('syntax_on')
    syntax reset
  endif

  set wincolor=NormalAlt
  execute 'highlight       CurrentBuffer  term=bold           cterm=bold         ctermfg=' . s:black    . ' ctermbg=' . s:purple_2 . ' |
    \      highlight       ActiveBuffer   term=bold           cterm=bold         ctermfg=' . s:green    . ' ctermbg=' . s:black    . ' |
    \      highlight       Normal         term=bold           cterm=bold         ctermfg=' . s:purple_3 . ' ctermbg=' . s:black    . ' |
    \      highlight       NormalAlt      term=NONE           cterm=NONE         ctermfg=' . s:white_2  . ' ctermbg=' . s:black    . ' |
    \      highlight       ModeMsg        term=NONE           cterm=NONE         ctermfg=' . s:blue_2   . ' ctermbg=' . s:black    . ' |
    \      highlight       MoreMsg        term=NONE           cterm=NONE         ctermfg=' . s:blue_3   . ' ctermbg=' . s:black    . ' |
    \      highlight       Question       term=NONE           cterm=NONE         ctermfg=' . s:blue_3   . ' ctermbg=' . s:black    . ' |
    \      highlight       NonText        term=NONE           cterm=NONE         ctermfg=' . s:orange   . ' ctermbg=' . s:black    . ' |
    \      highlight       Comment        term=NONE           cterm=NONE         ctermfg=' . s:purple_2 . ' ctermbg=' . s:black    . ' |
    \      highlight       Constant       term=NONE           cterm=NONE         ctermfg=' . s:blue_1   . ' ctermbg=' . s:black    . ' |
    \      highlight       Special        term=NONE           cterm=NONE         ctermfg=' . s:blue_2   . ' ctermbg=' . s:black    . ' |
    \      highlight       Identifier     term=NONE           cterm=NONE         ctermfg=' . s:blue_3   . ' ctermbg=' . s:black    . ' |
    \      highlight       Statement      term=NONE           cterm=NONE         ctermfg=' . s:red      . ' ctermbg=' . s:black    . ' |
    \      highlight       PreProc        term=NONE           cterm=NONE         ctermfg=' . s:purple_2 . ' ctermbg=' . s:black    . ' |
    \      highlight       Type           term=NONE           cterm=NONE         ctermfg=' . s:blue_3   . ' ctermbg=' . s:black    . ' |
    \      highlight       Visual         term=reverse        cterm=reverse                                 ctermbg=' . s:black    . ' |
    \      highlight       LineNr         term=NONE           cterm=NONE         ctermfg=' . s:green    . ' ctermbg=' . s:black    . ' |
    \      highlight       Search         term=reverse        cterm=reverse      ctermfg=' . s:green    . ' ctermbg=' . s:black    . ' |
    \      highlight       IncSearch      term=reverse        cterm=reverse      ctermfg=' . s:green    . ' ctermbg=' . s:black    . ' |
    \      highlight       Tag            term=NONE           cterm=NONE         ctermfg=' . s:blue_3   . ' ctermbg=' . s:black    . ' |
    \      highlight       Error                                                 ctermfg=' . s:black    . ' ctermbg=' . s:red      . ' |
    \      highlight       ErrorMsg       term=bold           cterm=bold         ctermfg=' . s:red      . ' ctermbg=' . s:black    . ' |
    \      highlight       Todo           term=standout                          ctermfg=' . s:black    . ' ctermbg=' . s:blue_1   . ' |
    \      highlight       StatusLine     term=bold           cterm=bold         ctermfg=' . s:blue_3   . ' ctermbg=' . s:grey_2   . ' |
    \      highlight       StatusLineNC   term=bold           cterm=bold         ctermfg=' . s:blue_1   . ' ctermbg=' . s:grey_1   . ' |
    \      highlight       Folded         term=NONE           cterm=NONE         ctermfg=' . s:black    . ' ctermbg=' . s:orange   . ' |
    \      highlight       VertSplit      term=NONE           cterm=NONE         ctermfg=' . s:purple_2 . ' ctermbg=' . s:black    . ' |
    \      highlight       CursorLine     term=bold,reverse   cterm=bold,reverse ctermfg=' . s:blue_2   . ' ctermbg=' . s:black    . ' |
    \      highlight       MatchParen     term=bold           cterm=bold         ctermfg=' . s:purple_1 . ' ctermbg=' . s:white_1
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
else
  highlight       CurrentBuffer  term=bold           cterm=bold           ctermfg=White   ctermbg=Magenta
  highlight       ActiveBuffer   term=bold           cterm=bold           ctermfg=Red
endif

execute s:redhighlight_cmd

"   }}}
"   Good practices {{{2

let s:redhighlight = v:true

" highlight unused spaces before the end of the line
function! ExtraSpaces()
  call matchadd('RedHighlight', '\v\s+$')
endfunction

" highlight characters which overpass 80 columns
function! OverLength()
  call matchadd('RedHighlight', '\v%80v.*')
endfunction

" clear/add red highlight matching patterns
function! ToggleRedHighlight()
  if s:redhighlight
    highlight clear RedHighlight
    let s:redhighlight = v:false
    set synmaxcol=3000
  else
    execute s:redhighlight_cmd
    let s:redhighlight = v:true
    set synmaxcol=79
  endif
endfunction

"   }}}
" }}}
" Buffers {{{1

" allow to switch between buffers without writting them
set hidden

" return number of active listed-buffers
function! ActiveListedBuffers()
  return len(filter(getbufinfo({'buflisted':1}), 'v:val.hidden == v:false'))
endfunction

"   Listed-Buffers {{{2

" enable mappings for listed-buffers activated by unlisted-buffers
function! EnableMappingsListedBuffer()
  if buflisted(bufnr())

    let l:dict = maparg(':', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer
        nunmap <buffer> :
      endif
    endif

    let l:dict = maparg('Q', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer
        nunmap <buffer> Q
      endif
    endif

    let l:dict = maparg('gQ', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer
        nunmap <buffer> gQ
      endif
    endif

    let l:dict = maparg('q', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer
        nunmap <buffer> q
      endif
    endif

    let l:dict = maparg('<S-Up>', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer
        nunmap <buffer> <S-Up>
      endif
    endif

    let l:dict = maparg('<S-Down>', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer
        nunmap <buffer> <S-Down>
      endif
    endif

    let l:dict = maparg('<leader>a', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer
        nunmap <buffer> <leader>a
      endif
    endif

    let l:dict = maparg("<leader>'", 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer
        nunmap <buffer> <leader>'
      endif
    endif

    let l:dict = maparg(':', 'v', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer
        vunmap <buffer> :
      endif
    endif

    let l:dict = maparg('<leader>:', 'v', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer
        vunmap <buffer> <leader>:
      endif
    endif

    let l:dict = maparg('<leader>&', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer
        nunmap <buffer> <leader>&
      endif
    endif

    let l:dict = maparg('<leader>q', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer
        nunmap <buffer> <leader>q
      endif
    endif

    let l:dict = maparg('<leader>w', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer
        nunmap <buffer> <leader>w
      endif
    endif

  endif
endfunction

"   }}}
"   Unlisted-Buffers {{{2

" close Vim if only unlisted-buffers are active
function! CloseLonelyUnlistedBuffers()
  if ActiveListedBuffers() == 0
    quitall
  endif
endfunction

" disable risky mappings for unlisted-buffers
function! DisableMappingsUnlistedBuffer()
  if buflisted(bufnr()) == v:false

    let l:dict = maparg(':', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer == v:false
        nnoremap <buffer> : <Esc>
      endif
    else
      nnoremap <buffer> : <Esc>
    endif

    let l:dict = maparg('Q', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer == v:false
        nnoremap <buffer> Q <Esc>
      endif
    else
      nnoremap <buffer> Q <Esc>
    endif

    let l:dict = maparg('gQ', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer == v:false
        nnoremap <buffer> gQ <Esc>
      endif
    else
      nnoremap <buffer> gQ <Esc>
    endif

    let l:dict = maparg('q', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer == v:false
        nnoremap <buffer> q :quit<CR>
      endif
    else
      nnoremap <buffer> q :quit<CR>
    endif

    let l:dict = maparg('<S-Up>', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer == v:false
        nnoremap <buffer> <S-Up> <Esc>
      endif
    else
      nnoremap <buffer> <S-Up> <Esc>
    endif

    let l:dict = maparg('<S-Down>', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer == v:false
        nnoremap <buffer> <S-Down> <Esc>
      endif
    else
      nnoremap <buffer> <S-Down> <Esc>
    endif

    let l:dict = maparg('<leader>a', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer == v:false
        nnoremap <buffer> <leader>a <Esc>
      endif
    else
      nnoremap <buffer> <leader>a <Esc>
    endif

    let l:dict = maparg("<leader>'", 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer == v:false
        nnoremap <buffer> <leader>' <Esc>
      endif
    else
      nnoremap <buffer> <leader>' <Esc>
    endif

    let l:dict = maparg(':', 'v', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer == v:false
        vnoremap <buffer> : <Esc>
      endif
    else
      vnoremap <buffer> : <Esc>
    endif

    let l:dict = maparg('<leader>:', 'v', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer == v:false
        vnoremap <buffer> <leader>: <Esc>
      endif
    else
      vnoremap <buffer> <leader>: <Esc>
    endif

    let l:dict = maparg('<leader>&', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer == v:false
        nnoremap <buffer> <leader>& <Esc>
      endif
    else
      nnoremap <buffer> <leader>& <Esc>
    endif

    let l:dict = maparg('<leader>q', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer == v:false
        nnoremap <buffer> <leader>q <Esc>
      endif
    else
      nnoremap <buffer> <leader>q <Esc>
    endif

    let l:dict = maparg('<leader>w', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer == v:false
        nnoremap <buffer> <leader>w <Esc>
      endif
    else
      nnoremap <buffer> <leader>w <Esc>
    endif

    if g:NERDTree.IsOpen()
      file
    endif

  endif
endfunction

"   }}}
"   Quit functions {{{2

" - use bdelete if current buffer is active only once AND if there are other
"   listed-buffers,
" - quit current window if current buffer is active several times,
" - quit Vim IF there are 1 active listed-buffer AND no other listed-buffer.
function! Quit()
  if &modified == 0
    if (len(win_findbuf(bufnr())) == 1) &&
    \ (len(getbufinfo({'buflisted':1})) > 1)
      silent bdelete
    else
      silent quit
    endif
    return v:true
  else
    echo 'Personal Warning Message: ' . bufname('%') . ' has unsaved
      \ modifications'
    return v:false
  endif
endfunction

function! WriteQuit()
  update
  return Quit()
endfunction

function! QuitAll()
  while Quit()
  endwhile
endfunction

function! WriteQuitAll()
  while WriteQuit()
  endwhile
endfunction

"   }}}
"   Timer & Drawing functions {{{2

" timer variables
if exists('s:tick') | unlet s:tick | endif | const s:tick = 100
if exists('s:nb_ticks') | unlet s:nb_ticks | endif | const s:nb_ticks = 50
let s:elapsed_time = s:nb_ticks * s:tick
let s:lasttick_sizebuflist = len(getbufinfo({'buflisted':1}))
let s:lasttick_buffer = bufnr()

" resize the command window, display listed buffers, highlight current
" buffer and underline active buffers
function! DisplayBuffersList(prompt_hitting)
  let l:listed_buf = getbufinfo({'buflisted':1})
  let l:buffers_nb = len(l:listed_buf)

  if a:prompt_hitting == v:false
    let l:buffers_nb = l:buffers_nb + 1
  endif

  execute 'set cmdheight=' . l:buffers_nb
  for l:buf in l:listed_buf
    let l:line = " " . l:buf.bufnr . ": \"" . fnamemodify(l:buf.name, ':.')
      \ . "\""
    let l:line = l:line .
      \ repeat(" ", &columns - 1 - strlen(l:line)) . "\n"
    if l:buf.bufnr == bufnr()
      echohl CurrentBuffer | echon l:line | echohl None
    elseif l:buf.hidden == v:false
      echohl ActiveBuffer | echon l:line | echohl None
    else
      echon l:line
    endif
  endfor
endfunction

" update the buffers list displayed in commandline
function! UpdateCommandline()
  if s:elapsed_time < s:nb_ticks * s:tick
    let s:elapsed_time = s:elapsed_time + s:tick
    redraw
    set cmdheight=1
    call DisplayBuffersList(v:false)
  else
    call StopDrawing()
  endif
endfunction

function! StartDrawing()
  let s:elapsed_time = 0
endfunction

let s:redraw_allowed = v:true

function! EnableRedraw()
  if s:redraw_allowed == v:false
    let s:redraw_allowed = v:true
  endif
endfunction

function! DisableRedraw()
  if s:redraw_allowed
    let s:redraw_allowed = v:false
  endif
endfunction

function! StopDrawing()
  let s:elapsed_time = s:nb_ticks * s:tick
  if s:redraw_allowed
    set cmdheight=1
    redraw
  endif
endfunction

" allow to monitor 2 events:
" - buffers list adding/deleting
" - current listed-buffer entering
function! s:MonitorBuffersList(timer_id)
  let l:current_sizebufist = len(getbufinfo({'buflisted':1}))
  let l:current_buffer = bufnr()

  if (s:lasttick_sizebuflist != l:current_sizebufist) ||
  \ (s:lasttick_buffer != l:current_buffer)
    call StartDrawing()
  endif

  call UpdateCommandline()

  " avoid commandline and risky commands for unlisted-buffers
  if buflisted(l:current_buffer)
    call EnableMappingsListedBuffer()
  else
    call DisableMappingsUnlistedBuffer()
  endif

  let s:lasttick_sizebuflist = l:current_sizebufist
  let s:lasttick_buffer = l:current_buffer
endfunction

let s:timer =
  \ timer_start(s:tick, function('s:MonitorBuffersList'), {'repeat': -1})

"   }}}
" }}}
" Windows {{{1

function! NextWindow()
  if winnr() < winnr('$')
    execute winnr() + 1 . 'wincmd w'
  else
    1wincmd w
  endif
endfunction

function! PreviousWindow()
  if winnr() > 1
    execute winnr() - 1 . 'wincmd w'
  else
    execute winnr('$') . 'wincmd w'
  endif
endfunction

" }}}
" Plugins and Dependencies {{{1

function! CheckDependencies()
  if v:version < 801
    echoe 'Personal Error Message: your VimRC needs Vim 8.1 to be functionnal'
    quit
  endif

  if exists('g:NERDTree') == v:false ||
  \ exists('g:NERDTreeMapOpenInTab') == v:false ||
  \ exists('g:NERDTreeMapOpenInTabSilent') == v:false ||
  \ exists('g:NERDTreeMapOpenSplit') == v:false ||
  \ exists('g:NERDTreeMapOpenVSplit') == v:false ||
  \ exists('g:NERDTreeMapOpenExpl') == v:false ||
  \ exists('g:NERDTreeNaturalSort') == v:false ||
  \ exists('g:NERDTreeHighlightCursorline') == v:false ||
  \ exists('g:NERDTreeMouseMode') == v:false ||
  \ exists('g:NERDTreeHijackNetrw') == v:false ||
  \ exists(':NERDTreeToggle') == v:false
    echoe 'Personal Error Message: your VimRC needs NERDTree plugin
      \ to be functionnal'
    quit
  endif
endfunction

"   NERDTree {{{2

" unused NERDTree tabpage commands
let g:NERDTreeMapOpenInTab = ''
let g:NERDTreeMapOpenInTabSilent = ''

" disable splitting window with NERDTree
let g:NERDTreeMapOpenSplit = ""
let g:NERDTreeMapOpenVSplit = ""

" unused directory exploration command
let g:NERDTreeMapOpenExpl = ''

" sort files by number order
let g:NERDTreeNaturalSort = v:true

" highlight line where the cursor is
let g:NERDTreeHighlightCursorline = v:true

" single mouse click opens directories and files
let g:NERDTreeMouseMode = 3

" disable NERDTree to replace netrw
let g:NERDTreeHijackNetrw = v:true

"   }}}
" }}}
" FileType-specific {{{1
"   Bash {{{2

function! PrefillShFile()
  call append(0, [ '#!/bin/bash',
  \                '', ])
endfunction

"   }}}
" }}}
" Commands {{{1

" check if buffer is listed before to open it
function! ActivateBuffer(buf)
  if s:redraw_allowed == v:false
    if buflisted(a:buf)
      execute 'silent buffer ' . a:buf
    else
      echoe 'Personal Error Message: selected buffer is not listed'
    endif
    call EnableRedraw()
  else
    echoe 'Personal Error Message: redraw must be disabled before calling
      \ ActivateBuffer command'
  endif
endfunction

command -nargs=1 ActivateBuffer call ActivateBuffer(<args>)

" }}}
" Mappings {{{1

" leader key
let mapleader = '²'

" search and replace
vnoremap : :s/\%V//g<Left><Left><Left>

" search and replace (case-insensitive)
vnoremap <leader>: :s/\%V\c//g<Left><Left><Left>

" search (case-insensitive)
nnoremap <leader>/ /\c

" hide/show good practices
nnoremap <silent> <leader>z :call ToggleRedHighlight()<CR>

" copy the unnamed register's content in the command line
" unnamed register = any text deleted or yank (with y)
cnoremap <leader>p <C-R><C-O>"

" open .vimrc in a vertical split window
nnoremap <silent> <leader>& :vsplit $MYVIMRC<CR>

" compile .vimrc
nnoremap <leader>é :source $MYVIMRC<CR>

" stop highlighting from the last search
nnoremap <silent> <leader>" :nohlsearch<CR>

" open NERDTree in a vertical split window
nnoremap <silent> <leader>' :NERDTreeToggle<CR>

" Quit() functions
nnoremap <silent> <leader>q :call Quit()<CR>
nnoremap <silent> <leader>w :call WriteQuit()<CR>

" buffers menu
nnoremap <leader>a :call DisableRedraw() <bar>
  \ call DisplayBuffersList(v:true)<CR>:ActivateBuffer<Space>

" buffers navigation
nnoremap <silent> <S-Down> :silent bnext<CR>
nnoremap <silent> <S-Up> :silent bprevious<CR>

" windows navigation
nnoremap <silent> <S-Right> :silent call NextWindow()<CR>
nnoremap <silent> <S-Left> :silent call PreviousWindow()<CR>

" unfold vimscipt's folds
nnoremap <space> za

" for debug purposes
nnoremap <leader>m :call DisableRedraw() <bar> messages<CR>
  \:call EnableRedraw()
nnoremap <leader>mm :call DisableRedraw() <bar> map<CR>:call EnableRedraw()
nnoremap <leader>mmm :call DisableRedraw() <bar> abbreviate<CR>
  \:call EnableRedraw()
nnoremap <leader>mmmm :call DisableRedraw() <bar> command<CR>
  \:call EnableRedraw()
nnoremap <leader>mmmmm :call DisableRedraw() <bar> autocmd<CR>
  \:call EnableRedraw()

" }}}
" Abbreviations {{{1

" avoid intuitive write usage
cnoreabbrev w update

" avoid intuitive tabpage usage
cnoreabbrev tabe silent tabonly

" avoid intuitive quit usage
cnoreabbrev q call Quit()

" avoid intuitive exit usage
cnoreabbrev wq call WriteQuit()
cnoreabbrev x call WriteQuit()

" avoid intuitive quitall usage
cnoreabbrev qa call QuitAll()

" avoid intuitive exitall usage
cnoreabbrev wqa call WriteQuitAll()
cnoreabbrev xa call WriteQuitAll()

" avoid intuitive buffer usage
cnoreabbrev b call DisableRedraw()<CR>:call DisplayBuffersList(v:true)<CR>
  \:ActivateBuffer

" }}}
" Autocommands {{{1

augroup vimrc_autocomands
  autocmd!
"   VimEnter Autocommands Group {{{2

  " check vim dependencies before opening
  autocmd VimEnter * :call CheckDependencies()

"   }}}
"   Color Autocommands Group {{{2

  autocmd WinEnter * set wincolor=NormalAlt

"   }}}
"   Good Practices Autocommands Group {{{2

  autocmd BufEnter * :silent call ExtraSpaces() | silent call OverLength()

"   }}}
"   Listed-Buffers Autocommands Group {{{2

  " 1) entering commandline erases displayed buffers list,
  " 2) renable incremental search
  autocmd CmdlineEnter * call StopDrawing() |
    \ call timer_pause(s:timer, v:true)
  autocmd CmdlineLeave * call timer_pause(s:timer, v:false)

"   }}}
"   Unlisted-Buffers Autocommands Group {{{2

  autocmd BufEnter * :silent call CloseLonelyUnlistedBuffers()

"   }}}
"   Vimscript filetype Autocommands Group {{{2

  autocmd FileType vim setlocal foldmethod=marker

"   }}}
"   Bash filetype Autocommands Group {{{2

  autocmd BufNewFile *.sh :call PrefillShFile()

"   }}}
augroup END

" }}}
