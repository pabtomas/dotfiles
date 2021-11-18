" Ideas {{{1

" - replace system()/systemlist() calls with job_start() ?
" - explorer: - hijack netrw ?

" }}}
" TODO {{{1

" - plugins: taglist

" }}}
" Dependencies {{{1

function! s:CheckDependencies()
  if !has('unix')
    echoerr 'Personal Error Message: your VimRC needs UNIX OS to be'
      \ . ' functionnal'
  endif
  if v:version < 802
    let l:major_version = v:version / 100
    echoerr 'Personal Error Message: your VimRC needs Vim 8.2 to be'
      \ . ' functionnal. Your Vim version is ' l:major_version . '.'
      \ . (v:version - l:major_version * 100)
    quit
  endif
endfunction

" }}}
" Quality of life {{{1
"   Options {{{2

" Vi default options unused
set nocompatible

" allow mouse use
set mouse=a

" view tabulation, end of line and other hidden characters
syntax on
set list
set listchars=eol:.,tab:>>
set fillchars=vert:│,fold:-,eob:∼

" highlight corresponding patterns during a search
if !&hlsearch | set hlsearch | endif
if !&incsearch | set incsearch | endif

" line number
set number

" put the new window right of the current one
set splitright

" put the new window below of the current one
set splitbelow

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

" more commands saved in history
set history=2000

" more undo saved
set undolevels=2000

" highlight and marks not restored
set viminfo='0,f0,h

" vimdiff vertical splits
set diffopt=vertical

" write swap files to disk and trigger CursorHold event faster
set updatetime=200

" use popup menu & additional info when completion is used
set completeopt=menu,preview

" stop beeping
set noerrorbells
set visualbell

" specify which shell use with shell commands
set shell=bash

" more pairs for % command and MatchParen highlight
set matchpairs+=<:>

"     Performance {{{3

" draw only when needed
set lazyredraw

" indicates terminal connection
set ttyfast

"     }}}
"   }}}
"   Search {{{2
"     Variables & constants {{{3

if exists('s:search') | unlet s:search | endif
const s:search = #{
\   sensitive_replace: ':s/\%V//g<Left><Left><Left>',
\   insensitive_replace: ':s/\%V\c//g<Left><Left><Left>',
\   insensitive: '/\c',
\ }

"     }}}
"     Functions {{{3

function! s:NextSearch()
  normal! n
  if foldlevel('.') > 0
    foldopen!
  endif
  normal! zz
endfunction

function! s:PreviousSearch()
  normal! N
  if foldlevel('.') > 0
    foldopen!
  endif
  normal! zz
endfunction

"     }}}
"   }}}
"   Buffers {{{2
"     Options {{{3

" allow to switch between buffers without writting them
set hidden

" use already opened buffers instead of loading it in a new window
set switchbuf=useopen

"     }}}
"     Functions {{{3

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

"     }}}
"   }}}
"   Windows {{{2

function! s:NextWindow()
  if empty(getcmdwintype())
    if winnr() < winnr('$')
      execute winnr() + 1 . 'wincmd w'
    else
      1wincmd w
    endif
  endif
endfunction

function! s:PreviousWindow()
  if empty(getcmdwintype())
    if winnr() > 1
      execute winnr() - 1 . 'wincmd w'
    else
      execute winnr('$') . 'wincmd w'
    endif
  endif
endfunction

"   }}}
"   Visual {{{2
"     Options {{{3

" avoid visual mod lags
set noshowcmd

"     }}}
"     Functions {{{3

function! s:VisualUp()
  if line('.') - v:count1 > 0
    execute "'" . '<,' . "'" . '>move ' . "'" . '<-' . (v:count1 + 1)
  else
    '<,'>move 0
  endif
  normal! gv
endfunction

function! s:VisualDown()
  if line('.') + line("'>") - line ("'<") + v:count1 > line('$')
    '<,'>move $
  else
    execute "'" . '<,' . "'" . '>move ' . "'" . '>+' . v:count1
  endif
  normal! gv
endfunction

"     }}}
"   }}}
"   Blank {{{2

function! s:BlankUp()
  call append(line('.') - 1, repeat([''], v:count1))
endfunction

function! s:BlankDown()
  call append(line('.'), repeat([''], v:count1))
endfunction

"   }}}
"   Redhighlight {{{2
"     Variables & constants {{{3

let s:redhighlight = #{
\   activated: v:true,
\   command: 'highlight RedHighlight term=NONE cterm=NONE ctermfg=White ctermbg=DarkRed',
\ }

"     }}}
"     Functions {{{3

function! s:RedHighlight()
  if buflisted(bufnr())
    if empty(filter(map(getmatches(), { _, val -> val.group }),
    \ 'v:val == "RedHighlight"'))
      " highlight unused spaces before the end of the line
      call matchadd('RedHighlight', '\v\s+$')
      " highlight characters which overpass 80 columns
      call matchadd('RedHighlight', '\v%80v.*')
    endif
  endif
endfunction

" clear/add red highlight matching patterns
function! s:ToggleRedHighlight()
  if s:redhighlight.activated
    highlight clear RedHighlight | set synmaxcol=3000
  else
    execute s:redhighlight.command | set synmaxcol=200
  endif
  let s:redhighlight.activated = !s:redhighlight.activated
endfunction

"     }}}
"   }}}
"   VimRC {{{2

function! s:OpenVimRC()
  vsplit $MYVIMRC
endfunction

if !exists("*s:SourceVimRC")
  function! s:SourceVimRC()
    execute 'source ' . $MYVIMRC
    call s:HighlightStatusLines()
  endfunction
endif

"   }}}
" }}}
" Style {{{1
"   Palette {{{2

if exists('s:palette') | unlet s:palette | endif
const s:palette = #{
\   red_1: 196,
\   red_2: 1,
\   pink: 205,
\   orange_1: 202,
\   orange_2: 209,
\   orange_3: 216,
\   purple_1: 62,
\   purple_2: 140,
\   purple_3: 176,
\   blue_1: 69,
\   blue_2: 105,
\   blue_3: 111,
\   blue_4: 45,
\   green_1: 42,
\   green_2: 120,
\   green_3: 2,
\   white_1: 147,
\   white_2: 153,
\   white_3: 255,
\   grey_1: 236,
\   grey_2: 244,
\   grey_3: 248,
\   black: 232,
\ }

"   }}}
"   Colorscheme {{{2

function s:LoadColorscheme()
  set t_Co=256
  set t_ut=
  set background=dark
  if exists('g:syntax_on') | syntax reset | endif
  set wincolor=NormalAlt

  highlight clear
  execute  'highlight       Buffer              cterm=bold         ctermfg=' . s:palette.grey_2   . ' ctermbg=' . s:palette.black
    \ . ' | highlight       ModifiedBuf         cterm=bold         ctermfg=' . s:palette.red_1
    \ . ' | highlight       BuffersMenuBorders  cterm=bold         ctermfg=' . s:palette.blue_4
    \ . ' | highlight       RootPath            cterm=bold         ctermfg=' . s:palette.pink     . ' ctermbg=' . s:palette.black
    \ . ' | highlight       ClosedDirPath       cterm=bold         ctermfg=' . s:palette.green_2  . ' ctermbg=' . s:palette.black
    \ . ' | highlight       OpenedDirPath       cterm=bold         ctermfg=' . s:palette.green_1  . ' ctermbg=' . s:palette.black
    \ . ' | highlight       FilePath            cterm=NONE         ctermfg=' . s:palette.white_2  . ' ctermbg=' . s:palette.black
    \ . ' | highlight       Help                cterm=bold         ctermfg=' . s:palette.purple_2 . ' ctermbg=' . s:palette.black
    \ . ' | highlight       HelpKey             cterm=bold         ctermfg=' . s:palette.pink     . ' ctermbg=' . s:palette.black
    \ . ' | highlight       HelpMode            cterm=bold         ctermfg=' . s:palette.green_1  . ' ctermbg=' . s:palette.black
    \ . ' | highlight       DiffAdd             cterm=NONE         ctermfg=' . s:palette.green_3  . ' ctermbg=' . s:palette.black
    \ . ' | highlight       DiffDelete          cterm=NONE         ctermfg=' . s:palette.red_2    . ' ctermbg=' . s:palette.black
    \ . ' | highlight       Button              cterm=bold,reverse ctermfg=' . s:palette.blue_4   . ' ctermbg=' . s:palette.black
    \ . ' | highlight       Normal              cterm=bold         ctermfg=' . s:palette.purple_2 . ' ctermbg=' . s:palette.black
    \ . ' | highlight       NormalAlt           cterm=NONE         ctermfg=' . s:palette.white_2  . ' ctermbg=' . s:palette.black
    \ . ' | highlight       ModeMsg             cterm=NONE         ctermfg=' . s:palette.blue_2   . ' ctermbg=' . s:palette.black
    \ . ' | highlight       MoreMsg             cterm=NONE         ctermfg=' . s:palette.blue_3   . ' ctermbg=' . s:palette.black
    \ . ' | highlight       Question            cterm=NONE         ctermfg=' . s:palette.blue_3   . ' ctermbg=' . s:palette.black
    \ . ' | highlight       NonText             cterm=NONE         ctermfg=' . s:palette.orange_1 . ' ctermbg=' . s:palette.black
    \ . ' | highlight       Comment             cterm=NONE         ctermfg=' . s:palette.purple_2 . ' ctermbg=' . s:palette.black
    \ . ' | highlight       Constant            cterm=NONE         ctermfg=' . s:palette.blue_1   . ' ctermbg=' . s:palette.black
    \ . ' | highlight       Special             cterm=NONE         ctermfg=' . s:palette.blue_2   . ' ctermbg=' . s:palette.black
    \ . ' | highlight       Identifier          cterm=NONE         ctermfg=' . s:palette.blue_3   . ' ctermbg=' . s:palette.black
    \ . ' | highlight       Statement           cterm=NONE         ctermfg=' . s:palette.red_1    . ' ctermbg=' . s:palette.black
    \ . ' | highlight       PreProc             cterm=NONE         ctermfg=' . s:palette.purple_2 . ' ctermbg=' . s:palette.black
    \ . ' | highlight       Type                cterm=NONE         ctermfg=' . s:palette.blue_3   . ' ctermbg=' . s:palette.black
    \ . ' | highlight       Visual              cterm=reverse      ctermbg=' . s:palette.black
    \ . ' | highlight       LineNr              cterm=NONE         ctermfg=' . s:palette.green_1  . ' ctermbg=' . s:palette.black
    \ . ' | highlight       Search              cterm=reverse      ctermfg=' . s:palette.pink     . ' ctermbg=' . s:palette.black
    \ . ' | highlight       IncSearch           cterm=reverse      ctermfg=' . s:palette.pink     . ' ctermbg=' . s:palette.black
    \ . ' | highlight       Tag                 cterm=underline'
    \ . ' | highlight       Error                                  ctermfg=' . s:palette.black    . ' ctermbg=' . s:palette.red_1
    \ . ' | highlight       ErrorMsg            cterm=bold         ctermfg=' . s:palette.red_1    . ' ctermbg=' . s:palette.black
    \ . ' | highlight       Todo                                   ctermfg=' . s:palette.black    . ' ctermbg=' . s:palette.blue_1
    \ . ' | highlight       StatusLine          cterm=bold         ctermfg=' . s:palette.blue_4   . ' ctermbg=' . s:palette.black
    \ . ' | highlight       StatusLineNC        cterm=NONE         ctermfg=' . s:palette.blue_1   . ' ctermbg=' . s:palette.black
    \ . ' | highlight       Folded              cterm=NONE         ctermfg=' . s:palette.black    . ' ctermbg=' . s:palette.orange_2
    \ . ' | highlight       VertSplit           cterm=NONE         ctermfg=' . s:palette.purple_2 . ' ctermbg=' . s:palette.black
    \ . ' | highlight       CursorLine          cterm=bold,reverse ctermfg=' . s:palette.blue_4   . ' ctermbg=' . s:palette.black
    \ . ' | highlight       MatchParen          cterm=bold         ctermfg=' . s:palette.purple_1 . ' ctermbg=' . s:palette.white_1
    \ . ' | highlight       Pmenu               cterm=bold         ctermfg=' . s:palette.green_1  . ' ctermbg=' . s:palette.black
    \ . ' | highlight       PopupSelected       cterm=bold         ctermfg=' . s:palette.black    . ' ctermbg=' . s:palette.purple_2
    \ . ' | highlight       PmenuSbar           cterm=NONE         ctermfg=' . s:palette.black    . ' ctermbg=' . s:palette.blue_3
    \ . ' | highlight       PmenuThumb          cterm=NONE         ctermfg=' . s:palette.black    . ' ctermbg=' . s:palette.blue_1
    \ . ' | highlight       User1               cterm=bold         ctermfg=' . s:palette.pink     . ' ctermbg=' . s:palette.black
    \ . ' | highlight       User2               cterm=bold         ctermfg=' . s:palette.green_2  . ' ctermbg=' . s:palette.black
    \ . ' | highlight       User3               cterm=bold         ctermfg=' . s:palette.orange_3 . ' ctermbg=' . s:palette.black
    \ . ' | highlight       User4               cterm=bold         ctermfg=' . s:palette.red_2
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
  highlight  link SpecialKey         Special
  highlight  link Debug              Special

  if s:redhighlight.activated | execute s:redhighlight.command | endif
endfunction

call s:LoadColorscheme()

"   }}}
"   Text properties {{{2

if index(prop_type_list(), 'statusline') != -1 | call prop_type_delete('statusline') | endif
if index(prop_type_list(), 'key')        != -1 | call prop_type_delete('key')        | endif
if index(prop_type_list(), 'help')       != -1 | call prop_type_delete('help')       | endif
if index(prop_type_list(), 'mode')       != -1 | call prop_type_delete('mode')       | endif

call prop_type_add('statusline', #{ highlight: 'StatusLine' })
call prop_type_add('key',        #{ highlight: 'HelpKey'    })
call prop_type_add('help',       #{ highlight: 'Help'       })
call prop_type_add('mode',       #{ highlight: 'HelpMode'   })

"     Buffers menu {{{3

if index(prop_type_list(), 'buf')      != -1 | call prop_type_delete('buf')      | endif
if index(prop_type_list(), 'modified') != -1 | call prop_type_delete('modified') | endif

call prop_type_add('buf',      #{ highlight: 'Buffer'      })
call prop_type_add('modified', #{ highlight: 'ModifiedBuf' })

"     }}}
"     Explorer {{{3

if index(prop_type_list(), 'root')   != -1 | call prop_type_delete('root')   | endif
if index(prop_type_list(), 'file')   != -1 | call prop_type_delete('file')   | endif
if index(prop_type_list(), 'closed') != -1 | call prop_type_delete('closed') | endif
if index(prop_type_list(), 'opened') != -1 | call prop_type_delete('opened') | endif

call prop_type_add('root',   #{ highlight: 'RootPath'      })
call prop_type_add('file',   #{ highlight: 'FilePath'      })
call prop_type_add('closed', #{ highlight: 'ClosedDirPath' })
call prop_type_add('opened', #{ highlight: 'OpenedDirPath' })

"     }}}
"     Undotree {{{3

if index(prop_type_list(), 'button')     != -1 | call prop_type_delete('button')     | endif
if index(prop_type_list(), 'diffadd')    != -1 | call prop_type_delete('diffadd')    | endif
if index(prop_type_list(), 'diffdelete') != -1 | call prop_type_delete('diffdelete') | endif

call prop_type_add('button',     #{ highlight: 'Button'     })
call prop_type_add('diffadd',    #{ highlight: 'DiffAdd'    })
call prop_type_add('diffdelete', #{ highlight: 'DiffDelete' })

"     }}}
"   }}}
"   Folds {{{2
"     Functions {{{3

function! s:Unfold()
  normal za
endfunction

function! FoldText()
  return substitute(substitute(foldtext(), '\s*\(\d\+\)',
    \ repeat('-', 10 - len(string(v:foldend - v:foldstart + 1))) . ' [\1', ''),
    \ '\(\a\+\)\s\?: ["#]\s\+', '\1] ', '')
endfunction

"     }}}
"     Options {{{3

set foldtext=FoldText()

" gg and G normal map open folds
set foldopen+=jump

"     }}}
"   }}}
" }}}
" Plugins {{{1
"   Tinsel {{{2
"     Options {{{3

" display status line
set laststatus=2

"     }}}
"     Variables & constants {{{3

let s:tinsel = #{
\   modes: {
\     'n': 'NORMAL', 'i': 'INSERT', 'R': 'REPLACE', 'v': 'VISUAL',
\     'V': 'VISUAL', "\<C-v>": 'VISUAL-BLOCK', 'c': 'COMMAND', 's': 'SELECT',
\     'S': 'SELECT-LINE', "\<C-s>": 'SELECT-BLOCK', 't': 'TERMINAL',
\     'r': 'PROMPT', '!': 'SHELL',
\   },
\   dots: [
\    '˳', '.', '｡', '·', '•', '･', 'º', '°', '˚', '˙',
\   ],
\   spectrum: [
\     51, 45, 39, 33, 27, 21, 57, 93, 129, 165, 201, 200, 199, 198, 197, 196,
\     202, 208, 214, 220, 226, 190, 154, 118, 82, 46, 47, 48, 49, 50,
\   ],
\   color: 0.0,
\   localtime: localtime(),
\   start: localtime(),
\   matches: {},
\ }

"     }}}
"     Functions {{{3

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
    \ + len(' [') + len(&filetype) + len(']')
    \ + len(' C') + len(virtcol('.'))
    \ + len(' L') + len(line('.')) + len('/') + len(line('$')) + len(' ')
    \ + len(split('├', '\zs')))
  if g:actual_curwin == win_getid()
    let l:length -= len(StartMode()) + len(Mode()) + len(EndMode())
    if v:hlsearch && !empty(s:tinsel.matches) && (s:tinsel.matches.total > 0)
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

function! Mode()
  if g:actual_curwin != win_getid()
    return ''
  endif
  return s:tinsel.modes[mode()[0]]
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

function! IndexedMatch()
  if (g:actual_curwin != win_getid()) || !v:hlsearch
    return ''
  endif
  let s:tinsel.matches =
    \ searchcount(#{ recompute: 1, maxcount: 0, timeout: 0 })
  if empty(s:tinsel.matches) || (s:tinsel.matches.total == 0)
    return ''
  endif
  return s:tinsel.matches.current
endfunction

function! Bar()
  if (g:actual_curwin != win_getid()) || !v:hlsearch
  \ || empty(s:tinsel.matches) || (s:tinsel.matches.total == 0)
    return ''
  endif
  return '/'
endfunction

function! TotalMatch()
  if (g:actual_curwin != win_getid()) || !v:hlsearch
  \ || empty(s:tinsel.matches) || (s:tinsel.matches.total == 0)
    return ''
  endif
  return s:tinsel.matches.total . ' '
endfunction

" status line content:
" [winnr] bufnr:filename [filetype] col('.') line('.')/line('$') [mode] matches
function! s:StatusLineData()
  set statusline+=\ [%3*%{winnr()}%0*]\ %3*%{bufnr()}%0*:
                   \%2*%{FileName(v:false,v:true)}%0*
                   \%2*%{FileName(v:false,v:false)}%0*
                   \%4*%{FileName(v:true,v:false)}%0*
                   \%1*%{FileName(v:true,v:true)}%0*
  set statusline+=\ [%3*%{&filetype}%0*]
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

function! s:ComputeWave(start, end)
  let l:wave = ''
  for l:each in range(a:start, a:end - 1)
    let l:wave = l:wave . s:tinsel.dots[5 + float2nr(5.0 * sin(l:each *
    \ (fmod(0.05 * (s:tinsel.localtime - s:tinsel.start) + 1.0, 2.0) - 1.0)))]
  endfor
  return l:wave
endfunction

function! StartWave()
  return s:ComputeWave(0, 4)
endfunction

function! EndWave()
  let l:win_width = winwidth(winnr())
  return s:ComputeWave(l:win_width - ComputeStatusLineLength() - 1, l:win_width)
endfunction

function! s:Tinsel(timer_id)
  let s:tinsel.color = fmod(s:tinsel.color + 0.75, 30.0)
  execute 'highlight User5 term=bold cterm=bold ctermfg='
    \ . s:tinsel.spectrum[float2nr(floor(s:tinsel.color))]
    \ . ' ctermbg=' . s:palette.black

  let s:tinsel.localtime = localtime()
  set statusline=%5*%{StartWave()}%0*
  call s:StatusLineData()
  set statusline+=%5*%{EndWave()}%0*

  if (s:tinsel.localtime - s:tinsel.start) > 40
    call timer_pause(s:tinsel.timer, v:true)
    call s:StaticLine()
  endif
endfunction

function! s:InitTinsel()
  let s:tinsel.color = 0.0
  let s:tinsel.start = localtime()
  call timer_pause(s:tinsel.timer, v:false)
endfunction

function! s:RestoreStatusLines(timer_id)
  execute  'highlight StatusLine   term=bold cterm=bold ctermfg='
    \ . s:palette.blue_4   . ' ctermbg=' . s:palette.black
    \ . ' | highlight StatusLineNC term=NONE cterm=NONE ctermfg='
    \ . s:palette.blue_1   . ' ctermbg=' . s:palette.black
    \ . ' | highlight VertSplit    term=NONE cterm=NONE ctermfg='
    \ . s:palette.purple_2 . ' ctermbg=' . s:palette.black
endfunction

function! s:HighlightStatusLines()
  execute  'highlight StatusLine   ctermfg=' . s:palette.green_1
    \ . ' | highlight StatusLineNC ctermfg=' . s:palette.green_1
    \ . ' | highlight VertSplit    ctermfg=' . s:palette.green_1
  call timer_start(1000, function('s:RestoreStatusLines'))
endfunction

"     }}}

if exists('s:tinsel.timer') | call timer_stop(s:tinsel.timer) | endif
let s:tinsel.timer = timer_start(100, function('s:Tinsel'), #{ repeat: -1 })
call timer_pause(s:tinsel.timer, v:true)

call s:StaticLine()

" }}}
"   Buffers menu {{{2
"     Keys {{{3

if exists('s:menukey') | unlet s:menukey | endif
const s:menukey = #{
\   next:         "\<Down>",
\   previous:       "\<Up>",
\   select:      "\<Enter>",
\   delete:             "d",
\   exit:          "\<Esc>",
\   selectchars:   '\d\|\$',
\   erase:          "\<BS>",
\   help:               "?",
\ }

"     }}}
"     Help {{{3

function! s:HelpBuffersMenu()
  let l:lines = [ '     ' . s:Key([s:menukey.help]) . '     - Show this help',
   \ '    ' . s:Key([s:menukey.exit]) . '    - Exit buffers menu',
   \ '   ' . s:Key([s:menukey.next, s:menukey.previous])
     \ . '   - Next/Previous buffer',
   \ '   ' . s:Key([s:menukey.select]) . '   - Select buffer',
   \ '     ' . s:Key([s:menukey.delete]) . '     - Delete buffer',
   \ '    < 0-9 >    - Buffer-id characters',
   \ '     < $ >     - End-of-string buffer-id character',
   \ ' ' . s:Key([s:menukey.erase]) . ' - Erase last buffer-id character',
  \ ]
  let l:text = []
  for l:each in l:lines
    let l:start = matchend(l:each, '^\s*< .\+ >\s* - \u')
    let l:properties = [#{ type: 'key', col: 1, length: l:start - 1}]
    let l:properties = l:properties + [#{ type: 'statusline',
      \ col: l:start - 2, length: 1 }]
    let l:start = 0
    while l:start > -1
      let l:start = match(l:each,
        \ '^\s*\zs< \| \zs> \s*- \u\| \zs| \|/\| .\zs-. ', l:start)
      if l:start > -1
        let l:start += 1
        let l:properties = l:properties + [#{ type: 'statusline',
          \ col: l:start, length: 1 }]
      endif
    endwhile
    call add(l:text, #{ text: l:each, props: l:properties })
  endfor
  call popup_create(l:text, #{
                           \   pos: 'topleft',
                           \   line: win_screenpos(0)[0] + winheight(0)
                           \     - len(l:text) - &cmdheight,
                           \   col: win_screenpos(0)[1],
                           \   zindex: 1,
                           \   minwidth: winwidth(0),
                           \   time: 10000,
                           \   border: [1, 0, 0, 0],
                           \   borderchars: ['━'],
                           \   borderhighlight: ['StatusLine'],
                           \   highlight: 'Help',
                           \ })
endfunction

"     }}}

function! s:ReplaceCursorOnCurrentBuffer(winid)
  call win_execute(a:winid,
    \ 'call cursor(index(map(getbufinfo(#{ buflisted: 1 }),'
    \ . '{ _, val -> val.bufnr }), winbufnr(s:menu.win_backup)) + 1, 0)')
endfunction

function! s:BuffersMenuFilter(winid, key)
  if a:key == s:menukey.next
    bnext
    call s:ReplaceCursorOnCurrentBuffer(a:winid)
  elseif a:key == s:menukey.previous
    bprevious
    call s:ReplaceCursorOnCurrentBuffer(a:winid)
  elseif a:key == s:menukey.select
    call popup_clear()
    unlet s:menu
  elseif a:key == s:menukey.delete
    let l:listed_buf = getbufinfo(#{ buflisted: 1 })
    if len(l:listed_buf) > 1
      let l:buf = bufnr()
      if len(win_findbuf(l:buf)) == 1
        if l:buf == l:listed_buf[-1].bufnr
          bprevious
        else
          bnext
        endif
        execute 'silent bdelete ' . l:buf
        call s:UpdateBuffersMenu()
        call popup_settext(a:winid, s:menu.text)
        call popup_setoptions(a:winid, #{
        \ line: win_screenpos(0)[0] + (winheight(0) - s:menu.height) / 2,
        \ col: win_screenpos(0)[1] + (winwidth(0) - s:menu.width) / 2,
        \ })
        call s:ReplaceCursorOnCurrentBuffer(a:winid)
      endif
    endif
  elseif a:key == s:menukey.exit
    if !empty(win_findbuf(s:menu.buf_backup))
      execute 'buffer ' . s:menu.buf_backup
    endif
    call popup_clear()
    unlet s:menu
  elseif match(a:key, s:menukey.selectchars) > -1
    if (a:key != "0") || (len(s:menu.input) > 0)
      let s:menu.input = s:menu.input . a:key
      let l:matches = filter(map(getbufinfo(#{ buflisted: 1 }),
        \ { _, val -> val.bufnr }),
        \ { _, val -> match(val, '^' . s:menu.input) > -1 })
      if len(l:matches) == 1
        execute 'buffer ' . l:matches[0]
        call s:ReplaceCursorOnCurrentBuffer(a:winid)
        let s:menu.input = ""
        echo len(l:matches) . ' match: ' . l:matches[0]
      else
        echo s:menu.input . ' (' . len(l:matches) . ' matches:'
          \ . string(l:matches) . ')'
      endif
    endif
  elseif a:key == s:menukey.erase
    let s:menu.input = s:menu.input[:-2]
    if len(s:menu.input) > 0
      let l:matches = filter(map(getbufinfo(#{ buflisted: 1 }),
        \ { _, val -> val.bufnr }),
        \ { _, val -> match(val, '^' . s:menu.input) > -1 })
      echo s:menu.input . ' (' . len(l:matches) . ' matches:'
        \ . string(l:matches) . ')'
    else
      echo s:menu.input
    endif
  elseif a:key == s:menukey.help
    call s:HelpBuffersMenu()
  endif
  return v:true
endfunction

function! s:UpdateBuffersMenu()
  let l:listed_buf = getbufinfo(#{ buflisted: 1 })
  let l:listedbuf_nb = len(l:listed_buf)

  if l:listedbuf_nb < 1
    return
  endif

  let s:menu.text = []
  let l:width = max(mapnew(l:listed_buf,
    \ {_, val -> len(val.bufnr . ': ""' . fnamemodify(val.name, ':.'))}))

  for l:each in l:listed_buf
    let l:line = l:each.bufnr . ': "' . fnamemodify(l:each.name, ':.') . '"'
    let l:line = l:line . repeat(' ', l:width - len(l:line))

    let l:properties = [#{ type: 'buf', col: 0, length: l:width + 1 }]
    if l:each.changed
      let l:properties = [#{ type: 'modified', col: 0, length: l:width + 1 }]
    endif

    call add(s:menu.text, #{ text: l:line, props: l:properties })
  endfor

  let s:menu.width = l:width
  let s:menu.height = len(s:menu.text)
endfunction

function! s:BuffersMenu()
  if empty(getcmdwintype())
    let s:menu = {}
    call s:UpdateBuffersMenu()
    let s:menu.buf_backup = bufnr()
    let s:menu.win_backup = winnr()
    let s:menu.input = ''

    let l:popup_id = popup_create(s:menu.text,
    \ #{
      \ pos: 'topleft',
      \ line: win_screenpos(0)[0] + (winheight(0) - s:menu.height) / 2,
      \ col: win_screenpos(0)[1] + (winwidth(0) - s:menu.width) / 2,
      \ zindex: 2,
      \ drag: v:true,
      \ wrap: v:false,
      \ filter: expand('<SID>') . 'BuffersMenuFilter',
      \ mapping: v:false,
      \ border: [],
      \ borderhighlight: ['BuffersMenuBorders'],
      \ borderchars: ['━', '┃', '━', '┃', '┏', '┓', '┛', '┗'],
      \ cursorline: v:true,
    \ })
    call s:ReplaceCursorOnCurrentBuffer(l:popup_id)
    call s:HelpBuffersMenu()
  endif
endfunction

"   }}}
"   Explorer {{{2
"     Keys {{{3

if exists('s:explorerkey') | unlet s:explorerkey | endif
const s:explorerkey = #{
\   next:              "\<Down>",
\   previous:            "\<Up>",
\   first:                   "g",
\   last:                    "G",
\   dotfiles:                ".",
\   yank:                    "y",
\   badd:                    "b",
\   open:                    "o",
\   reset:                   "c",
\   exit:               "\<Esc>",
\   help:                    "?",
\   searchmode:              "/",
\   next_match:              "n",
\   previous_match:          "N",
\   SM_right:         "\<Right>",
\   SM_left:           "\<Left>",
\   SM_wide_right:  "\<C-Right>",
\   SM_wide_left:    "\<C-Left>",
\   SM_next:           "\<Down>",
\   SM_previous:         "\<Up>",
\   SM_evaluate:      "\<Enter>",
\   SM_erase:            "\<BS>",
\   SM_exit:            "\<Esc>",
\ }

"     }}}
"     Help {{{3

function! s:HelpExplorer()
  let l:lines = [ repeat('━', 41) . '┳' . repeat('━', winwidth(0) - 42),
    \ '      NORMAL Mode                        ┃        '
      \ . s:Key([s:explorerkey.reset]) . '        - Reset explorer',
    \ '   ' . s:Key([s:explorerkey.help]) . '   - Show this help            '
      \ . '  ┃      ' . s:Key([s:explorerkey.searchmode])
      \ . '      - Enter SEARCH Mode',
    \ '  ' . s:Key([s:explorerkey.exit]) . '  - Exit explorer               '
      \ . '┃      ' . s:Key([s:explorerkey.next_match,
      \ s:explorerkey.previous_match]). '      - Next/Previous SEARCH match',
    \ ' ' . s:Key([s:explorerkey.next, s:explorerkey.previous])
      \ . ' - Next/Previous file          ┃                SEARCH Mode',
    \ ' ' . s:Key([s:explorerkey.first, s:explorerkey.last])
      \ . ' - First/Last file             ┃       '
      \ . s:Key([s:explorerkey.SM_exit]) . '       - Exit SEARCH Mode',
    \ '   ' . s:Key([s:explorerkey.open]) . '   - Open/Close dir & Open files'
      \ . ' ┃      ' . s:Key([s:explorerkey.SM_evaluate])
      \ . '      - Evaluate SEARCH',
    \ '   ' . s:Key([s:explorerkey.badd]) . '   - Add to buffers list        '
      \ . ' ┃    ' . s:Key([s:explorerkey.SM_erase]) . '    - Erase SEARCH',
    \ '   ' . s:Key([s:explorerkey.yank]) . '   - Yank path                  '
      \ . ' ┃      '
      \ . s:Key([s:explorerkey.SM_next, s:explorerkey.SM_previous])
      \ . '      - Next/Previous SEARCH',
    \ '   ' . s:Key([s:explorerkey.dotfiles]) . '   - Show/Hide dot files    '
      \ . '     ┃ ' . s:Key([s:explorerkey.SM_wide_left,
      \ s:explorerkey.SM_wide_right]) . ' - Navigation',
  \ ]
  let l:text = [#{ text: l:lines[0], props: [#{ type: 'statusline',
    \ col: 1, length: len(l:lines[0]) }] }]
  for l:each in l:lines[1:]

    let l:start = match(l:each, ' ┃ \s*<\zs .\+ >\s* - \u')
    let l:end = matchend(l:each, ' ┃ \s*< .\+ \ze>\s* - \u')
    let l:properties =
      \ [#{ type: 'key', col: l:start + 1, length: l:end - l:start }]

    let l:start = match(l:each, ' ┃ \s*< .\+ >\s* \zs- \u')
    let l:properties = l:properties + [#{ type: 'statusline',
      \ col: l:start + 1, length: 1 }]

    let l:start = match(l:each, '^\s*<\zs .\+ >\s* - \u.* ┃')
    let l:end = matchend(l:each, '^\s*< .\+ \ze>\s* - \u.* ┃')
    let l:properties = l:properties +
      \ [#{ type: 'key', col: l:start + 1, length: l:end - l:start }]

    let l:start = match(l:each, '^\s*< .\+ >\s* \zs- \u.* ┃')
    let l:properties = l:properties + [#{ type: 'statusline',
      \ col: l:start + 1, length: 1 }]

    let l:start = 0
    while l:start > -1
      let l:start = match(l:each, ' ┃ \s*\zs< \|^\s*\zs< \| \zs> \s*- \u\'
        \ . '| \zs| \|/\| .\zs-. \|[^<|] \zs& [^>|]', l:start)
      if l:start > -1
        let l:start += 1
        let l:properties = l:properties + [#{ type: 'statusline',
          \ col: l:start, length: 1 }]
      endif
    endwhile

    let l:properties = l:properties + [#{ type: 'statusline',
      \ col: match(l:each, ' \zs┃ '), length: len('┃')}]

    let l:start = match(l:each, '\u\{2,}')
    let l:end = matchend(l:each, '\u\{2,} Mode\|\u\{2,}')
    let l:properties = l:properties + [#{ type: 'mode',
      \ col: l:start, length: l:end + 1 - l:start }]

    call add(l:text, #{ text: l:each, props: l:properties })
  endfor
  call popup_create(l:text, #{ pos: 'topleft',
                           \   line: win_screenpos(0)[0] + winheight(0)
                           \     - len(l:text),
                           \   col: win_screenpos(0)[1],
                           \   zindex: 3,
                           \   minwidth: winwidth(0),
                           \   time: 10000,
                           \   highlight: 'Help',
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

function! s:InitExplorer()
  let s:explorer.tree = {}
  let s:explorer.tree['.'] = fnamemodify('.', ':p')
  let s:explorer.tree[fnamemodify('.', ':p')] = sort(map(reverse(
    \ readdir('.', '1', #{ sort: 'icase' })), { _, val ->
      \ s:FullPath(s:explorer.tree['.'], val) }), expand('<SID>')
      \ . 'PathCompare')
  let s:explorer.SEARCH = v:true
  let s:explorer.NORMAL = v:false
  let s:explorer.mode = s:explorer.NORMAL
  let s:explorer.input = ''
  let s:explorer.input_cursor = 0
  let s:explorer.history_cursor = 0
endfunction

function! s:Depth(path)
  return len(split(substitute(a:path, '/$', '', 'g'), '/'))
endfunction

function! s:NormalModeExplorerFilter(winid, key)
  if a:key == s:explorerkey.dotfiles
    let s:explorer.dotfiles = !s:explorer.dotfiles
    call s:UpdateExplorer()
    call popup_settext(a:winid, s:explorer.text)
    call win_execute(a:winid, 'if line(".") > line("$") |'
      \ . ' call cursor(line("$"), 0) | endif')
  elseif a:key == s:explorerkey.yank
    call win_execute(a:winid, 'let s:explorer.line = line(".") - 2')
    let l:path = s:explorer.paths[s:explorer.line]
    unlet s:explorer.line
    let @" = l:path
    echo 'Unnamed register content is:'
    echohl OpenedDirPath
    echon @"
    echohl NONE
  elseif a:key == s:explorerkey.badd
    call win_execute(a:winid, 'let s:explorer.line = line(".") - 2')
    let l:path = s:explorer.paths[s:explorer.line]
    unlet s:explorer.line
    if !isdirectory(l:path)
      execute 'badd ' . l:path
      echohl OpenedDirPath
      echo l:path
      echohl NONE
      echon ' added to buffers list'
    endif
  elseif a:key == s:explorerkey.open
    call win_execute(a:winid, 'let s:explorer.line = line(".") - 2')
    let l:path = s:explorer.paths[s:explorer.line]
    unlet s:explorer.line
    if isdirectory(l:path)
      if has_key(s:explorer.tree, l:path)
        unlet s:explorer.tree[l:path]
      else
        let s:explorer.tree[l:path] = sort(map(reverse(
          \ readdir(l:path, '1', #{ sort: 'icase' })), { _, val ->
            \s:FullPath(l:path, val) }), expand('<SID>') . 'PathCompare')
      endif
      call s:UpdateExplorer()
      call popup_settext(a:winid, s:explorer.text)
    else
      call popup_clear()
      execute 'edit ' . l:path
      unlet s:explorer
    endif
  elseif a:key == s:explorerkey.reset
    call s:InitExplorer()
    call s:UpdateExplorer()
    call popup_settext(a:winid, s:explorer.text)
    call win_execute(a:winid, 'call cursor(2, 0)')
  elseif a:key == s:explorerkey.next_match
    call win_execute(a:winid, 'call search(histget("/", -1), "")')
  elseif a:key == s:explorerkey.previous_match
    call win_execute(a:winid, 'call search(histget("/", -1), "b")')
  elseif a:key == s:explorerkey.first
    call win_execute(a:winid,
      \ 'call cursor(2, 0) | execute "normal! \<C-y>"')
  elseif a:key == s:explorerkey.last
    call win_execute(a:winid, 'call cursor(line("$"), 0)')
  elseif a:key == s:explorerkey.exit
    call win_execute(a:winid, 'call clearmatches()')
    call popup_clear()
    unlet s:explorer
  elseif a:key == s:explorerkey.next
    call win_execute(a:winid, 'if line(".") < line("$") |'
      \ . ' call cursor(line(".") + 1, 0) | endif')
  elseif a:key == s:explorerkey.previous
    call win_execute(a:winid, 'if line(".") > 2 |'
      \ . ' call cursor(line(".") - 1, 0) | else |'
      \ . ' execute "normal! \<C-y>" | endif')
  elseif a:key == s:explorerkey.help
    call s:HelpExplorer()
  elseif a:key == s:explorerkey.searchmode
    let s:explorer.mode = s:explorer.SEARCH
    let s:explorer.input = a:key
    let s:explorer.input_cursor = 1
    let s:explorer.history_cursor = 0
    echo s:explorer.input
    echohl Visual
    echon ' '
    echohl NONE
  endif
endfunction

function! s:SearchModeExplorerFilter(winid, key)
  if a:key == s:explorerkey.SM_evaluate
    let @/ = '\%>1l' . s:explorer.input[1:]
    call win_execute(a:winid,
      \ 'if s:explorer.input[0] == "/" | call search(@/, "c") | '
      \ . 'elseif s:explorer.input[0] == "?" | call search(@/, "bc") | endif')
    call histadd('/', @/)
    let s:explorer.input = ''
  elseif a:key == s:explorerkey.SM_erase
    if s:explorer.input_cursor > 1
      let s:explorer.input =
        \ slice(s:explorer.input, 0, s:explorer.input_cursor - 1)
        \ . slice(s:explorer.input, s:explorer.input_cursor)
      let s:explorer.input_cursor -= 1
    endif
  elseif a:key == s:explorerkey.SM_exit
    let s:explorer.input = ''
  elseif a:key == s:explorerkey.SM_next
    if s:explorer.history_cursor < 0
      let s:explorer.history_cursor += 1
      let s:explorer.input = '/' . histget('search', s:explorer.history_cursor)
    else
      let s:explorer.input = '/'
    endif
    let s:explorer.input_cursor = len(s:explorer.input)
  elseif a:key == s:explorerkey.SM_previous
    if abs(s:explorer.history_cursor) < &history
      let s:explorer.history_cursor -= 1
      let s:explorer.input = '/' . histget('search', s:explorer.history_cursor)
      let s:explorer.input_cursor = len(s:explorer.input)
    endif
  elseif a:key == s:explorerkey.SM_left
    if s:explorer.input_cursor > 1
      let s:explorer.input_cursor -= 1
    endif
  elseif a:key == s:explorerkey.SM_right
    if s:explorer.input_cursor < len(s:explorer.input)
      let s:explorer.input_cursor += 1
    endif
  elseif a:key == s:explorerkey.SM_wide_left
    for l:each in range(s:explorer.input_cursor - 2, 0, -1)
      if match(s:explorer.input[l:each], '[[:punct:][:space:]]') > -1
        let s:explorer.input_cursor = l:each + 1
        break
      endif
    endfor
  elseif a:key == s:explorerkey.SM_wide_right
    let s:explorer.input_cursor = match(s:explorer.input[1:],
      \ '[[:punct:][:space:]]', s:explorer.input_cursor + 1)
    if s:explorer.input_cursor == -1
      let s:explorer.input_cursor = len(s:explorer.input)
    endif
  else
    let s:explorer.input =
      \ slice(s:explorer.input, 0, s:explorer.input_cursor) . a:key
      \ . slice(s:explorer.input, s:explorer.input_cursor)
    let s:explorer.input_cursor += 1
    call win_execute(a:winid, 'call clearmatches() | '
      \ . 'try | call matchadd("Search", "\\%>1l" . s:explorer.input[1:]) | '
      \ . 'catch | endtry ')
  endif

  if empty(s:explorer.input)
    let s:explorer.mode = s:explorer.NORMAL
  endif
  echo slice(s:explorer.input, 0, s:explorer.input_cursor)
  echohl Visual
  echon slice(s:explorer.input, s:explorer.input_cursor,
    s:explorer.input_cursor + 1)
  if s:explorer.input_cursor == len(s:explorer.input)
    echon ' '
  endif
  echohl NONE
  echon slice(s:explorer.input, s:explorer.input_cursor + 1)
endfunction

function! s:ExplorerFilter(winid, key)
  if s:explorer.mode == s:explorer.NORMAL
    call s:NormalModeExplorerFilter(a:winid, a:key)
  else
    call s:SearchModeExplorerFilter(a:winid, a:key)
  endif
  return v:true
endfunction

function! s:UpdateExplorer()
  let s:explorer.text = []
  let s:explorer.paths = []

  let l:line = s:explorer.tree['.']
  let l:properties = [#{ type: 'root', col: 0, length: len(l:line) + 1 }]

  call add(s:explorer.text, #{ text: l:line, props: l:properties })

  let l:stack = s:explorer.tree[s:explorer.tree['.']]
  let l:visited = {}
  let l:visited[s:explorer.tree['.']] = v:true
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
      if has_key(s:explorer.tree, l:current)
        let l:arrow = '▾ '
      else
        let l:arrow = '▸ '
      endif
    endif

    if s:explorer.dotfiles || l:name[0] != '.'
      let l:indent = repeat('  ',
        \ s:Depth(l:current) - s:Depth(s:explorer.tree['.'])
        \ - isdirectory(l:current))
      let l:line = l:indent . l:arrow . l:name . l:id

      " construct properties
      let l:properties = [#{ type: 'file', col: 0, length: winwidth(0) + 1}]
      if isdirectory(l:current)
        if has_key(s:explorer.tree, l:current)
          let l:properties =
            \ [#{ type: 'opened', col: 0, length: winwidth(0) + 1}]
        else
          let l:properties =
            \ [#{ type: 'closed', col: 0, length: winwidth(0) + 1}]
        endif
      endif

      call add(s:explorer.text, #{ text: l:line, props: l:properties })
      call add(s:explorer.paths, l:current)
    endif

    " continue dfs
    if !has_key(l:visited, l:current)
      let l:visited[l:current] = v:true
      if has_key(s:explorer.tree, l:current)
        let l:stack += s:explorer.tree[l:current]
      endif
    endif
  endwhile
endfunction

function! s:Explorer()
  if empty(getcmdwintype())
    let s:explorer = {}
    call s:InitExplorer()
    let s:explorer.dotfiles = v:false

    call s:UpdateExplorer()
    let l:popup_id = popup_create(s:explorer.text,
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
      \ filter: expand('<SID>') . 'ExplorerFilter',
      \ mapping: v:false,
      \ scrollbar: v:true,
      \ cursorline: v:true,
    \ })
    call win_execute(l:popup_id, 'call cursor(2, 0)')
    call s:HelpExplorer()
  endif
endfunction

"   }}}
"   Obsession {{{2
"     Keys {{{3

if exists('s:obsessionkey') | unlet s:obsessionkey | endif
const s:obsessionkey = #{
\   yes: "y",
\   no:  "n",
\ }

"     }}}
"     Options {{{3

" unset blank (empty windows), options (sometimes buggy) and tabpages (unused)
set sessionoptions=buffers,sesdir,folds,help,winsize

"     }}}
"     Functions {{{3

function! s:Obsession()
  mksession!
  call s:HighlightStatusLines()
endfunction

function! s:SourceObsession()
  if !argc() && empty(v:this_session) && filereadable('Session.vim')
    \ && !&modified
    source Session.vim
  endif
endfunction

function! s:PromptObsession()
  if len(getbufinfo(#{ buflisted: 1 })) > 1
    call inputsave()
    while v:true
      redraw!
      echon 'Build a new session in "'
      echohl PMenu
      echon fnamemodify('.', ':p')
      echohl NONE
      echon '": ['
      echohl PMenu
      echon 'Y'
      echohl NONE
      echon ']es or ['
      echohl PMenu
      echon 'N'
      echohl NONE
      echon ']o ? '
      let l:mkses = input('')
      let l:mkses = tolower(l:mkses)
      if l:mkses == s:obsessionkey.yes
        mksession!
        break
      elseif l:mkses == s:obsessionkey.no
        break
      endif
      echohl NONE
    endwhile
    call inputrestore()
  endif
endfunction

"     }}}
"   }}}
"   Undo tree {{{2
"     Keys {{{3

if exists('s:undokey') | unlet s:undokey | endif
const s:undokey = #{
\   next:          "\<Up>",
\   previous:    "\<Down>",
\   first:             "g",
\   last:              "G",
\   scrollup:    "\<Left>",
\   scrolldown: "\<Right>",
\   select:     "\<Enter>",
\   exit:         "\<Esc>",
\   help:              "?",
\ }

"     }}}
"     Help {{{3

function! s:HelpUndotree()
  let l:lines = [ '     ' . s:Key([s:undokey.help]) . '   - Show this help',
   \ '    ' . s:Key([s:undokey.exit]) . '  - Exit undotree',
   \ '   ' . s:Key([s:undokey.next, s:undokey.previous])
     \ . ' - Next/Previous change',
   \ '   ' . s:Key([s:undokey.select]) . ' - Select change',
   \ '   ' . s:Key([s:undokey.first, s:undokey.last])
     \ . ' - First/Last change',
   \ '   ' . s:Key([s:undokey.scrollup, s:undokey.scrolldown])
     \ . ' - Scroll diff window',
  \ ]
  let l:text = []
  for l:each in l:lines
    let l:start = matchend(l:each, '^\s*< .\+ >\s* - \u')
    let l:properties = [#{ type: 'key', col: 1, length: l:start - 1}]
    let l:properties = l:properties + [#{ type: 'statusline',
      \ col: l:start - 2, length: 1 }]
    let l:start = 0
    while l:start > -1
      let l:start = match(l:each,
        \ '^\s*\zs< \| \zs> \s*- \u\| \zs| \|/\| .\zs-. ', l:start)
      if l:start > -1
        let l:start += 1
        let l:properties = l:properties + [#{ type: 'statusline',
          \ col: l:start, length: 1 }]
      endif
    endwhile
    call add(l:text, #{ text: l:each, props: l:properties })
  endfor
  call popup_create(l:text, #{
                           \   pos: 'topleft',
                           \   line: win_screenpos(0)[0] + winheight(0)
                           \     - len(l:text) - &cmdheight,
                           \   col: win_screenpos(0)[1] + s:undo.max_length
                           \     + 1,
                           \   zindex: 4,
                           \   minwidth: winwidth(0) - s:undo.max_length - 1,
                           \   maxwidth: winwidth(0) - s:undo.max_length - 1,
                           \   time: 10000,
                           \   border: [1, 0, 0, 0],
                           \   borderchars: ['━'],
                           \   borderhighlight: ['StatusLine'],
                           \   highlight: 'Help',
                           \ })
endfunction

"     }}}

function! s:DiffHandler(job, status)
  let l:eventignore_backup = &eventignore
  set eventignore=all

  let l:diffbuf = ch_getbufnr(a:job, 'out')
  let l:text = getbufline(l:diffbuf, 1, '$')

  execute 'silent bdelete ' . l:diffbuf
  if delete(s:undo.tmp[0]) != 0
    echoerr 'Personal Error Message: Can not delete temp file: '
      \ . s:undo.tmp[0]
  endif
  if delete(s:undo.tmp[1]) != 0
    echoerr 'Personal Error Message: Can not delete temp file: '
      \ . s:undo.tmp[1]
  endif

  for l:each in range(len(l:text))
    let l:properties = \ [ #{ type: 'diffadd', col: 1,
      \ length: max([0, len(l:text[l:each]) - 1]) }]
    if l:text[l:each][0] == '-'
      let l:properties = [ #{ type: 'diffdelete', col: 1,
        \ length: max([0, len(l:text[l:each]) - 1]) }]
    endif
    let l:text[l:each] = #{ text: l:text[l:each][1:], props: l:properties }
  endfor

  call popup_settext(s:undo.diff_id, l:text)
  unlet s:undo.job
  let &eventignore = l:eventignore_backup
endfunction

function! s:Diff(treepopup_id)
  call win_execute(a:treepopup_id, 'let s:undo.line = line(".")')
  let l:newchange = changenr()
  let l:oldchange = s:undo.meta[s:undo.line - 1]
  unlet s:undo.line

  let l:eventignore_backup = &eventignore
  set eventignore=all
  let l:savedview = winsaveview()
  let l:new = getbufline(bufnr(), 1, '$')
  execute 'silent undo ' . l:oldchange
  let l:old = getbufline(bufnr(), 1, '$')
  execute 'silent undo ' . l:newchange
  call winrestview(l:savedview)

  let l:diffcommand = 'diff --unchanged-line-format=""'
    \ . ' --new-line-format="-%dn: %L" --old-line-format="+%dn: %L"'
  while !empty(job_info())
    sleep 1m
  endwhile
  let s:undo.tmp = [tempname(), tempname()]
  if writefile(l:old, s:undo.tmp[0]) == -1
    echoerr 'Personal Error Message: Can not write to temp file: '
      \ . s:undo.tmp[0]
  endif
  if writefile(l:new, s:undo.tmp[1]) == -1
    echoerr 'Personal Error Message: Can not write to temp file: '
      \ . s:undo.tmp[1]
  endif
  let s:undo.job = job_start(['/bin/sh', '-c', l:diffcommand . ' '
    \ . s:undo.tmp[0] . ' ' . s:undo.tmp[1]], #{ out_io: 'buffer',
    \ out_msg: v:false, exit_cb: expand('<SID>') . 'DiffHandler' })

  let &eventignore = l:eventignore_backup
endfunction

function! s:UndotreeFilter(winid, key)
  if a:key == s:undokey.exit
    execute 'highlight PopupSelected term=bold cterm=bold ctermfg='
      \ . s:palette.black . ' ctermbg=' . s:palette.purple_2
    call popup_clear()
    unlet s:undo
  elseif a:key == s:undokey.next
    call s:UpdateUndotree()
    call win_execute(a:winid, 'while line(".") > 1'
      \ . ' | call cursor(line(".") - 1, 0)'
      \ . ' | if (line(".") < line("w0") + 1) && (line("w0") > 1)'
      \ . ' | execute "normal! \<C-y>" | endif'
      \ . ' | if s:undo.meta[line(".") - 1] > -1 | break | endif'
      \ . ' | endwhile')
    call s:Diff(a:winid)
    call s:UndotreeButtons(a:winid)
  elseif a:key == s:undokey.previous
    call s:UpdateUndotree()
    call win_execute(a:winid, 'while line(".") < line("$")'
      \ . ' | call cursor(line(".") + 1, 0)'
      \ . ' | if (line(".") > line("w$") - 1) && (line("$") > line("w$"))'
      \ . ' | execute "normal! \<C-e>" | endif'
      \ . ' | if s:undo.meta[line(".") - 1] > -1 | break | endif'
      \ . ' | endwhile')
    call s:Diff(a:winid)
    call s:UndotreeButtons(a:winid)
  elseif a:key == s:undokey.first
    call s:UpdateUndotree()
    call win_execute(a:winid, 'call cursor(1, 0)')
    call s:Diff(a:winid)
    call s:UndotreeButtons(a:winid)
  elseif a:key == s:undokey.last
    call s:UpdateUndotree()
    call win_execute(a:winid, 'call cursor(line("$"), 0)')
    call s:Diff(a:winid)
    call s:UndotreeButtons(a:winid)
  elseif a:key == s:undokey.scrollup
    call win_execute(s:undo.diff_id,
      \ 'call cursor(line("w0") - 1, 0) | redraw')
  elseif a:key == s:undokey.scrolldown
    call win_execute(s:undo.diff_id,
      \ 'call cursor(line("w$") + 1, 0) | redraw')
  elseif a:key == s:undokey.select
    call win_execute(a:winid, 'let s:undo.line = line(".")')
    execute 'silent undo ' . s:undo.meta[s:undo.line - 1]
    unlet s:undo.line
    call s:UpdateUndotree()
    call popup_settext(a:winid, s:undo.text)
  elseif a:key == s:undokey.help
    call s:HelpUndotree()
  endif
  return v:true
endfunction

function! s:ParseNode(in, out)
  if empty(a:in)
    return
  endif
  let l:currentnode = a:out
  for l:each in a:in
    if has_key(l:each, 'alt')
      call s:ParseNode(l:each.alt, l:currentnode)
    endif
    let l:newnode = #{ seq: l:each.seq, p: [] }
    call extend(l:currentnode.p, [l:newnode])
    let l:currentnode = l:newnode
  endfor
endfunction

function! s:UpdateUndotree()
  let l:rawtree = undotree().entries
  let s:undo.tree = #{ seq: 0, p: [] }
  let s:undo.text = []
  let s:undo.meta = []
  let l:maxlength = 0

  call s:ParseNode(l:rawtree, s:undo.tree)

  let l:slots = [s:undo.tree]
  while l:slots != []
    let l:foundstring = v:false
    let l:index = 0

    for l:each in range(len(l:slots))
      if type(l:slots[l:each]) == v:t_string
        let l:foundstring = v:true
        let l:eachndex = l:each
        break
      endif
    endfor

    let l:minseq = v:numbermax
    let l:minnode = {}

    if !l:foundstring
      for l:each in range(len(l:slots))
        if type(l:slots[l:each]) == v:t_dict
          if l:slots[l:each].seq < l:minseq
            let l:minseq = l:slots[l:each].seq
            let l:eachndex = l:each
            let l:minnode = l:slots[l:each]
            continue
          endif
        endif
        if type(l:slots[l:each]) == v:t_list
          for l:each2 in l:slots[l:each]
            if l:each2.seq < l:minseq
              let l:minseq = l:each2.seq
              let l:eachndex = l:each
              let l:minnode = l:each2
              continue
            endif
          endfor
        endif
      endfor
    endif

    let l:newline = " "
    let l:newmeta = -1
    let l:node = l:slots[l:index]
    if type(l:node) == v:t_string
      let l:newmeta = -1
      if l:index + 1 != len(l:slots)
        for l:each in range(len(l:slots))
          if l:each < l:eachndex
            let l:newline = l:newline . '| '
          endif
          if l:each > l:eachndex
            let l:newline = l:newline . ' \'
          endif
        endfor
      endif
      call remove(l:slots, l:index)
    endif

    if type(l:node) == v:t_dict
      let l:newmeta = l:node.seq
      for l:each in range(len(l:slots))
        if l:eachndex == l:each
          if l:node.seq == changenr()
            let l:newline = l:newline . '◊ '
          else
            let l:newline = l:newline . '• '
          endif
        else
          let l:newline = l:newline . '| '
        endif
      endfor
      let l:newline = l:newline . '   ' . l:node.seq
      if empty(l:node.p)
        let l:slots[l:index] = 'x'
      endif
      if len(l:node.p) == 1
        let l:slots[l:index] = l:node.p[0]
      endif
      if len(l:node.p) > 1
        let l:slots[l:index] = l:node.p
      endif
      let l:node.p = []
    endif

    if type(l:node) == v:t_list
      let l:newmeta = -1
      for l:each in range(len(l:slots))
        if l:each < l:index
          let l:newline = l:newline . '| '
        endif
        if l:each == l:index
          let l:newline = l:newline . '|/ '
        endif
        if l:each > l:index
          let l:newline = l:newline . '/ '
        endif
      endfor
      call remove(l:slots, l:index)
      if len(l:node) == 2
        if l:node[0].seq > l:node[1].seq
          call insert(l:slots, l:node[1], l:index)
          call insert(l:slots, l:node[0], l:index)
        else
          call insert(l:slots, l:node[0], l:index)
          call insert(l:slots, l:node[1], l:index)
        endif
      endif
      if len(l:node) > 2
        call remove(l:node, index(l:node, l:minnode))
        call insert(l:slots, l:minnode, l:index)
        call insert(l:slots, l:node, l:index)
      endif
    endif
    unlet l:node

    if l:newline != " "
      let l:newline = substitute(l:newline, '\s*$', '', 'g')
      let l:maxlength = max([l:maxlength, len(split(l:newline, '\zs'))])
      let l:properties =
        \ [#{ type: 'statusline', col: 1, length: len(l:newline) }]
      call insert(s:undo.text,
        \ #{ text: l:newline, props: l:properties }, 0)
      call insert(s:undo.meta, l:newmeta, 0)
    endif

  endwhile

  let s:undo.max_length = l:maxlength + 1
endfunction

function! s:UndotreeButtons(winid)
  let l:midlength = s:undo.max_length / 2
  let l:modified = v:false
  call win_execute(a:winid, 'let s:undo.first_line = line("w0")'
    \ . ' | let s:undo.last_line = line("w$")')
  if s:undo.first_line > 1
    if l:midlength * 2 == s:undo.max_length
      let s:undo.text[s:undo.first_line - 1].text =
      \ repeat(' ', l:midlength - 1) . '▲' . repeat(' ', l:midlength)
    else
      let s:undo.text[s:undo.first_line - 1].text =
      \ repeat(' ', l:midlength) . '▴' . repeat(' ', l:midlength)
    endif
    let s:undo.text[s:undo.first_line - 1].props =
    \ [#{ type: 'button', col: 1,
      \ length: len(s:undo.text[s:undo.first_line - 1].text) }]
    let l:modified = v:true
  endif
  unlet s:undo.first_line
  if s:undo.last_line < len(s:undo.text)
    if l:midlength * 2 == s:undo.max_length
      let s:undo.text[s:undo.last_line - 1].text =
      \ repeat(' ', l:midlength - 1) . '▼' . repeat(' ', l:midlength)
    else
      let s:undo.text[s:undo.last_line - 1].text =
      \ repeat(' ', l:midlength) . '▾' . repeat(' ', l:midlength)
    endif
    let s:undo.text[s:undo.last_line - 1].props =
    \ [#{ type: 'button', col: 1,
      \ length: len(s:undo.text[s:undo.last_line - 1].text) }]
    let l:modified = v:true
  endif
  unlet s:undo.last_line
  if l:modified
    call popup_settext(a:winid, s:undo.text)
  endif
endfunction

function! s:Undotree()
  if !buflisted(bufnr()) || !bufloaded(bufnr())
    echoerr 'Personal Error Message: Unlisted or Unloaded current buffer.'
      \ . ' Can not use undo tree.'
    return
  endif

  let s:undo = {}
  call s:UpdateUndotree()
  let s:undo.change_backup = changenr()
  execute 'highlight PopupSelected term=bold cterm=bold ctermfg='
    \ . s:palette.pink . ' ctermbg=' . s:palette.black

  let s:undo.diff_id = popup_create('',
  \ #{
    \ pos: 'topleft',
    \ line: win_screenpos(0)[0],
    \ col: win_screenpos(0)[1] + s:undo.max_length,
    \ zindex: 2,
    \ minwidth: winwidth(0) - s:undo.max_length - 1,
    \ maxwidth: winwidth(0) - s:undo.max_length - 1,
    \ minheight: winheight(0),
    \ maxheight: winheight(0),
    \ drag: v:false,
    \ wrap: v:true,
    \ mapping: v:false,
    \ scrollbar: v:true,
    \ border: [0, 0, 0, 1],
    \ borderchars: ['│'],
    \ borderhighlight: ['VertSplit'],
  \ })

  let l:popup_id = popup_create(s:undo.text,
  \ #{
    \ pos: 'topleft',
    \ line: win_screenpos(0)[0],
    \ col: win_screenpos(0)[1],
    \ zindex: 3,
    \ minwidth: s:undo.max_length,
    \ maxwidth: s:undo.max_length,
    \ minheight: winheight(0),
    \ maxheight: winheight(0),
    \ drag: v:false,
    \ wrap: v:true,
    \ filter: expand('<SID>') . 'UndotreeFilter',
    \ mapping: v:false,
    \ scrollbar: v:false,
    \ cursorline: v:true,
  \ })
  call win_execute(l:popup_id, 'let w:line = 1 | call cursor(w:line, 0)'
  \ . ' | while s:undo.meta[line(".") - 1] != s:undo.change_backup'
  \ . ' | let w:line += 1 | call cursor(w:line, 0) | endwhile')
  call s:UndotreeButtons(l:popup_id)
  call s:HelpUndotree()
endfunction

"   }}}
"   Gutentags {{{2

function! s:HighlightGutentags()
  if buflisted(bufnr())
    let l:matches = getmatches()
    if !empty(filter(mapnew(l:matches, { _, val -> val.group }),
    \ 'v:val == "Tag"'))
      call setmatches(filter(l:matches, { _, val -> val.group != 'Tag' }))
    endif
    call matchadd('Tag', join(sort(map(taglist('.*'), { _, val -> val.name }),
      \ { val1, val2 -> len(split(val2, '\zs')) - len(split(val1, '\zs')) }),
      \ '\|'), -1)
  endif
endfunction

function! s:GenerateGutentags()
  if !empty(systemlist('which ctags')) && !empty(systemlist('which git'))
    let l:bufdir = fnamemodify(expand('%'), ':p:h')
    let l:isingitdir = !empty(systemlist('command cd '
      \ . l:bufdir . ' && git rev-parse --git-dir 2> /dev/null'))
    if l:isingitdir
      let l:root = systemlist('command cd ' . l:bufdir
        \ . ' && git rev-parse --show-toplevel')[0]
      let l:tags_path = l:root . '/tags'
      let l:tagsignore_path = l:root . '/tagsignore'

      " specify tags file path (semi-colon really important)
      let l:tags_setting = l:tags_path . ';'
      let &tags = l:tags_setting

      let l:command = 'ctags -R'
      let l:ctags_flags = #{
      \   vim: ' --kinds-Vim=fvC',
      \ }
      if has_key(l:ctags_flags, &filetype)
        let l:command .= l:ctags_flags[&filetype]
      endif
      let l:command .= ' $(for FILE in $(cat ' . l:tagsignore_path . ');'
        \ . ' do echo -n "--exclude=' . l:root . '"/${FILE}" "; done) -o '
        \ . l:tags_path . ' ' . l:root
      call system(l:command)
      call s:HighlightGutentags()
      call s:HighlightStatusLines()
    endif
  endif
endfunction

function! s:FollowTag()
  let l:iskeyword_backup = ''
  if &filetype == 'vim'
    let l:iskeyword_backup = &iskeyword
    setlocal iskeyword+=:
  endif
  let l:cword = expand('<cword>')
  execute 'tag ' . l:cword
  if foldlevel('.') > 0
    foldopen!
  endif
  if len(taglist('^' . l:cword . '$')) == 1
    normal! zz
  endif
  if !empty(l:iskeyword_backup)
    let &iskeyword = l:iskeyword_backup
  endif
endfunction

function! s:NextTag()
  tag
  if foldlevel('.') > 0
    foldopen!
  endif
  normal! zz
endfunction

function! s:PreviousTag()
  pop
  if foldlevel('.') > 0
    foldopen!
  endif
  normal! zz
endfunction

"   }}}
"   Rainbow {{{2
"     Variables & constants {{{3

let s:rainbow = #{
\   colors: [
\      196, 208, 226, 40, 45, 33, 129, 201
\   ],
\   activated: v:false,
\ }

"     }}}
"     Functions {{{3

function! s:IsRainbowUsed()
  return empty(filter(map(split(execute('syntax list'), '\n'),
    \ 'matchstr(v:val, "^\[[:alnum:]_]*")'), 'match(v:val, "_Rainbow") > 0'))
endfunction

function! s:ActivateRainbow()
  let l:buf_syntax = split(execute('syntax list'), '\n')[1:]
  if !empty(l:buf_syntax) || empty(&filetype)
    if s:IsRainbowUsed()
      let l:max = len(s:rainbow.colors)
      let l:index = 0

      let l:containedin = ''
      let l:parentheses = ['start=/(/ end=/)/ fold',
        \ 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold']
      let l:stringsyn = '"^[^[:space:]]*String[^[:space:]]*"'

      if &filetype == 'vim'
        let l:parentheses = ['start=/(/ end=/)/', 'start=/\[/ end=/\]/',
          \ 'start=/{/ end=/}/ fold']
      elseif (&filetype == 'sh') || (&filetype == 'conf')
        let l:stringsyn = '"shDoubleQuote"'
        let l:containedin = ",shDoubleQuote"
      elseif &filetype == 'yaml'
        let l:containedin = ",yamlFlowString"
      endif

      " syntax list must not be cleared if the it is already empty
      if !empty(l:buf_syntax)
        execute 'syntax clear ' . join(filter(filter(filter(map(filter(
          \ l:buf_syntax, 'match(v:val, "cluster") < 0'),
          \ 'matchstr(v:val, "^[[:alnum:]_]*")'), '!empty(v:val)'),
          \ 'match(v:val, "_Rainbow") < 0'),
          \ 'match(v:val, ' . l:stringsyn . ') < 0'))
      endif

      for l:parenthesis in l:parentheses
        for l:each in range(0, l:max - 1)
          let l:fg = s:rainbow.colors[l:each % l:max]
          execute 'syntax match ' . &filetype . '_Rainbow' . l:each
            \ . '_Operator' . l:index . ' _,_ containedin=' . &filetype
            \ . '_Rainbow' . l:each . '_Region' . l:index . ' contained'
          execute 'syntax region ' . &filetype . '_Rainbow' . l:each
            \ . '_Region' . l:index . ' matchgroup=' . &filetype . '_Rainbow'
            \ . l:each . '_Parenthesis' . l:index
            \ . ((l:each > 0) ? ' contained' : '') . ' ' . l:parenthesis
            \ . ' containedin=@' . &filetype . '_RainbowRegions'
            \ . ((l:each + l:max - 1) % l:max)
            \ . ((l:each == 0) ? l:containedin : '') . ' contains=TOP fold'
          execute 'syntax cluster ' . &filetype . '_RainbowRegions' . l:each
            \ . ' add=' . &filetype . '_Rainbow' . l:each . '_Region' . l:index
          execute 'syntax cluster ' . &filetype . '_RainbowParentheses'
            \ . l:each . ' add=' . &filetype . '_Rainbow' . l:each
            \ . '_Parenthesis' . l:index
          execute 'syntax cluster ' . &filetype . '_RainbowOperators' . l:each
            \ . ' add=' . &filetype . '_Rainbow' . l:each . '_Operator'
            \ . l:index
          execute 'highlight ' . &filetype . '_Rainbow' . l:each
            \ . '_Operator' . l:index . ' cterm=bold ctermfg=' . l:fg
          execute 'highlight ' . &filetype . '_Rainbow' . l:each
            \ . '_Parenthesis' . l:index . ' cterm=bold ctermfg=' . l:fg
        endfor
        let l:index += 1
      endfor

      for l:each in range(0, l:max - 1)
        execute 'syntax cluster ' . &filetype . '_RainbowRegions add=@'
          \ . &filetype . '_RainbowRegions' . l:each
        execute 'syntax cluster ' . &filetype . '_RainbowParentheses add=@'
          \ . &filetype . '_RainbowParentheses' . l:each
        execute 'syntax cluster ' . &filetype . '_RainbowOperators add=@'
          \ . &filetype . '_RainbowOperators' . l:each
      endfor

      syntax sync fromstart
    endif
  endif
endfunction

function! s:InactivateRainbow()
  let l:buf_backup = bufnr()
  let l:savedview = winsaveview()
  let l:eventignore_backup = &eventignore
  set eventignore=all

  for l:each in map(getbufinfo(), 'v:val.bufnr')
    execute 'buffer ' . l:each
    syntax clear
  endfor

  execute 'buffer ' . l:buf_backup
  call winrestview(l:savedview)
  let &eventignore = l:eventignore_backup

  syntax enable
  call s:LoadColorscheme()
endfunction

function! s:ToggleRainbow()
  if empty(getcmdwintype())
    if s:rainbow.activated
      call s:InactivateRainbow()
    else
      let l:buf_backup = bufnr()
      let l:savedview = winsaveview()
      let l:eventignore_backup = &eventignore
      set eventignore=all

      for l:each in map(getbufinfo(), 'v:val.bufnr')
        execute 'buffer ' . l:each
        call s:ActivateRainbow()
      endfor

      execute 'buffer ' . l:buf_backup
      call winrestview(l:savedview)
      let &eventignore = l:eventignore_backup
    endif
    let s:rainbow.activated = !s:rainbow.activated
  endif
endfunction

function! s:RefreshRainbow()
  if s:rainbow.activated
    call s:ActivateRainbow()
  endif
endfunction

"     }}}
"   }}}
"   Tag list {{{2
"   }}}
" }}}
" Filetype specific {{{1
"   Bash {{{2

function! s:PrefillShFile()
  call append(0, [
  \                '#!/bin/bash',
  \                '',
  \              ])
endfunction

"   }}}
"   YAML {{{2

function! s:PrefillYamlFile()
  call append(0, [
  \                '---',
  \                '# Standards: 0.3',
  \                '',
  \              ])
endfunction

"   }}}
" }}}
" Mappings and Keys {{{1
"   Functions {{{2

function! s:Key(keys)
  let l:text = '< '
  let l:index = 1
  for l:each in a:keys
    if l:each == "\<Down>"
      let l:text = l:text . '↓'
    elseif l:each == "\<Up>"
      let l:text = l:text . '↑'
    elseif l:each == "\<Right>"
      let l:text = l:text . '→'
    elseif l:each == "\<Left>"
      let l:text = l:text . '←'
    elseif l:each == "\<S-Down>"
      let l:text = l:text . 'Shift ↓'
    elseif l:each == "\<S-Up>"
      let l:text = l:text . 'Shift ↑'
    elseif l:each == "\<S-Right>"
      let l:text = l:text . 'Shift →'
    elseif l:each == "\<S-Left>"
      let l:text = l:text . 'Shift ←'
    elseif l:each == "\<C-Down>"
      let l:text = l:text . 'Ctrl ↓'
    elseif l:each == "\<C-Up>"
      let l:text = l:text . 'Ctrl ↑'
    elseif l:each == "\<C-Right>"
      let l:text = l:text . 'Ctrl →'
    elseif l:each == "\<C-Left>"
      let l:text = l:text . 'Ctrl ←'
    elseif l:each == "\<Enter>"
      let l:text = l:text . 'Enter'
    elseif l:each == "\<Esc>"
      let l:text = l:text . 'Esc'
    elseif l:each == "\<BS>"
      let l:text = l:text . 'BackSpace'
    elseif l:each == "/"
      let l:text = l:text . 'Slash'
    elseif l:each == "\\"
      let l:text = l:text . 'BackSlash'
    elseif l:each == "|"
      let l:text = l:text . 'Bar'
    elseif l:each == "<"
      let l:text = l:text . 'Less'
    elseif l:each == ">"
      let l:text = l:text . 'Greater'
    else
      let l:text = l:text . l:each
    endif

    if l:index < len(a:keys)
      let l:text = l:text . ' | '
      let l:index += 1
    endif
  endfor
  return l:text . ' >'
endfunction

function! s:Mappings()
  let l:max = max(mapnew(s:mappings, { _, val -> len(split(val.key, '\zs')) }))
  let test = values(s:mappings)
  for l:each in sort(filter(values(s:mappings), 'v:val.order > 0'),
  \ { val1, val2 -> val1.order - val2.order })
    echon l:each.mode . ' '
    let l:start = match(l:each.key, '<.*>')
    if l:start > -1
      if l:start > 0
        echon l:each.key[0:l:start - 1]
      endif
      let l:end = matchend(l:each.key, '<.*>')
      echohl SpecialKey
      echon l:each.key[l:start:l:end - 1]
      echohl NONE
      if l:end < len(l:each.key)
        echon l:each.key[l:end:]
      endif
    else
      echon l:each.key
    endif
    echon repeat(' ', l:max - len(split(l:each.key, '\zs')) + 1)
      \ . l:each.description . "\n"
  endfor
endfunction

"   }}}
"   Variables & constants {{{2

if exists('s:leaders') | unlet s:leaders | endif
const s:leaders = #{
\   global: '²',
\   shift:  '³',
\ }

if exists('s:mappings') | unlet s:mappings | endif
const s:mappings = #{
\   search_replace:             #{ key:                                 ':',
  \ mode: 'v', description: 'Search and replace', order: 0 },
\   insensitive_search_replace: #{ key: s:leaders.global .              ':',
  \ mode: 'v', description: 'Case-insensitive search and replace', order: 1 },
\   insensitive_search:         #{ key: s:leaders.global .              '/',
  \ mode: 'n', description: 'Case-insensitive search', order: 2 },
\   paste_unnamed_reg:          #{ key: s:leaders.global .              'p',
  \ mode: 'c', description: 'Paste unnamed register in command-line', order: 3 },
\   vsplit_vimrc:               #{ key: s:leaders.global .              '&',
  \ mode: 'n', description: 'Open .vimrc in vertical split', order: 4 },
\   source_vimrc:               #{ key: s:leaders.shift  .              '1',
  \ mode: 'n', description: 'Source .vimrc', order: 5 },
\   nohighlight_search:         #{ key: s:leaders.global .              'é',
  \ mode: 'n', description: 'No highlight search', order: 6 },
\   next_window:                #{ key: s:leaders.global .        '<Right>',
  \ mode: 'n', description: 'Next window', order: 7 },
\   previous_window:            #{ key: s:leaders.global .         '<Left>',
  \ mode: 'n', description: 'Previous window', order: 8 },
\   next_search:                #{ key:                                 'n',
  \ mode: 'n', description: 'Next search', order: -1 },
\   previous_search:            #{ key:                                 'N',
  \ mode: 'n', description: 'Previous search', order: -1 },
\   unfold:                     #{ key:                           '<Space>',
  \ mode: 'n', description: 'Unfold', order: 9 },
\   follow_tag:                 #{ key: s:leaders.global .              't',
  \ mode: 'n', description: 'Follow tag under cursor', order: 10 },
\   next_tag:                   #{ key:                                'TT',
  \ mode: 'n', description: 'Next tag', order: 11 },
\   previous_tag:               #{ key:                                'tt',
  \ mode: 'n', description: 'Previous tag', order: 12 },
\   messages:                   #{ key: s:leaders.global .              'l',
  \ mode: 'n', description: 'Messages', order: 13 },
\   map:                        #{ key: s:leaders.global .              'm',
  \ mode: 'n', description: 'Mappings', order: 14 },
\   autocompletion:             #{ key:                           '<S-Tab>',
  \ mode: 'i', description: 'Auto-completion', order: 15 },
\   visualup:                   #{ key:                            '<S-Up>',
  \ mode: 'v', description: 'Move up visual block', order: 16 },
\   visualdown:                 #{ key:                          '<S-Down>',
  \ mode: 'v', description: 'Move down visual block', order: 17 },
\   blankup:                    #{ key: s:leaders.global .           '<CR>',
  \ mode: 'n', description: 'Blank line under current line', order: 18 },
\   blankdown:                  #{ key:                              '<CR>',
  \ mode: 'n', description: 'Blank line above current line', order: 19 },
\   tinsel:                     #{ key: s:leaders.global .              's',
  \ mode: 'n', description: 'Start Tinsel', order: 20 },
\   redhighlight:               #{ key: s:leaders.global .              '"',
  \ mode: 'n', description: 'Toggle Redhighlight', order: 21 },
\   buffers_menu:               #{ key: s:leaders.global . s:leaders.global,
  \ mode: 'n', description: 'Open Buffers Menu', order: 22 },
\   explorer:                   #{ key: s:leaders.shift  .  s:leaders.shift,
  \ mode: 'n', description: 'Open File Explorer', order: 23 },
\   obsession:                  #{ key: s:leaders.global .              'z',
  \ mode: 'n', description: 'Save session', order: 24 },
\   undotree:                   #{ key: s:leaders.shift  .              'U',
  \ mode: 'n', description: 'Open Undo Tree', order: 25 },
\   rainbow:                    #{ key: s:leaders.global.               '(',
  \ mode: 'n', description: 'Toggle Rainbow', order: 26 },
\ }

"   }}}

" search and replace
execute s:mappings.search_replace.mode             . 'noremap '
  \ . s:mappings.search_replace.key      . ' ' . s:search.sensitive_replace

" search and replace (case-insensitive)
execute s:mappings.insensitive_search_replace.mode . 'noremap '
  \ . s:mappings.insensitive_search_replace.key
  \ . ' ' . s:search.insensitive_replace

" search (case-insensitive)
execute s:mappings.insensitive_search.mode         . 'noremap '
  \ . s:mappings.insensitive_search.key  . ' ' . s:search.insensitive

" copy the unnamed register's content in the command line
" unnamed register = any text deleted or yank (with y)
execute s:mappings.paste_unnamed_reg.mode           . 'noremap '
  \ . s:mappings.paste_unnamed_reg.key    . ' <C-r><C-o>"'

" open .vimrc in a vertical split window
execute s:mappings.vsplit_vimrc.mode               . 'noremap '
  \ . s:mappings.vsplit_vimrc.key        . ' <Cmd>call <SID>OpenVimRC()<CR>'

" source .vimrc
execute s:mappings.source_vimrc.mode               . 'noremap '
  \ . s:mappings.source_vimrc.key        . ' <Cmd>call <SID>SourceVimRC()<CR>'

" stop highlighting from the last search
execute s:mappings.nohighlight_search.mode         . 'noremap '
  \ . s:mappings.nohighlight_search.key  . ' <Cmd>nohlsearch<CR>'

" toggle redhighlight
execute s:mappings.redhighlight.mode               . 'noremap '
  \ . s:mappings.redhighlight.key
  \ . ' <Cmd>call <SID>ToggleRedHighlight()<CR>'

" create session
execute s:mappings.obsession.mode                  . 'noremap '
  \ . s:mappings.obsession.key           . ' <Cmd>call <SID>Obsession()<CR>'

" statusline become a tinsel
execute s:mappings.tinsel.mode                     . 'noremap '
  \ . s:mappings.tinsel.key              . ' <Cmd>call <SID>InitTinsel()<CR>'

" buffers menu
execute s:mappings.buffers_menu.mode               . 'noremap '
  \ . s:mappings.buffers_menu.key        . ' <Cmd>call <SID>BuffersMenu()<CR>'

" explorer
execute s:mappings.explorer.mode                   . 'noremap '
  \ . s:mappings.explorer.key            . ' <Cmd>call <SID>Explorer()<CR>'

" undotree
execute s:mappings.undotree.mode                   . 'noremap '
  \ . s:mappings.undotree.key            . ' <Cmd>call <SID>Undotree()<CR>'

" toggle rainbow
execute s:mappings.rainbow.mode                    . 'noremap '
  \ . s:mappings.rainbow.key
  \ . ' <Cmd>call <SID>ToggleRainbow()<CR>'

" windows navigation
execute s:mappings.next_window.mode                . 'noremap '
  \ . s:mappings.next_window.key         . ' <Cmd>call <SID>NextWindow()<CR>'
execute s:mappings.previous_window.mode            . 'noremap '
  \ . s:mappings.previous_window.key
  \ . ' <Cmd>call <SID>PreviousWindow()<CR>'

" unfold vimscipt's folds
execute s:mappings.unfold.mode                     . 'noremap '
  \ . s:mappings.unfold.key              . ' <Cmd>call <SID>Unfold()<CR>'

" navigate between tags
execute s:mappings.follow_tag.mode                 . 'noremap '
  \ . s:mappings.follow_tag.key          . ' <Cmd>call <SID>FollowTag()<CR>'
execute s:mappings.next_tag.mode                   . 'noremap '
  \ . s:mappings.next_tag.key            . ' <Cmd>call <SID>NextTag()<CR>'
execute s:mappings.previous_tag.mode               . 'noremap '
  \ . s:mappings.previous_tag.key        . ' <Cmd>call <SID>PreviousTag()<CR>'

" for debug purposes
execute s:mappings.messages.mode                   . 'noremap '
  \ . s:mappings.messages.key            . ' <Cmd>messages<CR>'
execute s:mappings.map.mode                        . 'noremap '
  \ . s:mappings.map.key                 . ' <Cmd>call <SID>Mappings()<CR>'

" autocompletion
execute s:mappings.autocompletion.mode             . 'noremap '
  \ . s:mappings.autocompletion.key      . ' <C-n>'

" move visual block
execute s:mappings.visualup.mode                   . 'noremap <silent> '
  \ . s:mappings.visualup.key
  \ . ' :<C-u>silent call <SID>VisualUp()<CR>'
execute s:mappings.visualdown.mode                 . 'noremap <silent> '
  \ . s:mappings.visualdown.key
  \ . ' :<C-u>silent call <SID>VisualDown()<CR>'

" add blank lines
execute s:mappings.blankup.mode                    . 'noremap '
  \ . s:mappings.blankup.key             . ' <Cmd>call <SID>BlankUp()<CR>'
execute s:mappings.blankdown.mode                  . 'noremap '
  \ . s:mappings.blankdown.key           . ' <Cmd>call <SID>BlankDown()<CR>'

" centered search
execute s:mappings.next_search.mode                . 'noremap '
  \ . s:mappings.next_search.key         . ' <Cmd>call <SID>NextSearch()<CR>'
execute s:mappings.previous_search.mode            . 'noremap '
  \ . s:mappings.previous_search.key     . ' <Cmd>call <SID>PreviousSearch()<CR>'

" }}}
" Abbreviations {{{1

" avoid intuitive write usage
cnoreabbrev <expr> w (getcmdtype() == ':' ? "update" : "w")
cnoreabbrev <expr> wq (getcmdtype() == ':' ? "update \| quit" : "wq")

" save buffer as sudo user
cnoreabbrev <expr> sw (getcmdtype() == ':' ?
  \ "silent write ! sudo tee % > /dev/null \| echo ''" : "sw")

" avoid intuitive tabpage usage
cnoreabbrev <expr> tabe (getcmdtype() == ':' ? "silent tabonly" : "tabe")

" allow vertical split designation with bufnr instead of full filename
cnoreabbrev <expr> vb (getcmdtype() == ':' ? "vertical sbuffer" : "vb")

" next-previous intuitive usage for multi file opening
cnoreabbrev <expr> n (getcmdtype() == ':' ? "next" : "n")
cnoreabbrev <expr> p (getcmdtype() == ':' ? "previous" : "p")

" allow to ignore splitbelow option for help split
cnoreabbrev <expr> h (getcmdtype() == ':' ? "top help" : "h")
cnoreabbrev <expr> he (getcmdtype() == ':' ? "top help" : "he")
cnoreabbrev <expr> hel (getcmdtype() == ':' ? "top help" : "hel")
cnoreabbrev <expr> help (getcmdtype() == ':' ? "top help" : "help")

" }}}
" Autocommands {{{1

augroup vimrc_autocomands
  autocmd!
"   Dependencies autocommands {{{2

  autocmd VimEnter * :call <SID>CheckDependencies()

"   }}}
"   VimRC sourcing autocommands {{{2

  autocmd BufWritePost $MYVIMRC :silent call <SID>SourceVimRC()

"   }}}
"   Save-as-sudo loading autocommands {{{2

  " reload file automatically after sudo save command
  autocmd FileChangedShell * let v:fcs_choice="reload"

"   }}}
"   Color autocommands {{{2

  autocmd WinEnter * set wincolor=NormalAlt

"   }}}
"   Redhighlight autocommands {{{2

  autocmd BufEnter * :silent call <SID>RedHighlight()

"   }}}
"   Buffers autocommands {{{2

  autocmd BufEnter * :silent call <SID>CloseLonelyUnlistedBuffers()

"   }}}
"   Plugins autocommands {{{2
"     Obsession autocommands {{{3

  autocmd VimEnter * nested :call <SID>SourceObsession()
  autocmd VimLeavePre * :call <SID>PromptObsession()

"     }}}
"     Gutentags autocommands {{{3

  autocmd BufEnter * :silent call <SID>HighlightGutentags()
  autocmd VimEnter,BufWritePost * :silent call <SID>GenerateGutentags()

"     }}}
"     Rainbow autocommands {{{3

  autocmd BufEnter * :silent call <SID>RefreshRainbow()

"     }}}
"   }}}
"   Filetype specific autocommands {{{2
"     Bash autocommands {{{3

  autocmd BufNewFile *.sh :call <SID>PrefillShFile()

"     }}}
"     Yaml autocommands {{{3

  autocmd BufNewFile *.yml,*.yaml :call <SID>PrefillYamlFile()

"     }}}
"   }}}
"   Folds autocommands {{{2

  autocmd FileType vim,tmux,sh setlocal foldmethod=marker

"   }}}
augroup END

" }}}
