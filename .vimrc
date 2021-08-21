" TODO {{{1

" - hide buffers list only when screen moved
" - PROMPT mode breaks buffers list display

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
    let l:length = l:length - (len(StartMode()) + len(Mode()) + len(EndMode()))
    if v:hlsearch && !empty(s:matches) && (s:matches.total > 0)
      let l:length = l:length - (len(IndexedMatch()) + len(Bar())
        \ + len(TotalMatch()))
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
  let s:matches = searchcount(#{recompute: 1, maxcount: 0, timeout: 0})
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

" 5.0 * sin(localtime() / 100.0 + column + sin(column * 20.0) * 0.2)
if exists('s:dots') | unlet s:dots | endif | const s:dots = [
\  '˳', '.', '｡', '·', '•', '･', 'º', '°', '˚', '˙', 'ﾟ',
\ ]

function! Wave(start, end)
  let l:wave = ''
  for i in range(a:start, a:end - 1)
    let l:wave = l:wave . s:dots[5 + float2nr(5.0 * sin(i * (fmod(0.05 * localtime() + winnr(), 2.0) - 1.0)))]
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

function! s:WaveLine(timer_id)
  if &term[-9:] =~ '-256color'
    let s:wavecolor = fmod(s:wavecolor + 1.0, 231.0)
    if s:wavecolor < 17.0
      let s:wavecolor = 17.0
    endif
    execute '
    \ highlight User5 term=bold cterm=bold ctermfg=' . float2nr(floor(s:wavecolor)) . ' ctermbg=' . s:black
  endif

  set statusline=%5*%{StartWave()}%0*
  call StatusLineData()
  set statusline+=%5*%{EndWave()}%0*
endfunction

let s:wavecolor = 17.0
let s:animated_statusline = v:false
call StaticLine()

if exists('s:line_timer') | call timer_stop(s:line_timer) | endif
let s:line_timer = timer_start(1000, function('s:WaveLine'), {'repeat': -1})
call timer_pause(s:line_timer, v:true)

function! ToggleStatusLine()
  let s:animated_statusline = !s:animated_statusline
  if s:animated_statusline
    let s:wavecolor = 17.0
    call timer_pause(s:line_timer, v:false)
  else
    call timer_pause(s:line_timer, v:true)
    call StaticLine()
  endif
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
if exists('s:grey') | unlet s:grey | endif
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
const s:grey = 236
const s:black = 232

"   }}}
"   Scheme {{{2

let s:redhighlight_cmd = 'highlight RedHighlight ctermfg=White ctermbg=DarkRed'

if &term[-9:] =~ '-256color'

  set background=dark | highlight clear | if exists('syntax_on') | syntax reset | endif
  set wincolor=NormalAlt

  execute 'highlight       CurrentBuffer  term=bold           cterm=bold         ctermfg=' . s:black    . ' ctermbg=' . s:green_1  . ' |
    \      highlight       ActiveBuffer   term=bold           cterm=bold         ctermfg=' . s:green_2  . ' ctermbg=' . s:grey     . ' |
    \      highlight       Normal         term=bold           cterm=bold         ctermfg=' . s:orange_3 . ' ctermbg=' . s:black    . ' |
    \      highlight       NormalAlt      term=NONE           cterm=NONE         ctermfg=' . s:white_2  . ' ctermbg=' . s:black    . ' |
    \      highlight       ModeMsg        term=NONE           cterm=NONE         ctermfg=' . s:blue_2   . ' ctermbg=' . s:black    . ' |
    \      highlight       MoreMsg        term=NONE           cterm=NONE         ctermfg=' . s:blue_3   . ' ctermbg=' . s:black    . ' |
    \      highlight       Question       term=NONE           cterm=NONE         ctermfg=' . s:blue_3   . ' ctermbg=' . s:black    . ' |
    \      highlight       NonText        term=NONE           cterm=NONE         ctermfg=' . s:orange_1 . ' ctermbg=' . s:black    . ' |
    \      highlight       Comment        term=NONE           cterm=NONE         ctermfg=' . s:purple_2 . ' ctermbg=' . s:black    . ' |
    \      highlight       Constant       term=NONE           cterm=NONE         ctermfg=' . s:blue_1   . ' ctermbg=' . s:black    . ' |
    \      highlight       Special        term=NONE           cterm=NONE         ctermfg=' . s:blue_2   . ' ctermbg=' . s:black    . ' |
    \      highlight       Identifier     term=NONE           cterm=NONE         ctermfg=' . s:blue_3   . ' ctermbg=' . s:black    . ' |
    \      highlight       Statement      term=NONE           cterm=NONE         ctermfg=' . s:red      . ' ctermbg=' . s:black    . ' |
    \      highlight       PreProc        term=NONE           cterm=NONE         ctermfg=' . s:purple_2 . ' ctermbg=' . s:black    . ' |
    \      highlight       Type           term=NONE           cterm=NONE         ctermfg=' . s:blue_3   . ' ctermbg=' . s:black    . ' |
    \      highlight       Visual         term=reverse        cterm=reverse                                 ctermbg=' . s:black    . ' |
    \      highlight       LineNr         term=NONE           cterm=NONE         ctermfg=' . s:green_1  . ' ctermbg=' . s:black    . ' |
    \      highlight       Search         term=reverse        cterm=reverse      ctermfg=' . s:green_1  . ' ctermbg=' . s:black    . ' |
    \      highlight       IncSearch      term=reverse        cterm=reverse      ctermfg=' . s:green_1  . ' ctermbg=' . s:black    . ' |
    \      highlight       Tag            term=NONE           cterm=NONE         ctermfg=' . s:blue_3   . ' ctermbg=' . s:black    . ' |
    \      highlight       Error                                                 ctermfg=' . s:black    . ' ctermbg=' . s:red      . ' |
    \      highlight       ErrorMsg       term=bold           cterm=bold         ctermfg=' . s:red      . ' ctermbg=' . s:black    . ' |
    \      highlight       Todo           term=standout                          ctermfg=' . s:black    . ' ctermbg=' . s:blue_1   . ' |
    \      highlight       StatusLine     term=bold           cterm=bold         ctermfg=' . s:blue_4   . ' ctermbg=' . s:black    . ' |
    \      highlight       StatusLineNC   term=NONE           cterm=NONE         ctermfg=' . s:blue_1   . ' ctermbg=' . s:black    . ' |
    \      highlight       Folded         term=NONE           cterm=NONE         ctermfg=' . s:black    . ' ctermbg=' . s:orange_2 . ' |
    \      highlight       VertSplit      term=NONE           cterm=NONE         ctermfg=' . s:purple_2 . ' ctermbg=' . s:black    . ' |
    \      highlight       CursorLine     term=bold,reverse   cterm=bold,reverse ctermfg=' . s:blue_4   . ' ctermbg=' . s:black    . ' |
    \      highlight       MatchParen     term=bold           cterm=bold         ctermfg=' . s:purple_1 . ' ctermbg=' . s:white_1  . ' |
    \      highlight       PMenu          term=bold           cterm=bold         ctermfg=' . s:green_1  . ' ctermbg=' . s:black    . ' |
    \      highlight       User1          term=bold           cterm=bold         ctermfg=' . s:pink     . ' ctermbg=' . s:black    . ' |
    \      highlight       User2          term=bold           cterm=bold         ctermfg=' . s:green_2  . ' ctermbg=' . s:black    . ' |
    \      highlight       User3          term=bold           cterm=bold         ctermfg=' . s:orange_3 . ' ctermbg=' . s:black
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
  highlight       CurrentBuffer  term=bold           cterm=bold           ctermfg=Black     ctermbg=DarkRed
  highlight       ActiveBuffer   term=bold           cterm=bold           ctermfg=Red       ctermbg=DarkGrey
  highlight       PMenu          term=NONE           cterm=NONE           ctermfg=White     ctermbg=NONE
  highlight       StatusLine     term=bold           cterm=bold           ctermfg=LightBlue ctermbg=NONE
  highlight       StatusLineNC   term=NONE           cterm=NONE           ctermfg=Blue      ctermbg=NONE
  highlight       User1          term=bold           cterm=bold           ctermfg=Red       ctermbg=NONE
  highlight       User2          term=bold           cterm=bold           ctermfg=Green     ctermbg=NONE
  highlight       User3          term=bold           cterm=bold           ctermfg=Yellow    ctermbg=NONE
endif

highlight         User4          term=bold           cterm=bold           ctermfg=Red
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
  return len(filter(getbufinfo({'buflisted':1}), '!v:val.hidden'))
endfunction

" close Vim if only unlisted-buffers are active
function! CloseLonelyUnlistedBuffers()
  if ActiveListedBuffers() == 0
    quitall
  endif
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

    let l:dict = maparg(s:buffer_next_mapping, 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer
        execute 'nunmap <buffer> ' . s:buffer_next_mapping
      endif
    endif

    let l:dict = maparg(s:buffer_previous_mapping, 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer
        execute 'nunmap <buffer> ' . s:buffer_previous_mapping
      endif
    endif

    let l:dict = maparg(s:buffers_menu_mapping, 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer
        execute 'nunmap <buffer> ' . s:buffers_menu_mapping
      endif
    endif

    let l:dict = maparg(s:toggle_nerdtree_mapping, 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer
        execute 'nunmap <buffer> ' . s:toggle_nerdtree_mapping
      endif
    endif

    let l:dict = maparg(s:search_and_replace_mapping, 'v', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer
        execute 'vunmap <buffer> ' . s:search_and_replace_mapping
      endif
    endif

    let l:dict = maparg(s:search_and_replace_insensitive_mapping, 'v',
      \ v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer
        execute 'vunmap <buffer> ' . s:search_and_replace_insensitive_mapping
      endif
    endif

    let l:dict = maparg(s:vsplit_vimrc_mapping, 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer
        execute 'nunmap <buffer> ' . s:vsplit_vimrc_mapping
      endif
    endif

    let l:dict = maparg(s:call_quit_function_mapping, 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer
        execute 'nunmap <buffer> ' . s:call_quit_function_mapping
      endif
    endif

    let l:dict = maparg(s:call_writequit_function_mapping, 'n', v:false,
      \ v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer
        execute 'nunmap <buffer> ' . s:call_writequit_function_mapping
      endif
    endif

  endif
endfunction

"   }}}
"   Unlisted-Buffers {{{2

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

    let l:dict = maparg(s:buffer_next_mapping, 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer == v:false
        execute 'nnoremap <buffer> ' . s:buffer_next_mapping . ' <Esc>'
      endif
    else
      execute 'nnoremap <buffer> ' . s:buffer_next_mapping . ' <Esc>'
    endif

    let l:dict = maparg(s:buffer_previous_mapping, 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer == v:false
        execute 'nnoremap <buffer> ' . s:buffer_previous_mapping . ' <Esc>'
      endif
    else
      execute 'nnoremap <buffer> ' . s:buffer_previous_mapping . ' <Esc>'
    endif

    let l:dict = maparg(s:buffers_menu_mapping, 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer == v:false
        execute 'nnoremap <buffer> ' . s:buffers_menu_mapping . ' <Esc>'
      endif
    else
      execute 'nnoremap <buffer> ' . s:buffers_menu_mapping . ' <Esc>'
    endif

    let l:dict = maparg(s:toggle_nerdtree_mapping, 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer == v:false
        execute 'nnoremap <buffer> ' . s:toggle_nerdtree_mapping . ' <Esc>'
      endif
    else
      execute 'nnoremap <buffer> ' . s:toggle_nerdtree_mapping . ' <Esc>'
    endif

    let l:dict = maparg(s:search_and_replace_mapping, 'v', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer == v:false
        execute 'vnoremap <buffer> ' . s:search_and_replace_mapping . ' <Esc>'
      endif
    else
      execute 'vnoremap <buffer> ' . s:search_and_replace_mapping . ' <Esc>'
    endif

    let l:dict = maparg(s:search_and_replace_insensitive_mapping, 'v',
      \ v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer == v:false
        execute 'vnoremap <buffer> '
          \ . s:search_and_replace_insensitive_mapping . ' <Esc>'
      endif
    else
      execute 'vnoremap <buffer> ' . s:search_and_replace_insensitive_mapping
        \ . ' <Esc>'
    endif

    let l:dict = maparg(s:vsplit_vimrc_mapping, 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer == v:false
        execute 'nnoremap <buffer> ' . s:vsplit_vimrc_mapping . ' <Esc>'
      endif
    else
      execute 'nnoremap <buffer> ' . s:vsplit_vimrc_mapping . ' <Esc>'
    endif

    let l:dict = maparg(s:call_quit_function_mapping, 'n', v:false, v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer == v:false
        execute 'nnoremap <buffer> ' . s:call_quit_function_mapping . ' <Esc>'
      endif
    else
      execute 'nnoremap <buffer> ' . s:call_quit_function_mapping . ' <Esc>'
    endif

    let l:dict = maparg(s:call_writequit_function_mapping, 'n', v:false,
      \ v:true)
    if has_key(l:dict, 'buffer')
      if l:dict.buffer == v:false
        execute 'nnoremap <buffer> ' . s:call_writequit_function_mapping
          \ . ' <Esc>'
      endif
    else
      execute 'nnoremap <buffer> ' . s:call_writequit_function_mapping
        \ . ' <Esc>'
    endif

  endif
endfunction

"   }}}
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
      \ !empty(filter(getbufinfo({'buflisted':1}), 'v:val.hidden'))

    if !l:more_than_one_window && !l:at_least_one_hidden_listedbuf
      silent quit
      return v:true
    endif

    " case 3:                                   current
    "   (==1) win & (==0) unlisted-buf & (==1) listed-buf & (>=1) hidden-buf
    let l:lastused_hiddenbuf = 1
    if l:at_least_one_hidden_listedbuf
      let l:lastused_hiddenbuf = map(sort(filter(getbufinfo(
        \ {'buflisted':1}), 'v:val.hidden'),
        \ {x, y -> y.lastused - x.lastused}), {key, val -> val.bufnr})[0]
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
    for i in getbufinfo()->map({key, val -> len(val.windows)})
      let l:unlistedbuf_nb = l:unlistedbuf_nb + i
    endfor

    echoerr 'Personal Error Message: this Quit() case is not expected,'
      \ . ' you have to define it: ' . winnr('$') . ' Window(s) & '
      \ . l:unlistedbuf_nb . ' Unlisted-Buffer(s) & '
      \ . len(getbufinfo({'buflisted':1})) . ' Listed-Buffer(s) & '
      \ . len(filter(getbufinfo({'buflisted':1}), 'v:val.hidden'))
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
"   Timer & Popups functions {{{2

" timer variables
if exists('s:tick') | unlet s:tick | endif | const s:tick = 100
if exists('s:nb_ticks') | unlet s:nb_ticks | endif | const s:nb_ticks = 50
let s:elapsed_time = s:nb_ticks * s:tick
let s:lasttick_sizebuflist = len(getbufinfo({'buflisted':1}))
let s:lasttick_buffer = bufnr()

" cursor variable
let s:lastcursor_line = line('.')

" resize the commandline, display listed buffers, highlight current
" buffer and underline active buffers
function! DisplayBuffersList()
  let l:listed_buf = getbufinfo({'buflisted':1})
  let l:listedbuf_nb = len(l:listed_buf)

  if l:listedbuf_nb < 1
    return
  endif

  let l:index = &lines - l:listedbuf_nb

  execute 'set cmdheight=' . (l:listedbuf_nb + 2)
  call popup_clear() | call popup_create(repeat('━', &columns),
    \ #{ pos: 'topleft', line: l:index, col: 1, highlight: 'StatusLine' })

  for l:buf in l:listed_buf
    let l:line = ' ' . l:buf.bufnr . ': "' . fnamemodify(l:buf.name, ':.')
      \ . '"'
    let l:line = l:line . repeat(' ', &columns - strlen(l:line))

    let l:highlight = 'PMenu'
    if l:buf.bufnr == bufnr()
      let l:highlight = 'CurrentBuffer'
    elseif !l:buf.hidden
      let l:highlight = 'ActiveBuffer'
    endif

    let l:index = l:index + 1
    call popup_create(l:line, #{ pos: 'topleft', line: l:index, col: 1,
      \ highlight: l:highlight })
  endfor
endfunction

function! StartTimer()
  let s:elapsed_time = 0
endfunction

function! StopTimer()
  let s:elapsed_time = s:nb_ticks * s:tick
endfunction

function! HideBuffersList()
  let l:current_cursor_line = line('.')
  if s:lastcursor_line != l:current_cursor_line
    call StopTimer()
    let s:lastcursor_line = l:current_cursor_line
  endif
endfunction

function! s:MonitorBuffersList(timer_id)
  let l:current_sizebufist = len(getbufinfo({'buflisted':1}))
  let l:current_buffer = bufnr()

  " monitor 2 events:
  " - adding/deleting listed-buffers,
  " - moving current buffer to another buffer.
  if (s:lasttick_sizebuflist != l:current_sizebufist) ||
  \ (s:lasttick_buffer != l:current_buffer)
    call StartTimer()
  endif

  " update buffers list
  if s:elapsed_time == 0
    let s:elapsed_time = s:elapsed_time + s:tick
    call DisplayBuffersList()
  elseif (s:elapsed_time > 0) && (s:elapsed_time < s:nb_ticks * s:tick)
    let s:elapsed_time = s:elapsed_time + s:tick
  elseif (s:elapsed_time == s:nb_ticks * s:tick)
    let s:elapsed_time = s:elapsed_time + s:tick
    set cmdheight=1 | call popup_clear()
  endif

  " avoid commandline and risky commands for unlisted-buffers
  if buflisted(l:current_buffer)
    call EnableMappingsListedBuffer()
  else
    call DisableMappingsUnlistedBuffer()
  endif

  let s:lasttick_sizebuflist = l:current_sizebufist
  let s:lasttick_buffer = l:current_buffer
endfunction

" disable timers accumulation after sourcing vimrc
if exists('s:timer') | call timer_stop(s:timer) | endif | let s:timer =
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
  if v:version < 802
    let l:major_version = v:version / 100
    echoerr 'Personal Error Message: your VimRC needs Vim 8.2 to be'
      \ . ' functionnal. Your Vim version is ' l:major_version . '.'
      \ . (v:version - l:major_version * 100)
    quit
  endif

  if !exists('g:NERDTree') || !exists('g:NERDTreeMapOpenInTab') ||
  \ !exists('g:NERDTreeMapOpenInTabSilent') ||
  \ !exists('g:NERDTreeMapOpenSplit') || !exists('g:NERDTreeMapOpenVSplit') ||
  \ !exists('g:NERDTreeMapOpenExpl') || !exists('g:NERDTreeNaturalSort') ||
  \ !exists('g:NERDTreeHighlightCursorline') || !exists(':NERDTreeToggle') ||
  \ !exists('g:NERDTreeMouseMode') || !exists('g:NERDTreeHijackNetrw')
    echoerr 'Personal Error Message: your VimRC needs NERDTree plugin'
      \ . ' to be functionnal'
    quit
  endif
endfunction

"   NERDTree {{{2

" unused NERDTree tabpage commands
let g:NERDTreeMapOpenInTab = ''
let g:NERDTreeMapOpenInTabSilent = ''

" disable splitting window with NERDTree
let g:NERDTreeMapOpenSplit = ''
let g:NERDTreeMapOpenVSplit = ''

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
  if buflisted(a:buf)
    execute 'silent buffer ' . a:buf
  else
    echoerr 'Personal Error Message: selected buffer is not listed'
  endif
endfunction

command -nargs=1 ActivateBuffer call ActivateBuffer(<args>)

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
if exists('s:toggle_nerdtree_mapping') | unlet s:toggle_nerdtree_mapping | endif
if exists('s:call_quit_function_mapping') | unlet s:call_quit_function_mapping | endif
if exists('s:call_writequit_function_mapping') | unlet s:call_writequit_function_mapping | endif
if exists('s:buffers_menu_mapping') | unlet s:buffers_menu_mapping | endif
if exists('s:buffer_next_mapping') | unlet s:buffer_next_mapping | endif
if exists('s:buffer_previous_mapping') | unlet s:buffer_previous_mapping | endif
if exists('s:window_next_mapping') | unlet s:window_next_mapping | endif
if exists('s:window_previous_mapping') | unlet s:window_previous_mapping | endif
if exists('s:unfold_vim_fold_mapping') | unlet s:unfold_vim_fold_mapping | endif
if exists('s:message_command_mapping') | unlet s:message_command_mapping | endif
if exists('s:map_command_mapping') | unlet s:map_command_mapping | endif
if exists('s:autocompletion_mapping') | unlet s:autocompletion_mapping | endif

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
const s:toggle_nerdtree_mapping =                s:shift_leader . s:shift_leader
const s:toggle_statusline_mapping =              s:leader       .            's'
const s:call_quit_function_mapping =             s:leader       .            'q'
const s:call_writequit_function_mapping =        s:leader       .            'w'
const s:buffers_menu_mapping =                   s:leader       .       s:leader
const s:buffer_next_mapping =                                                'K'
const s:buffer_previous_mapping =                                            'J'
const s:window_next_mapping =                                                'L'
const s:window_previous_mapping =                                            'H'
const s:unfold_vim_fold_mapping =                                      '<Space>'
const s:message_command_mapping =                s:leader       .            'm'
const s:map_command_mapping =                    s:leader       .           'mm'
const s:autocompletion_mapping =                                       '<S-Tab>'

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

" open NERDTree in a vertical split window
execute 'nnoremap <silent> ' . s:toggle_nerdtree_mapping
  \ . ' :NERDTreeToggle<CR>'

" toggle statusline
execute 'nnoremap <silent> ' . s:toggle_statusline_mapping
  \ . ' :call ToggleStatusLine()<CR>'

" Quit() functions
execute 'nnoremap <silent> ' . s:call_quit_function_mapping
  \ . ' :call Quit()<CR>'
execute 'nnoremap <silent> ' . s:call_writequit_function_mapping
  \ . ' :call WriteQuit()<CR>'

" buffers menu
execute 'nnoremap '          . s:buffers_menu_mapping
  \ . ' :call StartTimer()<CR>:ActivateBuffer<Space>'

" buffers navigation
execute 'nnoremap <silent> ' . s:buffer_next_mapping
  \ . ' :silent bnext<CR>'
execute 'nnoremap <silent> ' . s:buffer_previous_mapping
  \ . ' :silent bprevious<CR>'

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

" avoid intuitive buffer usage
cnoreabbrev b call StartTimer()<CR>:ActivateBuffer

" }}}
" Autocommands {{{1

augroup vimrc_autocomands
  autocmd!
"   Dependencies Autocommands Group {{{2

  autocmd VimEnter * :call CheckDependencies()

"   }}}
"   Fixing Autocommands Group {{{2

  " hide buffers list when cursor is scrolling
  autocmd CursorMoved,CursorMovedI * :call HideBuffersList()

"   }}}
"   Color Autocommands Group {{{2

  autocmd WinEnter * set wincolor=NormalAlt

"   }}}
"   Good Practices Autocommands Group {{{2

  autocmd BufEnter * :silent call ExtraSpaces() | silent call OverLength()

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
