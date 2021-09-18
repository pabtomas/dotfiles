" TODO {{{1

" - buffers menu: test
" - tree: - test

" }}}
" Quality of life {{{1

" Vi default options unused
set nocompatible

" allow mouse use
set mouse=a

" view tabulation, end of line and other hidden characters
syntax on
set list
set listchars=tab:≫\ ,eol:.
set fillchars=vert:│,fold:-,eob:∼

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

" automatically update a file if it is changed externally
set autoread

" visual autocomplete for command menu
set wildmenu

" give backspace its original power
set backspace=indent,eol,start

" }}}
" Performance {{{1

" draw only when needed
set lazyredraw

" indicates terminal connection, Vim will be faster
set ttyfast

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
function! s:StatusLineData()
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

function! s:StaticLine()
  set statusline=%{StartLine()}
  call s:StatusLineData()
  set statusline+=%{EndLine()}
endfunction

if exists('s:dots') | unlet s:dots | endif | const s:dots = [
\  '˳', '.', '｡', '·', '•', '･', 'º', '°', '˚', '˙',
\ ]

function! s:Wave(start, end)
  let l:wave = ''
  for l:col in range(a:start, a:end - 1)
    let l:wave = l:wave . s:dots[5 + float2nr(5.0 * sin(l:col *
    \ (fmod(0.05 * (s:localtime - s:start_animation) + 1.0, 2.0) - 1.0)))]
  endfor
  return l:wave
endfunction

function! StartWave()
  return s:Wave(0, 4)
endfunction

function! EndWave()
  let l:win_width = winwidth(winnr())
  return s:Wave(l:win_width - ComputeStatusLineLength() - 1, l:win_width)
endfunction

if exists('s:color_spec') | unlet s:color_spec | endif
const s:color_spec = [
  \ 51, 45, 39, 33, 27, 21, 57, 93, 129, 165, 201, 200, 199, 198, 197, 196,
  \ 202, 208, 214, 220, 226, 190, 154, 118, 82, 46, 47, 48, 49, 50
\ ]

function! s:WaveLine(timer_id)
  let s:wavecolor = fmod(s:wavecolor + 0.75, 30.0)
  execute 'highlight User5 term=bold cterm=bold ctermfg='
    \ . s:color_spec[float2nr(floor(s:wavecolor))] . ' ctermbg=' . s:black

  let s:localtime = localtime()
  set statusline=%5*%{StartWave()}%0*
  call s:StatusLineData()
  set statusline+=%5*%{EndWave()}%0*

  if (s:localtime - s:start_animation) > 40
    call timer_pause(s:line_timer, v:true)
    call s:StaticLine()
  endif
endfunction

let s:wavecolor = 0.0
let s:localtime = localtime()
let s:start_animation = s:localtime
call s:StaticLine()

if exists('s:line_timer') | call timer_stop(s:line_timer) | endif
let s:line_timer = timer_start(1000, function('s:WaveLine'), #{ repeat: -1 })
call timer_pause(s:line_timer, v:true)

function! s:AnimateStatusLine()
  let s:wavecolor = 0.0
  let s:start_animation = localtime()
  call timer_pause(s:line_timer, v:false)
endfunction

" }}}
" Style {{{1
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
"   Colorscheme {{{2

let s:redhighlight_cmd = 'highlight RedHighlight ctermfg=White ctermbg=DarkRed'

set background=dark | highlight clear | if exists('syntax_on') | syntax reset | endif
set wincolor=NormalAlt

execute 'highlight       Buffer             term=bold         cterm=bold         ctermfg=' . s:grey_2   . ' ctermbg=' . s:black    . ' |
  \      highlight       ModifiedBuf        term=bold         cterm=bold         ctermfg=' . s:red      .                            ' |
  \      highlight       BufferMenuBorders  term=bold         cterm=bold         ctermfg=' . s:blue_4   .                            ' |
  \      highlight       RootPath           term=bold         cterm=bold         ctermfg=' . s:pink     . ' ctermbg=' . s:black    . ' |
  \      highlight       ClosedDirPath      term=bold         cterm=bold         ctermfg=' . s:green_2  . ' ctermbg=' . s:black    . ' |
  \      highlight       OpenedDirPath      term=bold         cterm=bold         ctermfg=' . s:green_1  . ' ctermbg=' . s:black    . ' |
  \      highlight       FilePath           term=NONE         cterm=NONE         ctermfg=' . s:white_2  . ' ctermbg=' . s:black    . ' |
  \      highlight       Help               term=bold         cterm=bold         ctermfg=' . s:purple_2 . ' ctermbg=' . s:black    . ' |
  \      highlight       HelpKey            term=bold         cterm=bold         ctermfg=' . s:pink     . ' ctermbg=' . s:black    . ' |
  \      highlight       HelpMode           term=bold         cterm=bold         ctermfg=' . s:green_1  . ' ctermbg=' . s:black    . ' |
  \      highlight       Normal             term=bold         cterm=bold         ctermfg=' . s:purple_2 . ' ctermbg=' . s:black    . ' |
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
  \      highlight       User3              term=bold         cterm=bold         ctermfg=' . s:orange_3 . ' ctermbg=' . s:black    . ' |
  \      highlight       User4              term=bold         cterm=bold         ctermfg=Red'
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

execute s:redhighlight_cmd

"   }}}
"   Text properties {{{2

if index(prop_type_list(), 'statusline') != -1 | call prop_type_delete('statusline') | endif
if index(prop_type_list(), 'key') != -1 | call prop_type_delete('key') | endif
if index(prop_type_list(), 'help') != -1 | call prop_type_delete('help') | endif
if index(prop_type_list(), 'mode') != -1 | call prop_type_delete('mode') | endif

call prop_type_add('statusline', #{ highlight: 'StatusLine' })
call prop_type_add('key', #{ highlight: 'HelpKey' })
call prop_type_add('help', #{ highlight: 'Help' })
call prop_type_add('mode', #{ highlight: 'HelpMode' })

"     Buffers menu {{{3

if index(prop_type_list(), 'buf') != -1 | call prop_type_delete('buf') | endif
if index(prop_type_list(), 'mbuf') != -1 | call prop_type_delete('mbuf') | endif

call prop_type_add('buf', #{ highlight: 'Buffer' })
call prop_type_add('mbuf', #{ highlight: 'ModifiedBuf' })

"     }}}
"     Tree {{{3

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
function! s:ExtraSpaces()
  call matchadd('RedHighlight', '\v\s+$')
endfunction

" highlight characters which overpass 80 columns
function! s:OverLength()
  call matchadd('RedHighlight', '\v%80v.*')
endfunction

" clear/add red highlight matching patterns
function! s:ToggleRedHighlight()
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
function! s:ActiveListedBuffers()
  return len(filter(getbufinfo(#{ buflisted: 1 }), {_, val -> !val.hidden}))
endfunction

" close Vim if only unlisted-buffers are active
function! s:CloseLonelyUnlistedBuffers()
  if s:ActiveListedBuffers() == 0
    quitall
  endif
endfunction

"   Quit functions {{{2

" W   - winnr('$')
" ==N - is equal N
" =>N - is greater than N
" <=N - is less than N
" N   - distinct number of windows/u-buffer/l-buffers/h-buffers
function! s:Quit()
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
    let l:more_than_one_active_listedbuf = (s:ActiveListedBuffers() > 1)

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

function! s:WriteQuit()
  update
  return s:Quit()
endfunction

function! s:QuitAll()
  while s:Quit()
  endwhile
endfunction

function! s:WriteQuitAll()
  while s:WriteQuit()
  endwhile
endfunction

"   }}}
" }}}
" Windows {{{1

function! s:NextWindow()
  if winnr() < winnr('$')
    execute winnr() + 1 . 'wincmd w'
  else
    1wincmd w
  endif
endfunction

function! s:PreviousWindow()
  if winnr() > 1
    execute winnr() - 1 . 'wincmd w'
  else
    execute winnr('$') . 'wincmd w'
  endif
endfunction

" }}}
" Dependencies {{{1

function! s:CheckDependencies()
  if v:version < 801
    let l:major_version = v:version / 100
    echoerr 'Personal Error Message: your VimRC needs Vim 8.1 to be'
      \ . ' functionnal. Your Vim version is ' l:major_version . '.'
      \ . (v:version - l:major_version * 100)
    quit
  endif
endfunction

" }}}
" Plugins {{{1
"   Buffers menu {{{2
"     Help {{{3

function! s:HelpBuffersMenu()
  let l:lines = [ '     ' . s:Key([s:help_menukey]) . '     - Show this help',
   \ '    ' . s:Key([s:exit_menukey]) . '    - Exit buffers menu',
   \ '   ' . s:Key([s:next_menukey, s:previous_menukey])
     \ . '   - Next/Previous buffer',
   \ '   ' . s:Key([s:select_menukey]) . '   - Select buffer',
   \ '    < 0-9 >    - Buffer-id characters',
   \ '     < $ >     - End-of-string buffer-id character',
   \ ' ' . s:Key([s:erase_menukey]) . ' - Erase last buffer-id character',
  \ ]
  let l:text = []
  for l:line in l:lines
    let l:start = matchend(l:line, '^\s*< .\+ >\s* - \u')
    let l:properties = [#{ type: 'key', col: 1, length: l:start - 1}]
    let l:properties = l:properties + [#{ type: 'statusline',
      \ col: l:start - 2, length: 1 }]
    let l:start = 0
    while l:start > -1
      let l:start = match(l:line,
        \ '^\s*\zs< \| \zs> \s*- \u\| \zs| \|/\| .\zs-. ', l:start)
      if l:start > -1
        let l:start += 1
        let l:properties = l:properties + [#{ type: 'statusline',
          \ col: l:start, length: 1 }]
      endif
    endwhile
    call add(l:text, #{ text: l:line, props: l:properties })
  endfor
  call popup_create(l:text, #{ pos: 'topleft',
                             \ line: win_screenpos(0)[0] + winheight(0)
                             \   - len(l:text) - &cmdheight,
                             \ col: win_screenpos(0)[1],
                             \ zindex: 1,
                             \ minwidth: winwidth(0),
                             \ time: 10000,
                             \ border: [1, 0, 0, 0],
                             \ borderchars: ['━'],
                             \ borderhighlight: ["StatusLine"],
                             \ highlight: 'Help',
                             \ })
endfunction

"     }}}

let s:buf_before_menu = bufnr()
let s:menu_bufnr = ''

function! s:ReplaceCursorOnCurrentBuffer(winid)
  call win_execute(a:winid,
    \ 'call cursor(index(map(getbufinfo(#{ buflisted: 1 }),
    \ {_, val -> val.bufnr}), winbufnr(s:win_before_menu)) + 1, 0)')
endfunction

function! s:BuffersMenuFilter(winid, key)
  if a:key == s:next_menukey
    bnext
    call s:ReplaceCursorOnCurrentBuffer(a:winid)
  elseif a:key == s:previous_menukey
    bprevious
    call s:ReplaceCursorOnCurrentBuffer(a:winid)
  elseif a:key == s:select_menukey
    call popup_clear()
  elseif a:key == s:exit_menukey
    execute 'buffer ' . s:buf_before_menu
    call popup_clear()
  elseif match(a:key, s:select_menuchars) > -1
    if (a:key != "0") || (len(s:menu_bufnr) > 0)
      let s:menu_bufnr = s:menu_bufnr . a:key
      let l:matches = filter(map(getbufinfo(#{ buflisted: 1 }),
        \ {_, val -> val.bufnr}),
        \ {_, val -> match(val, '^' . s:menu_bufnr) > -1})
      if len(l:matches) == 1
        execute 'buffer ' . l:matches[0]
        call popup_clear()
      else
        echo s:menu_bufnr . ' (' . len(l:matches) . ' matches:'
          \ . string(l:matches) . ')'
      endif
    endif
  elseif a:key == s:erase_menukey
    let s:menu_bufnr = s:menu_bufnr[:-2]
    if len(s:menu_bufnr) > 0
      let l:matches = filter(map(getbufinfo(#{ buflisted: 1 }),
        \ {_, val -> val.bufnr}),
        \ {_, val -> match(val, '^' . s:menu_bufnr) > -1})
      echo s:menu_bufnr . ' (' . len(l:matches) . ' matches:'
        \ . string(l:matches) . ')'
    else
      echo s:menu_bufnr
    endif
  elseif a:key == s:help_menukey
    call s:HelpBuffersMenu()
  endif
  return v:true
endfunction

function! s:BuffersMenu()
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

function! s:DisplayBuffersMenu()
  let s:buf_before_menu = bufnr()
  let s:win_before_menu = winnr()
  let s:menu_bufnr = ''

  let l:menu = s:BuffersMenu()
  let l:popup_id = popup_create(l:menu.text,
  \ #{
    \ pos: 'topleft',
    \ line: win_screenpos(0)[0] + (winheight(0) - l:menu.height) / 2,
    \ col: win_screenpos(0)[1] + (winwidth(0) - l:menu.width) / 2,
    \ zindex: 2,
    \ drag: v:true,
    \ wrap: v:false,
    \ filter: expand('<SID>') . 'BuffersMenuFilter',
    \ mapping: v:false,
    \ border: [],
    \ borderhighlight: ['BufferMenuBorders'],
    \ borderchars: ['━', '┃', '━', '┃', '┏', '┓', '┛', '┗'],
    \ cursorline: v:true,
  \ })
  call s:ReplaceCursorOnCurrentBuffer(l:popup_id)
  call s:HelpBuffersMenu()
endfunction

"   }}}
"   Tree {{{2
"     Help {{{3
function! s:HelpTree()
  let l:lines = [ repeat('━', 41) . '┳' . repeat('━', winwidth(0) - 42),
    \ '      NORMAL Mode                        ┃        '
      \ . s:Key([s:reset_treekey]) . '        - Reset tree',
    \ '   ' . s:Key([s:help_treekey]) . '   - Show this help              ┃  '
      \ . '    ' . s:Key([s:searchmode_treekey])
      \ . '      - Enter SEARCH Mode',
    \ '  ' . s:Key([s:exit_treekey]) . '  - Exit tree                   ┃    '
      \ . '  ' . s:Key([s:next_match_treekey, s:previous_match_treekey])
      \ . '      - Next/Previous SEARCH match',
    \ ' ' . s:Key([s:next_file_treekey, s:previous_file_treekey])
      \ . ' - Next/Previous file          ┃                SEARCH Mode',
    \ ' ' . s:Key([s:first_file_treekey, s:last_file_treekey])
      \ . ' - First/Last file             ┃       '
      \ . s:Key([s:exit_smtreekey]) . '       - Exit SEARCH Mode',
    \ '   ' . s:Key([s:open_treekey]) . '   - Open/Close dir & Open files ┃  '
      \ . '    ' . s:Key([s:evaluate_smtreekey]) . '      - Evaluate SEARCH',
    \ '   ' . s:Key([s:badd_treekey]) . '   - Add to buffers list         ┃  '
      \ . '  ' . s:Key([s:erase_smtreekey]) . '    - Erase SEARCH',
    \ '   ' . s:Key([s:yank_treekey]) . '   - Yank path                   ┃ '
      \ . '     ' . s:Key([s:next_smtreekey, s:previous_smtreekey])
      \ . '      - Next/Previous SEARCH',
    \ '   ' . s:Key([s:dotfiles_treekey]) . '   - Show/Hide dot files        '
      \ . ' ┃ ' . s:Key([s:wide_left_smtreekey, s:wide_right_smtreekey])
      \ . ' - Navigation',
  \ ]
  let l:text = [#{ text: l:lines[0], props: [#{ type: 'statusline',
    \ col: 1, length: len(l:lines[0]) }] }]
  for l:line in l:lines[1:]

    let l:start = match(l:line, ' ┃ \s*<\zs .\+ >\s* - \u')
    let l:end = matchend(l:line, ' ┃ \s*< .\+ \ze>\s* - \u')
    let l:properties =
      \ [#{ type: 'key', col: l:start + 1, length: l:end - l:start }]

    let l:start = match(l:line, ' ┃ \s*< .\+ >\s* \zs- \u')
    let l:properties = l:properties + [#{ type: 'statusline',
      \ col: l:start + 1, length: 1 }]

    let l:start = match(l:line, '^\s*<\zs .\+ >\s* - \u.* ┃')
    let l:end = matchend(l:line, '^\s*< .\+ \ze>\s* - \u.* ┃')
    let l:properties = l:properties +
      \ [#{ type: 'key', col: l:start + 1, length: l:end - l:start }]

    let l:start = match(l:line, '^\s*< .\+ >\s* \zs- \u.* ┃')
    let l:properties = l:properties + [#{ type: 'statusline',
      \ col: l:start + 1, length: 1 }]

    let l:start = 0
    while l:start > -1
      let l:start = match(l:line,
        \ ' ┃ \s*\zs< \|^\s*\zs< \| \zs> \s*- \u\| \zs| \|/\| .\zs-. ',
        \ l:start)
      if l:start > -1
        let l:start += 1
        let l:properties = l:properties + [#{ type: 'statusline',
          \ col: l:start, length: 1 }]
      endif
    endwhile

    let l:properties = l:properties + [#{ type: 'statusline',
      \ col: match(l:line, ' \zs┃ '), length: len('┃')}]

    let l:start = match(l:line, '\u\{2,}')
    let l:end = matchend(l:line, '\u\{2,} Mode\|\u\{2,}')
    let l:properties = l:properties + [#{ type: 'mode',
      \ col: l:start, length: l:end + 1 - l:start }]

    call add(l:text, #{ text: l:line, props: l:properties })
  endfor
  call popup_create(l:text, #{ pos: 'topleft',
                             \ line: win_screenpos(0)[0] + winheight(0)
                             \   - len(l:text),
                             \ col: win_screenpos(0)[1],
                             \ zindex: 3,
                             \ minwidth: winwidth(0),
                             \ time: 10000,
                             \ highlight: 'Help',
                             \ })
endfunction

"     }}}

function! s:PathCompare(file1, file2)
  if isdirectory(a:file1) && !isdirectory(a:file2)
    return 1
  elseif !isdirectory(a:file1) && isdirectory(a:file2)
    return -1
  endif
endfunction

function! s:FullPath(path, value)
  let l:content = a:path . a:value
  if isdirectory(l:content)
    return l:content . '/'
  endif
  return l:content
endfunction

function! s:InitTree()
  let s:tree = {}
  let s:tree['.'] = fnamemodify('.', ':p')
  let s:tree[fnamemodify('.', ':p')] = sort(map(reverse(
    \ readdir('.', '1', #{ sort: 'icase' })), {_, val ->
      \ s:FullPath(s:tree['.'], val)}), expand('<SID>') . 'PathCompare')
  let s:tree_searchmode = v:false
  let s:tree_search = ''
endfunction

let s:show_dotfiles = v:false
let s:search_cursor = 0
let s:search_hist_cursor = 0
call s:InitTree()

function! s:Depth(path)
  return len(split(substitute(a:path, '/$', '', 'g'), '/'))
endfunction

function! s:NormalModeTreeFilter(winid, key)
  if a:key == s:dotfiles_treekey
    let s:show_dotfiles = !s:show_dotfiles
    call popup_settext(a:winid, s:Tree().text)
    call win_execute(a:winid, 'if line(".") > line("$") |'
      \ . ' call cursor(line("$"), 0) | endif')
  elseif a:key == s:yank_treekey
    call win_execute(a:winid, 'let s:tree_line = line(".") - 2')
    let l:path = s:Tree().paths[s:tree_line]
    let @" = l:path
    echo 'Unnamed register content is:'
    echohl OpenedDirPath
    echon @"
    echohl NONE
  elseif a:key == s:badd_treekey
    call win_execute(a:winid, 'let s:tree_line = line(".") - 2')
    let l:path = s:Tree().paths[s:tree_line]
    if !isdirectory(l:path)
      execute 'badd ' . l:path
      echohl OpenedDirPath
      echo l:path
      echohl NONE
      echon ' added to buffers list'
    endif
  elseif a:key == s:open_treekey
    call win_execute(a:winid, 'let s:tree_line = line(".") - 2')
    let l:path = s:Tree().paths[s:tree_line]
    if isdirectory(l:path)
      if has_key(s:tree, l:path)
        unlet s:tree[l:path]
      else
        let s:tree[l:path] = sort(map(reverse(
          \ readdir(l:path, '1', #{ sort: 'icase' })), {_, val ->
            \s:FullPath(l:path, val)}), expand('<SID>') . 'PathCompare')
      endif
      call popup_settext(a:winid, s:Tree().text)
    else
      call popup_clear()
      execute 'edit ' . l:path
    endif
  elseif a:key == s:reset_treekey
    call s:InitTree()
    call popup_settext(a:winid, s:Tree().text)
    call win_execute(a:winid, 'call cursor(2, 0)')
  elseif a:key == s:next_match_treekey
    call win_execute(a:winid, 'call search(histget("/", -1), "")')
  elseif a:key == s:previous_match_treekey
    call win_execute(a:winid, 'call search(histget("/", -1), "b")')
  elseif a:key == s:first_file_treekey
    call win_execute(a:winid,
      \ 'call cursor(2, 0) | execute "normal! \<C-Y>"')
  elseif a:key == s:last_file_treekey
    call win_execute(a:winid, 'call cursor(line("$"), 0)')
  elseif a:key == s:exit_treekey
    call win_execute(a:winid, 'call clearmatches()')
    call popup_clear()
  elseif a:key == s:next_file_treekey
    call win_execute(a:winid, 'if line(".") < line("$") |'
      \ . ' call cursor(line(".") + 1, 0) | endif')
  elseif a:key == s:previous_file_treekey
    call win_execute(a:winid, 'if line(".") > 2 |'
      \ . ' call cursor(line(".") - 1, 0) | else |'
      \ . ' execute "normal! \<C-Y>" | endif')
  elseif a:key == s:help_treekey
    call s:HelpTree()
  elseif a:key == s:searchmode_treekey
    let s:tree_searchmode = v:true
    let s:tree_search = a:key
    let s:search_cursor = 1
    let s:search_hist_cursor = 0
    echo s:tree_search
    echohl Visual
    echon ' '
    echohl NONE
  endif
endfunction

function! s:SearchModeTreeFilter(winid, key)
  if a:key == s:evaluate_smtreekey
    let @/ = '\%>1l' . s:tree_search[1:]
    call win_execute(a:winid,
      \ 'if s:tree_search[0] == "/" | call search(@/, "c") | '
      \ . 'elseif s:tree_search[0] == "?" | call search(@/, "bc") | endif')
    call histadd('/', @/)
    let s:tree_search = ''
  elseif a:key == s:erase_smtreekey
    if s:search_cursor > 1
      let s:tree_search = slice(s:tree_search, 0, s:search_cursor - 1)
        \ . slice(s:tree_search, s:search_cursor)
      let s:search_cursor -= 1
    endif
  elseif a:key == s:exit_smtreekey
    let s:tree_search = ''
  elseif a:key == s:next_smtreekey
    if s:search_hist_cursor < 0
      let s:search_hist_cursor += 1
      let s:tree_search = '/' . histget('search', s:search_hist_cursor)
    else
      let s:tree_search = '/'
    endif
    let s:search_cursor = len(s:tree_search)
  elseif a:key == s:previous_smtreekey
    if abs(s:search_hist_cursor) < &history
      let s:search_hist_cursor -= 1
      let s:tree_search = '/' . histget('search', s:search_hist_cursor)
      let s:search_cursor = len(s:tree_search)
    endif
  elseif a:key == s:left_smtreekey
    if s:search_cursor > 1
      let s:search_cursor -= 1
    endif
  elseif a:key == s:right_smtreekey
    if s:search_cursor < len(s:tree_search)
      let s:search_cursor += 1
    endif
  elseif a:key == s:wide_left_smtreekey
    for l:i in range(s:search_cursor - 2, 0, -1)
      if match(s:tree_search[l:i], '[[:punct:][:space:]]') > -1
        let s:search_cursor = l:i + 1
        break
      endif
    endfor
  elseif a:key == s:wide_right_smtreekey
    let s:search_cursor =
      \ match(s:tree_search[1:], '[[:punct:][:space:]]', s:search_cursor + 1)
    if s:search_cursor == -1
      let s:search_cursor = len(s:tree_search)
    endif
  else
    let s:tree_search = slice(s:tree_search, 0, s:search_cursor) . a:key
      \ . slice(s:tree_search, s:search_cursor)
    let s:search_cursor += 1
    call win_execute(a:winid, 'call clearmatches() | '
      \ . 'try | call matchadd("Search", "\\%>1l" . s:tree_search[1:]) | '
      \ . 'catch | endtry ')
  endif

  if empty(s:tree_search)
    let s:tree_searchmode = v:false
  endif
  echo slice(s:tree_search, 0, s:search_cursor)
  echohl Visual
  echon slice(s:tree_search, s:search_cursor, s:search_cursor + 1)
  if s:search_cursor == len(s:tree_search)
    echon ' '
  endif
  echohl NONE
  echon slice(s:tree_search, s:search_cursor + 1)
endfunction

function! s:TreeFilter(winid, key)
  if !s:tree_searchmode
    call s:NormalModeTreeFilter(a:winid, a:key)
  else
    call s:SearchModeTreeFilter(a:winid, a:key)
  endif
  return v:true
endfunction

function! s:Tree()
  let l:text = []
  let l:paths = []

  let l:line = s:tree['.']
  let l:property = [#{ type: 'rpath', col: 0, length: len(l:line) + 1 }]

  call add(l:text, #{ text: l:line, props: l:property })

  let l:stack = s:tree[s:tree['.']]
  let l:visited = {}
  let l:visited[s:tree['.']] = v:true
  while !empty(l:stack)
    " pop
    let l:current = l:stack[-1]
    let l:stack = l:stack[:-2]

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
        \ s:Depth(l:current) - s:Depth(s:tree['.']) - isdirectory(l:current))
      let l:line = l:indent . l:arrow . l:name . l:id

      " construct property
      let l:property = [#{ type: 'fpath', col: 0, length: winwidth(0) + 1}]
      if isdirectory(l:current)
        if has_key(s:tree, l:current)
          let l:property =
            \ [#{ type: 'odpath', col: 0, length: winwidth(0) + 1}]
        else
          let l:property =
            \ [#{ type: 'cdpath', col: 0, length: winwidth(0) + 1}]
        endif
      endif

      call add(l:text, #{ text: l:line, props: l:property })
      call add(l:paths, l:current)
    endif

    " continue dfs
    if !has_key(l:visited, l:current)
      let l:visited[l:current] = v:true
      if has_key(s:tree, l:current)
        let l:stack += s:tree[l:current]
      endif
    endif
  endwhile
  return #{ text: l:text, paths: l:paths }
endfunction

function! s:DisplayTree()
  call s:InitTree()

  let l:tree = s:Tree()
  let l:popup_id = popup_create(l:tree.text,
  \ #{
    \ pos: 'topleft',
    \ line: win_screenpos(0)[0],
    \ col: win_screenpos(0)[1],
    \ zindex: 2,
    \ minwidth: winwidth(0),
    \ maxwidth: winwidth(0),
    \ minheight: winheight(0),
    \ maxheight: winheight(0),
    \ drag: v:true,
    \ wrap: v:true,
    \ filter: expand('<SID>') . 'TreeFilter',
    \ mapping: v:false,
    \ scrollbar: v:true,
    \ cursorline: v:true,
  \ })
  call win_execute(l:popup_id, 'call cursor(2, 0)')
  call s:HelpTree()
endfunction

"   }}}
" }}}
" Filetype specific {{{1
"   Bash {{{2

function! s:PrefillShFile()
  call append(0, [ '#!/bin/bash',
  \                '', ])
endfunction

"   }}}
" }}}
" Mappings and Keys {{{1

function! s:Key(keys)
  let l:text = '< '
  let l:index = 1
  for l:key in a:keys
    if l:key == "\<Down>"
      let l:text = l:text . '↓'
    elseif l:key == "\<Up>"
      let l:text = l:text . '↑'
    elseif l:key == "\<Right>"
      let l:text = l:text . '→'
    elseif l:key == "\<Left>"
      let l:text = l:text . '←'
    elseif l:key == "\<S-Down>"
      let l:text = l:text . 'Shift ↓'
    elseif l:key == "\<S-Up>"
      let l:text = l:text . 'Shift ↑'
    elseif l:key == "\<S-Right>"
      let l:text = l:text . 'Shift →'
    elseif l:key == "\<S-Left>"
      let l:text = l:text . 'Shift ←'
    elseif l:key == "\<C-Down>"
      let l:text = l:text . 'Ctrl ↓'
    elseif l:key == "\<C-Up>"
      let l:text = l:text . 'Ctrl ↑'
    elseif l:key == "\<C-Right>"
      let l:text = l:text . 'Ctrl →'
    elseif l:key == "\<C-Left>"
      let l:text = l:text . 'Ctrl ←'
    elseif l:key == "\<Enter>"
      let l:text = l:text . 'Enter'
    elseif l:key == "\<Esc>"
      let l:text = l:text . 'Esc'
    elseif l:key == "\<BS>"
      let l:text = l:text . 'BackSpace'
    elseif l:key == "/"
      let l:text = l:text . 'Slash'
    elseif l:key == "\\"
      let l:text = l:text . 'BackSlash'
    elseif l:key == "|"
      let l:text = l:text . 'Bar'
    elseif l:key == "<"
      let l:text = l:text . 'Less'
    elseif l:key == ">"
      let l:text = l:text . 'Greater'
    else
      let l:text = l:text . l:key
    endif

    if l:index < len(a:keys)
      let l:text = l:text . ' | '
      let l:index += 1
    endif
  endfor
  return l:text . ' >'
endfunction

"   Vim mappings {{{2

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
if exists('s:tree_mapping') | unlet s:tree_mapping | endif
if exists('s:window_next_mapping') | unlet s:window_next_mapping | endif
if exists('s:window_previous_mapping') | unlet s:window_previous_mapping | endif
if exists('s:unfold_vim_fold_mapping') | unlet s:unfold_vim_fold_mapping | endif
if exists('s:message_command_mapping') | unlet s:message_command_mapping | endif
if exists('s:map_command_mapping') | unlet s:map_command_mapping | endif
if exists('s:autocompletion_mapping') | unlet s:autocompletion_mapping | endif
if exists('s:mksession_mapping') | unlet s:mksession_mapping | endif
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
const s:tree_mapping =                           s:shift_leader . s:shift_leader
const s:window_next_mapping =                    s:leader       .      '<Right>'
const s:window_previous_mapping =                s:leader       .       '<Left>'
const s:unfold_vim_fold_mapping =                                      '<Space>'
const s:message_command_mapping =                s:leader       .            'm'
const s:map_command_mapping =                    s:leader       .           'mm'
const s:autocompletion_mapping =                                       '<S-Tab>'
const s:mksession_mapping =                      s:leader       .            'z'
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
  \ . ' :call <SID>ToggleRedHighlight()<CR>'

" create session
execute 'nnoremap <silent> ' . s:mksession_mapping
  \ . ' :mksession!<CR>'

" animate statusline
execute 'nnoremap <silent> ' . s:animate_statusline_mapping
  \ . ' :call <SID>AnimateStatusLine()<CR>'

" Quit() functions
execute 'nnoremap <silent> ' . s:call_quit_function_mapping
  \ . ' :call <SID>Quit()<CR>'
execute 'nnoremap <silent> ' . s:call_writequit_function_mapping
  \ . ' :call <SID>WriteQuit()<CR>'

" buffers menu
execute 'nnoremap <silent> ' . s:buffers_menu_mapping
  \ . ' :call <SID>DisplayBuffersMenu()<CR>'

" tree
execute 'nnoremap <silent> ' . s:tree_mapping
  \ . ' :call <SID>DisplayTree()<CR>'

" windows navigation
execute 'nnoremap <silent> ' . s:window_next_mapping
  \ . ' :silent call <SID>NextWindow()<CR>'
execute 'nnoremap <silent> ' . s:window_previous_mapping
  \ . ' :silent call <SID>PreviousWindow()<CR>'

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

"   }}}
"   Buffers menu keys {{{2

if exists('s:next_menukey') | unlet s:next_menukey | endif
if exists('s:previous_menukey') | unlet s:previous_menukey | endif
if exists('s:select_menukey') | unlet s:select_menukey | endif
if exists('s:exit_menukey') | unlet s:exit_menukey | endif
if exists('s:select_menuchars') | unlet s:select_menuchars | endif
if exists('s:erase_menukey') | unlet s:erase_menukey | endif
if exists('s:help_menukey') | unlet s:help_menukey | endif

const s:next_menukey =      "\<Down>"
const s:previous_menukey =    "\<Up>"
const s:select_menukey =   "\<Enter>"
const s:exit_menukey =       "\<Esc>"
const s:select_menuchars =   '\d\|\$'
const s:erase_menukey =       "\<BS>"
const s:help_menukey =            "?"

"   }}}
"   Tree keys {{{2

if exists('s:next_file_treekey') | unlet s:next_file_treekey | endif
if exists('s:previous_file_treekey') | unlet s:previous_file_treekey | endif
if exists('s:first_file_treekey') | unlet s:first_file_treekey | endif
if exists('s:last_file_treekey') | unlet s:last_file_treekey | endif
if exists('s:dotfiles_treekey') | unlet s:dotfiles_treekey | endif
if exists('s:yank_treekey') | unlet s:yank_treekey | endif
if exists('s:badd_treekey') | unlet s:badd_treekey | endif
if exists('s:open_treekey') | unlet s:open_treekey | endif
if exists('s:reset_treekey') | unlet s:reset_treekey | endif
if exists('s:exit_treekey') | unlet s:exit_treekey | endif
if exists('s:help_treekey') | unlet s:help_treekey | endif
if exists('s:searchmode_treekey') | unlet s:searchmode_treekey | endif
if exists('s:next_match_treekey') | unlet s:next_match_treekey | endif
if exists('s:previous_match_treekey') | unlet s:previous_match_treekey | endif
if exists('s:left_smtreekey') | unlet s:left_smtreekey | endif
if exists('s:right_smtreekey') | unlet s:right_smtreekey | endif
if exists('s:wide_left_smtreekey') | unlet s:wide_left_smtreekey | endif
if exists('s:wide_right_smtreekey') | unlet s:wide_right_smtreekey | endif
if exists('s:next_smtreekey') | unlet s:next_smtreekey | endif
if exists('s:previous_smtreekey') | unlet s:previous_smtreekey | endif
if exists('s:evaluate_smtreekey') | unlet s:evaluate_smtreekey | endif
if exists('s:erase_smtreekey') | unlet s:erase_smtreekey | endif
if exists('s:exit_smtreekey') | unlet s:exit_smtreekey | endif

const s:next_file_treekey =        "\<Down>"
const s:previous_file_treekey =      "\<Up>"
const s:first_file_treekey =             "g"
const s:last_file_treekey =              "G"
const s:dotfiles_treekey =               "."
const s:yank_treekey =                   "y"
const s:badd_treekey =                   "b"
const s:open_treekey =                   "o"
const s:reset_treekey =                  "c"
const s:exit_treekey =              "\<Esc>"
const s:help_treekey =                   "?"
const s:searchmode_treekey =             "/"
const s:next_match_treekey =             "n"
const s:previous_match_treekey =         "N"
const s:right_smtreekey =         "\<Right>"
const s:left_smtreekey =           "\<Left>"
const s:wide_right_smtreekey =  "\<C-Right>"
const s:wide_left_smtreekey =    "\<C-Left>"
const s:next_smtreekey =           "\<Down>"
const s:previous_smtreekey =         "\<Up>"
const s:evaluate_smtreekey =      "\<Enter>"
const s:erase_smtreekey =            "\<BS>"
const s:exit_smtreekey =            "\<Esc>"

"   }}}
" }}}
" Abbreviations {{{1

" avoid intuitive write usage
cnoreabbrev w update

" avoid intuitive tabpage usage
cnoreabbrev tabe silent tabonly

" avoid intuitive quit usage
cnoreabbrev q call <SID>Quit()

" avoid intuitive exit usage
cnoreabbrev wq call <SID>WriteQuit()
cnoreabbrev x call <SID>WriteQuit()

" avoid intuitive quitall usage
cnoreabbrev qa call <SID>QuitAll()

" avoid intuitive exitall usage
cnoreabbrev wqa call <SID>WriteQuitAll()
cnoreabbrev xa call <SID>WriteQuitAll()

cnoreabbrev vb vertical sbuffer

" }}}
" Autocommands {{{1

augroup vimrc_autocomands
  autocmd!
"   Dependencies autocommands group {{{2

  autocmd VimEnter * :call <SID>CheckDependencies()

"   }}}
"   Color autocommands group {{{2

  autocmd WinEnter * set wincolor=NormalAlt

"   }}}
"   Good practices autocommands group {{{2

  autocmd BufEnter * :silent call <SID>ExtraSpaces() |
    \ silent call <SID>OverLength()

"   }}}
"   Buffers autocommands group {{{2

  autocmd BufEnter * :silent call <SID>CloseLonelyUnlistedBuffers()

"   }}}
"   Tree autocommands group {{{2

  " autocmd VimEnter * silent! autocmd! FileExplorer

"   }}}
"   Vimscript filetype autocommands group {{{2

  autocmd FileType vim setlocal foldmethod=marker

"   }}}
"   Tmux filetype autocommands group {{{2

  autocmd FileType tmux setlocal foldmethod=marker

"   }}}
"   Bash filetype autocommands group {{{2

  autocmd BufNewFile *.sh :call <SID>PrefillShFile()

"   }}}
augroup END

" }}}
