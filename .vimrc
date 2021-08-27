" TODO {{{1

" - buffers menu: test
" - file explorer: - copy fullpath file/dir
"                  - disable Vexplore
"                  - add do buffers list without open it
"                  - open it in current window

" }}}
" Quality of life {{{1

" Vi default options unused
set nocompatible

" allow mouse use
set mouse=a

" view tabulation, end of line and other hidden characters
syntax on
set list
set listchars=tab:▸\ ,eol:.

" highlight corresponding patterns during a search
if !&hlsearch | set hlsearch | endif
if !&incsearch | set incsearch | endif

" line number
set number

" put the new window right of the current one
set splitright

" tabulation
set tabstop=2 softtabstop=2 expandtab shiftwidth=2 smarttab

" always display the number of changes after a command
set report=0

" disable default shortmessage config
" n       -> show [New] instead of [New File]
" x       -> show [unix] instead of [unix format]
" t and T -> truncate too long messages
" s       -> do not show search keys instructions when search is used
" S       -> do not search counter
" F       -> do not give the file info when editing a file
set shortmess=nxtTsSF

" }}}
" Performance {{{1

" draw only when needed
set lazyredraw

" indicates terminal connection, Vim will be faster
set ttyfast

" max column where syntax is applied (default: 3000)
set synmaxcol=200

" avoid visual mod lags
set noshowcmd

" }}}
" Status line {{{1

" display status line
set laststatus=2

function! FileName(modified, is_current_win)
  let l:check_current_win = (g:actual_curwin == win_getid())
  if (&modified != a:modified) || (l:check_current_win != a:is_current_win)
    return ''
  endif
  return fnamemodify(bufname('%'), ':.')
endfunction

function! StartLine()
  if g:actual_curwin != win_getid()
    return '───┤'
  endif
  return '━━━┫'
endfunction

function! ComputeStatusLineLength()
  let l:length = winwidth(winnr()) - (len(split('───┤ ', '\zs'))
    \ + len('[') + len(winnr()) + len('] ')
    \ + len(bufnr()) + len (':') + len(fnamemodify(bufname('%'), ':.'))
    \ + len(' [') + len(&ft) + len(']')
    \ + len(' C') + len(virtcol('.'))
    \ + len(' L') + len(line('.')) + len('/') + len(line('$')) + len(' ')
    \ + len(split('├', '\zs')))
  if g:actual_curwin == win_getid()
    let l:length -= len(StartMode()) + len(Mode()) + len(EndMode())
    if v:hlsearch && !empty(s:matches) && (s:matches.total > 0)
      let l:length -= len(IndexedMatch()) + len(Bar()) + len(TotalMatch())
    endif
  endif
  return l:length
endfunction

function! EndLine()
  let l:length = ComputeStatusLineLength()
  if g:actual_curwin != win_getid()
    return '├' . repeat('─', l:length)
  endif
  return '┣' . repeat('━', l:length)
endfunction

if exists('s:modes') | unlet s:modes | endif | const s:modes = {
  \ 'n': 'NORMAL', 'i': 'INSERT', 'R': 'REPLACE', 'v': 'VISUAL',
  \ 'V': 'VISUAL', "\<C-v>": 'VISUAL-BLOCK', 'c': 'COMMAND', 's': 'SELECT',
  \ 'S': 'SELECT-LINE', "\<C-s>": 'SELECT-BLOCK', 't': 'TERMINAL',
  \ 'r': 'PROMPT', '!': 'SHELL',
\ }

function! Mode()
  if g:actual_curwin != win_getid()
    return ''
  endif
  return s:modes[mode()[0]]
endfunction

function! StartMode()
  if g:actual_curwin != win_getid()
    return ''
  endif
  return '['
endfunction

function! EndMode()
  if g:actual_curwin != win_getid()
    return ''
  endif
  return '] '
endfunction

let s:matches = {}

function! IndexedMatch()
  if (g:actual_curwin != win_getid()) || !v:hlsearch
    return ''
  endif
  let s:matches = searchcount(#{ recompute: 1, maxcount: 0, timeout: 0 })
  if empty(s:matches) || (s:matches.total == 0)
    return ''
  endif
  return s:matches.current
endfunction

function! Bar()
  if (g:actual_curwin != win_getid()) || !v:hlsearch
  \ || empty(s:matches) || (s:matches.total == 0)
    return ''
  endif
  return '/'
endfunction

function! TotalMatch()
  if (g:actual_curwin != win_getid()) || !v:hlsearch
  \ || empty(s:matches) || (s:matches.total == 0)
    return ''
  endif
  return s:matches.total . ' '
endfunction

" status line content:
" [winnr] bufnr:filename [filetype] col('.') line('.')/line('$') [mode] matches
function! StatusLineData()
  set statusline+=\ [%3*%{winnr()}%0*]\ %3*%{bufnr()}%0*:
                   \%2*%{FileName(v:false,v:true)}%0*
                   \%2*%{FileName(v:false,v:false)}%0*
                   \%4*%{FileName(v:true,v:false)}%0*
                   \%1*%{FileName(v:true,v:true)}%0*
  set statusline+=\ [%3*%{&ft}%0*]
  set statusline+=\ C%3*%{virtcol('.')}%0*
  set statusline+=\ L%3*%{line('.')}%0*/%3*%{line('$')}\ %0*
  set statusline+=%{StartMode()}%3*%{Mode()}%0*%{EndMode()}
  set statusline+=%3*%{IndexedMatch()}%0*%{Bar()}%3*%{TotalMatch()}%0*
endfunction

function! StaticLine()
  set statusline=%{StartLine()}
  call StatusLineData()
  set statusline+=%{EndLine()}
endfunction

if exists('s:dots') | unlet s:dots | endif | const s:dots = [
\  '˳', '.', '｡', '·', '•', '･', 'º', '°', '˚', '˙',
\ ]

function! Wave(start, end)
  let l:wave = ''
  for l:col in range(a:start, a:end - 1)
    let l:wave = l:wave . s:dots[5 + float2nr(5.0 * sin(l:col *
    \ (fmod(0.05 * (s:localtime - s:start_animation) + 1.0, 2.0) - 1.0)))]
  endfor
  return l:wave
endfunction

function! StartWave()
  return Wave(0, 4)
endfunction

function! EndWave()
  let l:win_width = winwidth(winnr())
  return Wave(l:win_width - ComputeStatusLineLength() - 1, l:win_width)
endfunction

if &term[-9:] =~ '-256color'
  if exists('s:color_spec') | unlet s:color_spec | endif
  const s:color_spec = [
    \ 51, 45, 39, 33, 27, 21, 57, 93, 129, 165, 201, 200, 199, 198, 197, 196,
    \ 202, 208, 214, 220, 226, 190, 154, 118, 82, 46, 47, 48, 49, 50
  \ ]
endif

function! s:WaveLine(timer_id)
  if &term[-9:] =~ '-256color'
    let s:wavecolor = fmod(s:wavecolor + 0.75, 30.0)
    execute 'highlight User5 term=bold cterm=bold ctermfg='
      \ . s:color_spec[float2nr(floor(s:wavecolor))] . ' ctermbg=' . s:black
  endif

  let s:localtime = localtime()
  set statusline=%5*%{StartWave()}%0*
  call StatusLineData()
  set statusline+=%5*%{EndWave()}%0*

  if (s:localtime - s:start_animation) > 40
    call timer_pause(s:line_timer, v:true)
    call StaticLine()
  endif
endfunction

if &term[-9:] =~ '-256color' | let s:wavecolor = 0.0 | endif
let s:localtime = localtime()
let s:start_animation = s:localtime
call StaticLine()

if exists('s:line_timer') | call timer_stop(s:line_timer) | endif
let s:line_timer = timer_start(1000, function('s:WaveLine'), #{ repeat: -1 })
call timer_pause(s:line_timer, v:true)

function! AnimateStatusLine()
  if &term[-9:] =~ '-256color' | let s:wavecolor = 0.0 | endif
  let s:start_animation = localtime()
  call timer_pause(s:line_timer, v:false)
endfunction

" }}}
" Colors {{{1
"   Palette {{{2

if exists('s:red') | unlet s:red | endif
if exists('s:pink') | unlet s:pink | endif
if exists('s:orange_1') | unlet s:orange_1 | endif
if exists('s:orange_2') | unlet s:orange_2 | endif
if exists('s:orange_3') | unlet s:orange_3 | endif
if exists('s:purple_1') | unlet s:purple_1 | endif
if exists('s:purple_2') | unlet s:purple_2 | endif
if exists('s:purple_3') | unlet s:purple_3 | endif
if exists('s:blue_1') | unlet s:blue_1 | endif
if exists('s:blue_2') | unlet s:blue_2 | endif
if exists('s:blue_3') | unlet s:blue_3 | endif
if exists('s:blue_4') | unlet s:blue_4 | endif
if exists('s:green_1') | unlet s:green_1 | endif
if exists('s:green_2') | unlet s:green_2 | endif
if exists('s:white_1') | unlet s:white_1 | endif
if exists('s:white_2') | unlet s:white_2 | endif
if exists('s:grey_1') | unlet s:grey_1 | endif
if exists('s:grey_2') | unlet s:grey_2 | endif
if exists('s:black') | unlet s:black | endif

const s:red = 196
const s:pink = 205
const s:orange_1 = 202
const s:orange_2 = 209
const s:orange_3 = 216
const s:purple_1 = 62
const s:purple_2 = 140
const s:purple_3 = 176
const s:blue_1 = 69
const s:blue_2 = 105
const s:blue_3 = 111
const s:blue_4 = 45
const s:green_1 = 42
const s:green_2 = 120
const s:white_1 = 147
const s:white_2 = 153
const s:grey_1 = 236
const s:grey_2 = 244
const s:black = 232

"   }}}
"   Scheme {{{2

let s:redhighlight_cmd = 'highlight RedHighlight ctermfg=White ctermbg=DarkRed'

if &term[-9:] =~ '-256color'

  set background=dark | highlight clear | if exists('syntax_on') | syntax reset | endif
  set wincolor=NormalAlt

  execute 'highlight       Buffer             term=bold         cterm=bold         ctermfg=' . s:grey_2   . ' ctermbg=' . s:black    . ' |
    \      highlight       ModifiedBuf        term=bold         cterm=bold         ctermfg=' . s:red      .                            ' |
    \      highlight       BufferMenuBorders  term=bold         cterm=bold         ctermfg=' . s:blue_4   .                            ' |
    \      highlight       RootPath           term=bold         cterm=bold         ctermfg=' . s:pink     . ' ctermbg=' . s:black    . ' |
    \      highlight       ClosedDirPath      term=bold         cterm=bold         ctermfg=' . s:orange_3 . ' ctermbg=' . s:black    . ' |
    \      highlight       OpenedDirPath      term=bold         cterm=bold         ctermfg=' . s:orange_1 . ' ctermbg=' . s:black    . ' |
    \      highlight       FilePath           term=NONE         cterm=NONE         ctermfg=' . s:white_2  . ' ctermbg=' . s:black    . ' |
    \      highlight       Normal             term=bold         cterm=bold         ctermfg=' . s:orange_3 . ' ctermbg=' . s:black    . ' |
    \      highlight       NormalAlt          term=NONE         cterm=NONE         ctermfg=' . s:white_2  . ' ctermbg=' . s:black    . ' |
    \      highlight       ModeMsg            term=NONE         cterm=NONE         ctermfg=' . s:blue_2   . ' ctermbg=' . s:black    . ' |
    \      highlight       MoreMsg            term=NONE         cterm=NONE         ctermfg=' . s:blue_3   . ' ctermbg=' . s:black    . ' |
    \      highlight       Question           term=NONE         cterm=NONE         ctermfg=' . s:blue_3   . ' ctermbg=' . s:black    . ' |
    \      highlight       NonText            term=NONE         cterm=NONE         ctermfg=' . s:orange_1 . ' ctermbg=' . s:black    . ' |
    \      highlight       Comment            term=NONE         cterm=NONE         ctermfg=' . s:purple_2 . ' ctermbg=' . s:black    . ' |
    \      highlight       Constant           term=NONE         cterm=NONE         ctermfg=' . s:blue_1   . ' ctermbg=' . s:black    . ' |
    \      highlight       Special            term=NONE         cterm=NONE         ctermfg=' . s:blue_2   . ' ctermbg=' . s:black    . ' |
    \      highlight       Identifier         term=NONE         cterm=NONE         ctermfg=' . s:blue_3   . ' ctermbg=' . s:black    . ' |
    \      highlight       Statement          term=NONE         cterm=NONE         ctermfg=' . s:red      . ' ctermbg=' . s:black    . ' |
    \      highlight       PreProc            term=NONE         cterm=NONE         ctermfg=' . s:purple_2 . ' ctermbg=' . s:black    . ' |
    \      highlight       Type               term=NONE         cterm=NONE         ctermfg=' . s:blue_3   . ' ctermbg=' . s:black    . ' |
    \      highlight       Visual             term=reverse      cterm=reverse                                 ctermbg=' . s:black    . ' |
    \      highlight       LineNr             term=NONE         cterm=NONE         ctermfg=' . s:green_1  . ' ctermbg=' . s:black    . ' |
    \      highlight       Search             term=reverse      cterm=reverse      ctermfg=' . s:green_1  . ' ctermbg=' . s:black    . ' |
    \      highlight       IncSearch          term=reverse      cterm=reverse      ctermfg=' . s:green_1  . ' ctermbg=' . s:black    . ' |
    \      highlight       Tag                term=NONE         cterm=NONE         ctermfg=' . s:blue_3   . ' ctermbg=' . s:black    . ' |
    \      highlight       Error                                                   ctermfg=' . s:black    . ' ctermbg=' . s:red      . ' |
    \      highlight       ErrorMsg           term=bold         cterm=bold         ctermfg=' . s:red      . ' ctermbg=' . s:black    . ' |
    \      highlight       Todo               term=standout                        ctermfg=' . s:black    . ' ctermbg=' . s:blue_1   . ' |
    \      highlight       StatusLine         term=bold         cterm=bold         ctermfg=' . s:blue_4   . ' ctermbg=' . s:black    . ' |
    \      highlight       StatusLineNC       term=NONE         cterm=NONE         ctermfg=' . s:blue_1   . ' ctermbg=' . s:black    . ' |
    \      highlight       Folded             term=NONE         cterm=NONE         ctermfg=' . s:black    . ' ctermbg=' . s:orange_2 . ' |
    \      highlight       VertSplit          term=NONE         cterm=NONE         ctermfg=' . s:purple_2 . ' ctermbg=' . s:black    . ' |
    \      highlight       CursorLine         term=bold,reverse cterm=bold,reverse ctermfg=' . s:blue_4   . ' ctermbg=' . s:black    . ' |
    \      highlight       MatchParen         term=bold         cterm=bold         ctermfg=' . s:purple_1 . ' ctermbg=' . s:white_1  . ' |
    \      highlight       Pmenu              term=bold         cterm=bold         ctermfg=' . s:green_1  . ' ctermbg=' . s:black    . ' |
    \      highlight       PopupSelected      term=bold         cterm=bold         ctermfg=' . s:black    . ' ctermbg=' . s:purple_2 . ' |
    \      highlight       PmenuSbar          term=NONE         cterm=NONE         ctermfg=' . s:black    . ' ctermbg=' . s:blue_3   . ' |
    \      highlight       PmenuThumb         term=NONE         cterm=NONE         ctermfg=' . s:black    . ' ctermbg=' . s:blue_1   . ' |
    \      highlight       User1              term=bold         cterm=bold         ctermfg=' . s:pink     . ' ctermbg=' . s:black    . ' |
    \      highlight       User2              term=bold         cterm=bold         ctermfg=' . s:green_2  . ' ctermbg=' . s:black    . ' |
    \      highlight       User3              term=bold         cterm=bold         ctermfg=' . s:orange_3 . ' ctermbg=' . s:black
  highlight! link WarningMsg         ErrorMsg
  highlight  link String             Constant
  highlight  link Character          Constant
  highlight  link Number             Constant
  highlight  link Boolean            Constant
  highlight  link Float              Number
  highlight  link Function           Identifier
  highlight  link Conditional        Statement
  highlight  link Repeat             Statement
  highlight  link Label              Statement
  highlight  link Operator           Statement
  highlight  link Keyword            Statement
  highlight  link Exception          Statement
  highlight  link Include            PreProc
  highlight  link Define             PreProc
  highlight  link Macro              PreProc
  highlight  link PreCondit          PreProc
  highlight  link StorageClass       Type
  highlight  link Structure          Type
  highlight  link Typedef            Type
  highlight  link SpecialChar        Special
  highlight  link Delimiter          Special
  highlight  link SpecialComment     Special
  highlight  link Debug              Special
else
  highlight       Buffer             term=bold           cterm=bold           ctermfg=DarkGrey  ctermbg=Black
  highlight       ModifiedBuf        term=bold           cterm=bold           ctermfg=Red
  highlight       BufferMenuBorders  term=bold           cterm=bold           ctermfg=LightBlue
  highlight       RootPath           term=bold           cterm=bold           ctermfg=DarkRed   ctermbg=Black
  highlight       ClosedDirPath      term=bold           cterm=bold           ctermfg=Yellow    ctermbg=Black
  highlight       FilePath           term=NONE           cterm=NONE           ctermfg=White     ctermbg=Black
  highlight       Pmenu              term=NONE           cterm=NONE           ctermfg=White     ctermbg=NONE
  highlight       PmenuSbar          term=NONE           cterm=NONE           ctermfg=Black     ctermbg=Blue
  highlight       PmenuThumb         term=NONE           cterm=NONE           ctermfg=Black     ctermbg=White
  highlight       StatusLine         term=bold           cterm=bold           ctermfg=LightBlue ctermbg=NONE
  highlight       StatusLineNC       term=NONE           cterm=NONE           ctermfg=Blue      ctermbg=NONE
  highlight       User1              term=bold           cterm=bold           ctermfg=Red       ctermbg=NONE
  highlight       User2              term=bold           cterm=bold           ctermfg=Green     ctermbg=NONE
  highlight       User3              term=bold           cterm=bold           ctermfg=Yellow    ctermbg=NONE
  highlight  link OpenedDirPath      ClosedDirPath
endif

highlight         User4              term=bold           cterm=bold           ctermfg=Red
execute s:redhighlight_cmd

"   }}}
"   Text properties {{{2
"     Buffers menu {{{3

if index(prop_type_list(), 'buf') != -1 | call prop_type_delete('buf') | endif
if index(prop_type_list(), 'mbuf') != -1 | call prop_type_delete('mbuf') | endif

call prop_type_add('buf', #{ highlight: 'Buffer' })
call prop_type_add('mbuf', #{ highlight: 'ModifiedBuf' })

"     }}}
"     File explorer {{{3

if index(prop_type_list(), 'rpath') != -1 | call prop_type_delete('rpath') | endif
if index(prop_type_list(), 'fpath') != -1 | call prop_type_delete('fpath') | endif
if index(prop_type_list(), 'cdpath') != -1 | call prop_type_delete('cdpath') | endif
if index(prop_type_list(), 'odpath') != -1 | call prop_type_delete('odpath') | endif

call prop_type_add('rpath', #{ highlight: 'RootPath' })
call prop_type_add('fpath', #{ highlight: 'FilePath' })
call prop_type_add('cdpath', #{ highlight: 'ClosedDirPath' })
call prop_type_add('odpath', #{ highlight: 'OpenedDirPath' })

"     }}}
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
    highlight clear RedHighlight | set synmaxcol=3000
  else
    execute s:redhighlight_cmd | set synmaxcol=200
  endif
  let s:redhighlight = !s:redhighlight
endfunction

"   }}}
" }}}
" Buffers {{{1

" allow to switch between buffers without writting them
set hidden

" return number of active listed-buffers
function! ActiveListedBuffers()
  return len(filter(getbufinfo(#{ buflisted: 1 }), {_, val -> !val.hidden}))
endfunction

" close Vim if only unlisted-buffers are active
function! CloseLonelyUnlistedBuffers()
  if ActiveListedBuffers() == 0
    quitall
  endif
endfunction

"   Quit functions {{{2

" W   - winnr('$')
" ==N - is equal N
" =>N - is greater than N
" <=N - is less than N
" N   - distinct number of windows/u-buffer/l-buffers/h-buffers
function! Quit()
  if !&modified

    let l:current_buf = bufnr()

    " case 1:               current
    "   (>=1) win & (==1) unlisted-buf & (>=0) listed-buf & (>=0) hidden-buf
    let l:is_currentbuf_listed = buflisted(current_buf)

    if !l:is_currentbuf_listed
      silent quit
      return v:true
    endif

    " case 2:                                   current
    "   (==1) win & (==0) unlisted-buf & (==1) listed-buf & (==0) hidden-buf
    let l:more_than_one_window = (winnr('$') > 1)
    let l:at_least_one_hidden_listedbuf =
      \ !empty(filter(getbufinfo(#{ buflisted: 1 }), {_, val -> val.hidden}))

    if !l:more_than_one_window && !l:at_least_one_hidden_listedbuf
      silent quit
      return v:true
    endif

    " case 3:                                   current
    "   (==1) win & (==0) unlisted-buf & (==1) listed-buf & (>=1) hidden-buf
    let l:lastused_hiddenbuf = 1
    if l:at_least_one_hidden_listedbuf
      let l:lastused_hiddenbuf = map(sort(filter(getbufinfo(
        \ #{ buflisted: 1 }), {_, val -> val.hidden}),
        \ {x, y -> y.lastused - x.lastused}), {_, val -> val.bufnr})[0]
    endif

    if !l:more_than_one_window && l:at_least_one_hidden_listedbuf
      execute 'silent buffer '  . l:lastused_hiddenbuf
      execute 'silent bdelete ' . l:current_buf
      return v:true
    endif

    " case 4:                                     current
    "   (>=2) win & (<=W-2) unlisted-buf & (==1) listed-buf & (>=0) hidden-buf
    let l:current_buf_active_more_than_once =
      \ (len(win_findbuf(l:current_buf)) > 1)

    if l:more_than_one_window && l:current_buf_active_more_than_once
      silent quit
      return v:true
    endif

    " case 5:                                   current
    "   (>=2) win & (==W-1) unlisted-buf & (==1) listed-buf & (==0) hidden-buf
    let l:more_than_one_active_listedbuf = (ActiveListedBuffers() > 1)

    if l:more_than_one_window && !l:current_buf_active_more_than_once
    \ && !l:more_than_one_active_listedbuf && !l:at_least_one_hidden_listedbuf
      silent quitall
      return v:true
    endif

    " case 6:                                   current
    "   (>=2) win & (==W-1) unlisted-buf & (==1) listed-buf & (>=0) hidden-buf
    if l:more_than_one_window && !l:current_buf_active_more_than_once
    \ && !l:more_than_one_active_listedbuf && l:at_least_one_hidden_listedbuf
      execute 'silent buffer '  . l:lastused_hiddenbuf
      execute 'silent bdelete ' . l:current_buf
      return v:true
    endif

    " case 7:                                   current
    "   (>=2) win & (>=0) unlisted-buf & (>=2) listed-buf & (>=0) hidden-buf
    if l:more_than_one_window && l:more_than_one_active_listedbuf
    \ && !l:current_buf_active_more_than_once
      silent quit
      execute 'silent bdelete ' . l:current_buf
      return v:true
    endif

    let l:unlistedbuf_nb = 0
    for l:i in map(getbufinfo(), {_, val -> len(val.windows)})
      let l:unlistedbuf_nb += 1
    endfor

    echoerr 'Personal Error Message: this Quit() case is not expected,'
      \ . ' you have to define it: ' . winnr('$') . ' Window(s) & '
      \ . l:unlistedbuf_nb . ' Unlisted-Buffer(s) & '
      \ . len(getbufinfo(#{ buflisted: 1 })) . ' Listed-Buffer(s) & '
      \ . len(filter(getbufinfo(#{ buflisted: 1 }), {_, val -> val.hidden}))
      \ . ' Hidden-Buffer(s)'
  else
    echomsg 'Personal Warning Message: ' . bufname('%') . ' has unsaved
      \ modifications'
  endif
  return v:false
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
"   Buffers menu {{{2

let s:last_buf = bufnr()
let s:bufselect = ''

function! ReplaceCursorOnCurrentBuffer(winid)
  call win_execute(a:winid,
    \ 'call cursor(index(map(getbufinfo(#{ buflisted: 1 }),
    \ {_, val -> val.bufnr}), winbufnr(s:last_win)) + 1, 0)')
endfunction

function! BuffersMenuFilter(winid, key)
  if a:key == "\<Down>"
    bnext
    call ReplaceCursorOnCurrentBuffer(a:winid)
  elseif a:key == "\<Up>"
    bprevious
    call ReplaceCursorOnCurrentBuffer(a:winid)
  elseif a:key == "\<Enter>"
    call popup_close(a:winid)
  elseif a:key == "\<Esc>"
    execute 'buffer ' . s:last_buf
    call popup_close(a:winid)
  elseif (match(a:key, '\d') > -1) || (a:key == "$")
    if (a:key != "0") || (len(s:bufselect) > 0)
      let s:bufselect = s:bufselect . a:key
      let l:matches = filter(map(getbufinfo(#{ buflisted: 1 }),
        \ {_, val -> val.bufnr}),
        \ {_, val -> match(val, '^' . s:bufselect) > -1})
      if len(l:matches) == 1
        execute 'buffer ' . l:matches[0]
        call popup_close(a:winid)
      else
        echo s:bufselect . ' (' . len(l:matches) . ' matches:'
          \ . string(l:matches) . ')'
      endif
    endif
  elseif a:key == "\<BS>"
    let s:bufselect = s:bufselect[:-2]
    if len(s:bufselect) > 0
      let l:matches = filter(map(getbufinfo(#{ buflisted: 1 }),
        \ {_, val -> val.bufnr}),
        \ {_, val -> match(val, '^' . s:bufselect) > -1})
      echo s:bufselect . ' (' . len(l:matches) . ' matches:'
        \ . string(l:matches) . ')'
    else
      echo s:bufselect
    endif
  endif
  return v:true
endfunction

function! BuffersMenu()
  let l:listed_buf = getbufinfo(#{ buflisted: 1 })
  let l:listedbuf_nb = len(l:listed_buf)

  if l:listedbuf_nb < 1
    return
  endif

  let l:text = []
  let l:width = max(mapnew(l:listed_buf,
    \ {_, val -> len(val.bufnr . ': ""' . fnamemodify(val.name, ':.'))}))

  for l:buf in l:listed_buf
    let l:line = l:buf.bufnr . ': "' . fnamemodify(l:buf.name, ':.') . '"'
    let l:line = l:line . repeat(' ', l:width - len(l:line))

    let l:property = [#{ type: 'buf', col: 0, length: l:width + 1 }]
    if l:buf.changed
      let l:property = [#{ type: 'mbuf', col: 0, length: l:width + 1 }]
    endif

    call add(l:text, #{ text: l:line, props: l:property })
  endfor

  return #{ text: l:text, height: len(l:text), width: l:width }
endfunction

function! DisplayBuffersMenu()
  let s:last_buf = bufnr()
  let s:last_win = winnr()
  let s:bufselect = ''

  let l:menu = BuffersMenu()
  let l:popup_id = popup_create(l:menu.text,
  \ #{
    \ pos: 'topleft',
    \ line: win_screenpos(0)[0] + (winheight(0) - l:menu.height) / 2,
    \ col: win_screenpos(0)[1] + (winwidth(0) - l:menu.width) / 2,
    \ drag: v:true,
    \ wrap: v:false,
    \ filter: 'BuffersMenuFilter',
    \ mapping: v:false,
    \ border: [],
    \ borderhighlight: ['BufferMenuBorders'],
    \ borderchars: ['━', '┃', '━', '┃', '┏', '┓', '┛', '┗'],
    \ cursorline: v:true,
  \ })
  call ReplaceCursorOnCurrentBuffer(l:popup_id)
endfunction

"   }}
" }}}
" File explorer {{{1

function! PathCompare(file1, file2)
  if isdirectory(a:file1) && !isdirectory(a:file2)
    return 1
  elseif !isdirectory(a:file1) && isdirectory(a:file2)
    return -1
  endif
endfunction

function! InitTree()
  let s:tree = {}
  let s:tree['.'] = fnamemodify('.', ':p')
  let s:tree[fnamemodify('.', ':p')] = map(sort(reverse(
    \ readdir('.', '1', #{ sort: 'icase' })),
    \ "PathCompare"), {_, val -> fnamemodify(val, ':p')})
endfunction

let s:show_dotfiles = v:false
let s:expl_searchmode = v:false
let s:expl_search = ''
let s:expl_lastsearch = ''
call InitTree()

function! Depth(path)
  return len(split(substitute(a:path, '/$', '', 'g'), '/'))
endfunction

function! FileExplorerFilter(winid, key)
  if !s:expl_searchmode
    if a:key == "."
      let s:show_dotfiles = !s:show_dotfiles
      call popup_settext(a:winid, FileExplorer().text)
      call win_execute(a:winid, 'call cursor(2, 0)')
    elseif a:key == "y"
      " copy fullpath in unnamed register
    elseif a:key == "b"
      " use badd for the file
    elseif a:key == "o"
      " if dir
      "   open the directory and add content to the tree (even if empty)
      " elseif file
        edit s:tree[]
        call popup_close(a:winid)
    elseif a:key == "c"
      call InitTree()
      call popup_settext(a:winid, FileExplorer().text)
      call win_execute(a:winid, 'call cursor(2, 0)')
    elseif a:key == "n"
      call win_execute(a:winid, 'call search(s:expl_lastsearch[1:], "")')
    elseif a:key == "N"
      call win_execute(a:winid, 'call search(s:expl_lastsearch[1:], "b")')
    elseif a:key == "g"
      call win_execute(a:winid, 'call cursor(2, 0)')
    elseif a:key == "G"
      call win_execute(a:winid, 'call cursor(line("$"), 0)')
    elseif a:key == "\<Esc>"
      call popup_close(a:winid)
    elseif a:key == "\<Down>"
      call win_execute(a:winid, 'let s:expl_cursor = (line(".") < line("$"))')
      if s:expl_cursor
        call win_execute(a:winid, 'call cursor(line(".") + 1, 0)')
      endif
    elseif a:key == "\<Up>"
      call win_execute(a:winid, 'let s:expl_cursor = (line(".") > 2)')
      if s:expl_cursor
        call win_execute(a:winid, 'call cursor(line(".") - 1, 0)')
      endif
    elseif a:key == "/"
      let s:expl_searchmode = v:true
      let s:expl_search = '/'
      echo s:expl_search
    endif
  else
    if a:key == "\<Enter>"
      let s:expl_lastsearch = s:expl_search
      call win_execute(a:winid, 'call search(s:expl_search[1:], "c")')
      let s:expl_search = ''
    elseif a:key == "\<BS>"
      let s:expl_search = s:expl_search[:-2]
    elseif a:key == "\<Esc>"
      let s:expl_search = ''
    elseif a:key == "\<Down>"
    elseif a:key == "\<Up>"
    elseif a:key == "\<Left>"
    elseif a:key == "\<Right>"
    else
      let s:expl_search = s:expl_search . a:key
    endif
    if empty(s:expl_search)
      let s:expl_searchmode = v:false
    endif
    echo s:expl_search
  endif
  return v:true
endfunction

function! FileExplorer()
  let l:text = []

  let l:line = s:tree['.']
  let l:property = [#{ type: 'rpath', col: 0, length: len(l:line) + 1 }]

  call add(l:text, #{ text: l:line, props: l:property })

  let l:index = -1
  let l:stack = s:tree[s:tree['.']]
  let l:visited = {}
  let l:visited[s:tree['.']] = v:true
  while !empty(l:stack)
    " pop
    let l:current = l:stack[-1]
    let l:stack = l:stack[:-2]
    let l:index += 1

    " construct text
    let l:arrow = ''
    let l:id = ''
    let l:name = fnamemodify(l:current, ':t')
    if isdirectory(l:current)
      let l:name = fnamemodify(l:current, ':p:s?/$??:t')
      let l:id = '/'
      if has_key(s:tree, l:current)
        let l:arrow = '▾ '
      else
        let l:arrow = '▸ '
      endif
    endif

    if s:show_dotfiles || l:name[0] != '.'
      let l:indent = repeat('  ',
        \ Depth(l:current) - Depth(s:tree['.']) - isdirectory(l:current))
      let l:line = l:indent . l:arrow . l:name . l:id

      " construct property
      let l:property = [#{ type: 'fpath', col: 0, length: winwidth(0) + 1}]
      if isdirectory(l:current)
        if has_key(s:tree, l:current)
          let l:property = [#{ type: 'odpath', col: 0, length: winwidth(0) + 1}]
        else
          let l:property = [#{ type: 'cdpath', col: 0, length: winwidth(0) + 1}]
        endif
      endif

      call add(l:text, #{ text: l:line, props: l:property })
    endif

    " continue dfs
    if has_key(l:visited, l:current)
      let l:visited[l:current] = v:true
      let l:stack += s:tree[l:current]
    endif
  endwhile
  return #{ text: l:text }
endfunction

function! DisplayFileExplorer()
  let s:show_dotfiles = v:false
  let s:expl_searchmode = v:false
  let s:expl_search = ''
  call InitTree()

  let l:file_expl = FileExplorer()
  let l:popup_id = popup_create(l:file_expl.text,
  \ #{
    \ pos: 'topleft',
    \ line: win_screenpos(0)[0],
    \ col: win_screenpos(0)[1],
    \ minwidth: winwidth(0),
    \ maxwidth: winwidth(0),
    \ minheight: winheight(0),
    \ maxheight: winheight(0),
    \ drag: v:true,
    \ wrap: v:true,
    \ filter: 'FileExplorerFilter',
    \ mapping: v:false,
    \ scrollbar: v:true,
    \ cursorline: v:true,
  \ })
  call win_execute(l:popup_id, 'call cursor(2, 0)')
endfunction

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
" Dependencies {{{1

function! CheckDependencies()
  if v:version < 801
    let l:major_version = v:version / 100
    echoerr 'Personal Error Message: your VimRC needs Vim 8.1 to be'
      \ . ' functionnal. Your Vim version is ' l:major_version . '.'
      \ . (v:version - l:major_version * 100)
    quit
  endif
endfunction

" }}}
" Filetype specific {{{1
"   Bash {{{2

function! PrefillShFile()
  call append(0, [ '#!/bin/bash',
  \                '', ])
endfunction

"   }}}
" }}}
" Mappings {{{1

if exists('s:leader') | unlet s:leader | endif
if exists('s:shift_leader') | unlet s:shift_leader | endif

if exists('s:search_and_replace_mapping') | unlet s:search_and_replace_mapping | endif
if exists('s:search_and_replace_insensitive_mapping') | unlet s:search_and_replace_insensitive_mapping | endif
if exists('s:search_insensitive_mapping') | unlet s:search_insensitive_mapping | endif
if exists('s:past_unnamed_reg_in_cli_mapping') | unlet s:past_unnamed_reg_in_cli_mapping | endif
if exists('s:vsplit_vimrc_mapping') | unlet s:vsplit_vimrc_mapping | endif
if exists('s:source_vimrc_mapping') | unlet s:source_vimrc_mapping | endif
if exists('s:nohighlight_search_mapping') | unlet s:nohighlight_search_mapping | endif
if exists('s:toggle_good_practices_mapping') | unlet s:toggle_good_practices_mapping | endif
if exists('s:call_quit_function_mapping') | unlet s:call_quit_function_mapping | endif
if exists('s:call_writequit_function_mapping') | unlet s:call_writequit_function_mapping | endif
if exists('s:buffers_menu_mapping') | unlet s:buffers_menu_mapping | endif
if exists('s:file_explorer_mapping') | unlet s:file_explorer_mapping | endif
if exists('s:window_next_mapping') | unlet s:window_next_mapping | endif
if exists('s:window_previous_mapping') | unlet s:window_previous_mapping | endif
if exists('s:unfold_vim_fold_mapping') | unlet s:unfold_vim_fold_mapping | endif
if exists('s:message_command_mapping') | unlet s:message_command_mapping | endif
if exists('s:map_command_mapping') | unlet s:map_command_mapping | endif
if exists('s:autocompletion_mapping') | unlet s:autocompletion_mapping | endif
if exists('s:animate_statusline_mapping') | unlet s:animate_statusline_mapping | endif

" leader keys
const s:leader =                                                             '²'
const s:shift_leader =                                                       '³'

const s:search_and_replace_mapping =                                         ':'
const s:search_and_replace_insensitive_mapping = s:leader       .            ':'
const s:search_insensitive_mapping =             s:leader       .            '/'
const s:past_unnamed_reg_in_cli_mapping =        s:leader       .            'p'
const s:vsplit_vimrc_mapping =                   s:leader       .            '&'
const s:source_vimrc_mapping =                   s:shift_leader .            '1'
const s:nohighlight_search_mapping =             s:leader       .            'é'
const s:toggle_good_practices_mapping =          s:leader       .            '"'
const s:call_quit_function_mapping =             s:leader       .            'q'
const s:call_writequit_function_mapping =        s:leader       .            'w'
const s:buffers_menu_mapping =                   s:leader       .       s:leader
const s:file_explorer_mapping =                  s:shift_leader . s:shift_leader
const s:window_next_mapping =                                                'L'
const s:window_previous_mapping =                                            'H'
const s:unfold_vim_fold_mapping =                                      '<Space>'
const s:message_command_mapping =                s:leader       .            'm'
const s:map_command_mapping =                    s:leader       .           'mm'
const s:autocompletion_mapping =                                       '<S-Tab>'
const s:animate_statusline_mapping =             s:leader       .            's'

" search and replace
execute 'vnoremap '          . s:search_and_replace_mapping
  \ . ' :s/\%V//g<Left><Left><Left>'

" search and replace (case-insensitive)
execute 'vnoremap '          . s:search_and_replace_insensitive_mapping
  \ . ' :s/\%V\c//g<Left><Left><Left>'

" search (case-insensitive)
execute 'nnoremap '          . s:search_insensitive_mapping
  \ . ' /\c'

" copy the unnamed register's content in the command line
" unnamed register = any text deleted or yank (with y)
execute 'cnoremap '          . s:past_unnamed_reg_in_cli_mapping
  \ . ' <C-R><C-O>"'

" open .vimrc in a vertical split window
execute 'nnoremap <silent> ' . s:vsplit_vimrc_mapping
  \ . ' :vsplit $MYVIMRC<CR>'

" source .vimrc
execute 'nnoremap '          . s:source_vimrc_mapping
  \ . ' :source $MYVIMRC<CR>'

" stop highlighting from the last search
execute 'nnoremap <silent> ' . s:nohighlight_search_mapping
  \ . ' :nohlsearch<CR>'

" hide/show good practices
execute 'nnoremap <silent> ' . s:toggle_good_practices_mapping
  \ . ' :call ToggleRedHighlight()<CR>'

" animate statusline
execute 'nnoremap <silent> ' . s:animate_statusline_mapping
  \ . ' :call AnimateStatusLine()<CR>'

" Quit() functions
execute 'nnoremap <silent> ' . s:call_quit_function_mapping
  \ . ' :call Quit()<CR>'
execute 'nnoremap <silent> ' . s:call_writequit_function_mapping
  \ . ' :call WriteQuit()<CR>'

" buffers menu
execute 'nnoremap <silent> ' . s:buffers_menu_mapping
  \ . ' :silent call DisplayBuffersMenu()<CR>'

" file explorer
execute 'nnoremap <silent> ' . s:file_explorer_mapping
  \ . ' :silent call DisplayFileExplorer()<CR>'

" windows navigation
execute 'nnoremap <silent> ' . s:window_next_mapping
  \ . ' :silent call NextWindow()<CR>'
execute 'nnoremap <silent> ' . s:window_previous_mapping
  \ . ' :silent call PreviousWindow()<CR>'

" unfold vimscipt's folds
execute 'nnoremap '          . s:unfold_vim_fold_mapping
  \ . ' za'

" for debug purposes
execute 'nnoremap '          . s:message_command_mapping
  \ . ' :messages<CR>'
execute 'nnoremap '          . s:map_command_mapping
  \ . ' :map<CR>'

" autocompletion
execute 'inoremap '          . s:autocompletion_mapping
  \ . ' <C-n>'

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

" }}}
" Autocommands {{{1

augroup vimrc_autocomands
  autocmd!
"   Dependencies autocommands group {{{2

  autocmd VimEnter * :call CheckDependencies()

"   }}}
"   Color autocommands group {{{2

  autocmd WinEnter * set wincolor=NormalAlt

"   }}}
"   Good practices autocommands group {{{2

  autocmd BufEnter * :silent call ExtraSpaces() | silent call OverLength()

"   }}}
"   Buffers autocommands group {{{2

  autocmd BufEnter * :silent call CloseLonelyUnlistedBuffers()

"   }}}
"   File explorer autocommands group {{{2

  " autocmd VimEnter * silent! autocmd! FileExplorer
  " autocmd BufEnter,VimEnter * if isdirectory('<amatch>') | call DisplayFileExplorer() | endif

"   }}}
"   Vimscript filetype autocommands group {{{2

  autocmd FileType vim setlocal foldmethod=marker

"   }}}
"   Bash filetype autocommands group {{{2

  autocmd BufNewFile *.sh :call PrefillShFile()

"   }}}
augroup END

" }}}