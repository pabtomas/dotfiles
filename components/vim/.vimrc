" Dependencies {{{1

function! s:CheckDependencies()
  if !has('unix')
    echohl ErrorMsg
    echomsg 'Personal Error Message: your VimRC needs UNIX OS to be'
      \ . ' functionnal'
    echohl NONE
  endif
  if v:version < 802
    let l:major_version = v:version / 100
    echohl ErrorMsg
    echomsg 'Personal Error Message: your VimRC needs Vim 8.2 to be'
      \ . ' functionnal. Your Vim version is ' l:major_version . '.'
      \ . (v:version - l:major_version * 100)
    echohl NONE
    quit
  endif
endfunction

" }}}
" Quality of life {{{1
"   Options {{{2

" Vi default options unused
set nocompatible

" Remove all bell
set belloff=all
set noerrorbells
set visualbell

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

" use popup menu & additional info when completion is used
set completeopt=menu,preview

" specify which shell use with shell commands
set shell=/usr/local/bin/bash

" more pairs for % command and MatchParen highlight
set matchpairs+=<:>

let g:zig_fmt_autosave = 0
let g:loaded_netrwPlugin = 1

"     Performance {{{3

" draw only when needed
set lazyredraw

" indicates terminal connection
set ttyfast

"     }}}
"   }}}
"   Variables & constants {{{2

if exists('s:MODES') | unlet s:MODES | endif
const s:MODES = {
\   'n': 'NORMAL', 'i': 'INSERT', 'R': 'REPLACE', 'v': 'VISUAL',
\   'V': 'VISUAL', "\<C-v>": 'VISUAL-BLOCK', 'c': 'COMMAND', 's': 'SELECT',
\   'S': 'SELECT-LINE', "\<C-s>": 'SELECT-BLOCK', 't': 'TERMINAL',
\   'r': 'PROMPT', '!': 'SHELL',
\ }

"   }}}
"   Search {{{2
"     Variables & constants {{{3

if exists('s:SEARCH') | unlet s:SEARCH | endif
const s:SEARCH = #{
\   sensitive_replace: ':s/\%V\%V//g<Left><Left><Left><Left><Left>',
\   insensitive_replace: ':s/\%V\c\%V//g<Left><Left><Left><Left><Left>',
\   insensitive: '/\c',
\ }

"     }}}
"     Functions {{{3

function! s:NextSearch()
  try
    normal! n
    if foldlevel('.') > 0 | foldopen! | endif
    normal! zz
  catch
    echohl ErrorMsg
    echomsg matchstr(v:exception, 'E[0-9]*: .*')
    echohl NONE
  endtry
endfunction

function! s:PreviousSearch()
  try
    normal! N
    if foldlevel('.') > 0 | foldopen! | endif
    normal! zz
  catch
    echohl ErrorMsg
    echomsg matchstr(v:exception, 'E[0-9]*: .*')
    echohl NONE
  endtry
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

function! s:NextBuffer()
  let l:buffers_nr = sort(map(getbufinfo(#{ buflisted: 1 }), { _, val -> val.bufnr }), 'N')
  if len(l:buffers_nr) > 1
    while get(l:buffers_nr, 0) != bufnr()
      let l:buffers_nr = add(l:buffers_nr, remove(l:buffers_nr, 0))
    endwhile
    execute 'buffer ' . get(l:buffers_nr, 1)
    redraw!
  endif
endfunction

function! s:PreviousBuffer()
  let l:buffers_nr = sort(map(getbufinfo(#{ buflisted: 1 }), { _, val -> val.bufnr }), 'N')
  if len(l:buffers_nr) > 1
    while get(l:buffers_nr, 0) != bufnr()
      let l:buffers_nr = add(l:buffers_nr, remove(l:buffers_nr, 0))
    endwhile
    execute 'buffer ' . get(l:buffers_nr, -1)
    redraw!
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
  if &modifiable
    if line('.') - v:count1 > 0
      execute "'" . '<,' . "'" . '>move ' . "'" . '<-' . (v:count1 + 1)
    else
      '<,'>move 0
    endif
    normal! gv
  endif
endfunction

function! s:VisualDown()
  if &modifiable
    if line('.') + line("'>") - line ("'<") + v:count1 > line('$')
      '<,'>move $
    else
      execute "'" . '<,' . "'" . '>move ' . "'" . '>+' . v:count1
    endif
    normal! gv
  endif
endfunction

"     }}}
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
"   Statusline {{{2
"     Options {{{3

" display status line
set laststatus=2

"     }}}
"     Variables & constants {{{3

let s:statusline = #{
\   matches: {},
\ }

"     }}}
"     Functions {{{3

function! FileName(modified)
  if (&modified != a:modified)
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
    if v:hlsearch && !empty(s:statusline.matches) && (s:statusline.matches.total > 0)
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
  return s:MODES[mode()[0]]
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
  let s:statusline.matches =
    \ searchcount(#{ recompute: 1, maxcount: 0, timeout: 0 })
  if empty(s:statusline.matches) || (s:statusline.matches.total == 0)
    return ''
  endif
  return s:statusline.matches.current
endfunction

function! Bar()
  if (g:actual_curwin != win_getid()) || !v:hlsearch
  \ || empty(s:statusline.matches) || (s:statusline.matches.total == 0)
    return ''
  endif
  return '/'
endfunction

function! TotalMatch()
  if (g:actual_curwin != win_getid()) || !v:hlsearch
  \ || empty(s:statusline.matches) || (s:statusline.matches.total == 0)
    return ''
  endif
  return s:statusline.matches.total . ' '
endfunction

" status line content:
" [winnr] bufnr:filename [filetype] col('.') line('.')/line('$') [mode] matches
function! s:StatusLineData()
  set statusline+=\ %4*[%3*%{winnr()}%4*]\ %3*%{bufnr()}%4*:%0*
                   \%2*%{FileName(v:false)}%0*
                   \%1*%{FileName(v:true)}%0*
  set statusline+=\ %4*[%3*%{&filetype}%4*]%0*
  set statusline+=\ %4*C%3*%{virtcol('.')}%0*
  set statusline+=\ %4*L%3*%{line('.')}%4*/%3*%{line('$')}\ %0*
  set statusline+=%4*%{StartMode()}%3*%{Mode()}%4*%{EndMode()}%0*
  set statusline+=%3*%{IndexedMatch()}%4*%{Bar()}%3*%{TotalMatch()}%0*
endfunction

function! s:RestoreStatusLines(timer_id)
  execute  'highlight StatusLine   cterm=bold ctermfg='
    \ . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight StatusLineNC cterm=NONE ctermfg='
    \ . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight VertSplit    cterm=NONE ctermfg='
    \ . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.gray_900
endfunction

function! s:HighlightStatusLines()
  execute  'highlight StatusLine   ctermfg=' . s:PALETTE.green
    \ . ' | highlight StatusLineNC ctermfg=' . s:PALETTE.green
    \ . ' | highlight VertSplit    ctermfg=' . s:PALETTE.green
  call timer_start(1000, function('s:RestoreStatusLines'))
endfunction

function! s:StaticLine()
  set statusline=%{StartLine()}
  call s:StatusLineData()
  set statusline+=%{EndLine()}
endfunction

"     }}}

call s:StaticLine()

"   }}}
"   Tag {{{2

function! s:FollowTag()
  try
    let l:iskeyword_backup = ''
    if &filetype == 'vim'
      let l:iskeyword_backup = &iskeyword
      setlocal iskeyword+=:
    endif
    let l:cword = expand('<cword>')
    execute 'tag ' . l:cword
    if foldlevel('.') > 0 | foldopen! | endif
    if len(taglist('^' . l:cword . '$')) == 1
      normal! zz
    endif
    if !empty(l:iskeyword_backup)
      let &iskeyword = l:iskeyword_backup
    endif
  catch
    echohl ErrorMsg
    echomsg matchstr(v:exception, 'E[0-9]*: .*')
    echohl NONE
  endtry
endfunction

function! s:NextTag()
  try
    tag
    if foldlevel('.') > 0 | foldopen! | endif
    normal! zz
  catch
    echohl ErrorMsg
    echomsg matchstr(v:exception, 'E[0-9]*: .*')
    echohl NONE
  endtry
endfunction

function! s:PreviousTag()
  try
    pop
    if foldlevel('.') > 0 | foldopen! | endif
    normal! zz
  catch
    echohl ErrorMsg
    echomsg matchstr(v:exception, 'E[0-9]*: .*')
    echohl NONE
  endtry
endfunction

"   }}}
"   Tmux {{{2

function! s:ToggleTmuxCopy()
  if &number || &list
    set nonumber nolist
  else
    set number list
  endif
endfunction

"   }}}
"   Comments {{{2

function! s:SetCommentString()
  if (&filetype == "c") || (&filetype == "cpp") || (&filetype == "glsl")
    \ || (&filetype == "rust") || (&filetype == "zig")
      setlocal commentstring=//%s
  elseif (&filetype == "conf") || (&filetype == "make")
    \ || (&filetype == "tmux") || (&filetype == "sh")
    \ || (&filetype == "yaml")
      setlocal commentstring=#%s
  elseif &filetype == "vim"
    setlocal commentstring=\"%s
  endif
endfunction

function! s:Comment(visual)
  const l:DELIMITER = &commentstring[:match(&commentstring, "%s") - 1]
  let l:min_limit = line('.')
  let l:max_limit = line('.')
  if a:visual
    let l:min_limit = line("'<")
    let l:max_limit = line("'>")
  endif
  for l:lineno in range(l:min_limit, l:max_limit)
    let l:line = getline(l:lineno)
    if !empty(l:line)
      if match(l:line, '^[[:space:]]*' . l:DELIMITER . ' ') == -1
        call setline(l:lineno, l:DELIMITER . ' ' . l:line)
      endif
    endif
  endfor
endfunction

function! s:Uncomment(visual)
  const l:DELIMITER = &commentstring[:match(&commentstring, "%s") - 1]
  let l:min_limit = line('.')
  let l:max_limit = line('.')
  if a:visual
    let l:min_limit = line("'<")
    let l:max_limit = line("'>")
  endif
  for l:lineno in range(l:min_limit, l:max_limit)
    let l:line = getline(l:lineno)
    if !empty(l:line)
      let [l:match, l:start, l:end] =
        \ matchstrpos(l:line, '^[[:space:]]*' . l:DELIMITER . ' ')
      if !empty(l:match) || (l:start > 0) || (l:end > 0)
        call setline(l:lineno, l:line[l:end:])
      endif
    endif
  endfor
endfunction

"   }}}
"   Server {{{2
"     Variables & constants {{{3

if exists('s:SERVER_PREFIX') | unlet s:SERVER_PREFIX | endif
const s:SERVER_PREFIX = 'VIM-'

if !exists('s:servers') | let s:servers = {} | endif

"     }}}
"     Functions {{{3

function! s:StartServer(app, id)
  if has('clientserver')
    if empty(v:servername)
      call remote_startserver(s:SERVER_PREFIX . a:id)
    endif
    let s:servers[a:app] = #{ reachable: v:true }
  else
    echohl ErrorMsg
    echomsg 'Personal Error Message: Vim needs to be compiled with'
      \ . ' +clientserver feature to use this command'
    echohl NONE
  endif
endfunction

function! s:LockServer(app)
  if exists('s:servers["' . a:app . '"].reachable')
    let s:servers[a:app].reachable = v:false
  endif
endfunction

function! s:UnlockServer(app)
  if exists('s:servers["' . a:app . '"].reachable')
    let s:servers[a:app].reachable = v:true
  endif
endfunction

function! s:IsServerReachable(app)
  if exists('s:servers["' . a:app . '"].reachable')
    return s:servers[a:app].reachable == v:true
  else
    return 0
  endif
endfunction

"     }}}
"   }}}
" }}}
" Style {{{1
"   Palette {{{2

let s:PALETTE = #{}
let s:PALETTE.green = $GREEN
let s:PALETTE.gray_900 = $GRAY_900
let s:PALETTE.gray_800 = $GRAY_800
let s:PALETTE.gray_700 = $GRAY_700
let s:PALETTE.gray_600 = $GRAY_600
let s:PALETTE.gray_500 = $GRAY_500
let s:PALETTE.gray_400 = $GRAY_400
let s:PALETTE.zinc = $ZINC
let s:PALETTE.white = $WHITE
let s:PALETTE.theme = $THEME

"   }}}
"   Colors {{{2

function s:LoadColorscheme()
  set t_Co=256
  set t_ut=
  set background=dark
  if exists('g:syntax_on') | syntax reset | endif
  set wincolor=NormalAlt

  highlight clear

  " https://github.com/n1ghtmare/noirblaze-vim/blob/master/colors/noirblaze.vim
  " Default
  execute ' highlight       Comment                                ctermfg=' . s:PALETTE.gray_800 . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       Constant                               ctermfg=' . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       Character                              ctermfg=' . s:PALETTE.gray_700 . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       Identifier                             ctermfg=' . s:PALETTE.white    . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       Statement                              ctermfg=' . s:PALETTE.gray_500 . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       PreProc                                ctermfg=' . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       Type                                   ctermfg=' . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       Special                                ctermfg=' . s:PALETTE.gray_700 . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       Underlined                             ctermfg=' . s:PALETTE.gray_500 . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       Error               cterm=bold         ctermfg=' . s:PALETTE.gray_900 . ' ctermbg=' . s:PALETTE.theme
    \ . ' | highlight       Todo                cterm=bold         ctermfg=' . s:PALETTE.gray_900 . ' ctermbg=' . s:PALETTE.theme
    \ . ' | highlight       Function                               ctermfg=' . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       ColorColumn                                                               ctermbg=' . s:PALETTE.zinc
    \ . ' | highlight       Conceal                                ctermfg=' . s:PALETTE.gray_800 . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       Cursor                                 ctermfg=' . s:PALETTE.gray_900 . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       CursorColumn                                                              ctermbg=' . s:PALETTE.zinc
    \ . ' | highlight       CursorLine          cterm=NONE                                            ctermbg=' . s:PALETTE.zinc
    \ . ' | highlight       DiffAdd                                ctermfg=' . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       DiffDelete                             ctermfg=' . s:PALETTE.gray_700 . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       ErrorMsg                               ctermfg=' . s:PALETTE.gray_900 . ' ctermbg=' . s:PALETTE.theme
    \ . ' | highlight       VertSplit           cterm=NONE         ctermfg=' . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       Folded                                 ctermfg=' . s:PALETTE.gray_600 . ' ctermbg=' . s:PALETTE.zinc
    \ . ' | highlight       FoldColumn                             ctermfg=' . s:PALETTE.gray_600 . ' ctermbg=' . s:PALETTE.zinc
    \ . ' | highlight       IncSearch                              ctermfg=' . s:PALETTE.gray_900 . ' ctermbg=' . s:PALETTE.white
    \ . ' | highlight       LineNr                                 ctermfg=' . s:PALETTE.zinc     . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       CursorLineNr                           ctermfg=' . s:PALETTE.gray_700 . ' ctermbg=' . s:PALETTE.zinc
    \ . ' | highlight       MatchParen                                                                ctermbg=' . s:PALETTE.gray_800
    \ . ' | highlight       MoreMsg                                ctermfg=' . s:PALETTE.gray_900 . ' ctermbg=' . s:PALETTE.gray_700
    \ . ' | highlight       NonText                                ctermfg=' . s:PALETTE.zinc     . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       Pmenu                                  ctermfg=' . s:PALETTE.gray_400 . ' ctermbg=' . s:PALETTE.zinc
    \ . ' | highlight       PmenuSel                               ctermfg=' . s:PALETTE.gray_500 . ' ctermbg=' . s:PALETTE.gray_800
    \ . ' | highlight       PmenuSbar                              ctermfg=' . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.zinc
    \ . ' | highlight       PmenuThumb                             ctermfg=' . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.gray_800
    \ . ' | highlight       Question                               ctermfg=' . s:PALETTE.white    . ' ctermbg=' . s:PALETTE.zinc
    \ . ' | highlight       Search                                 ctermfg=' . s:PALETTE.gray_900 . ' ctermbg=' . s:PALETTE.white
    \ . ' | highlight       SpecialKey                             ctermfg=' . s:PALETTE.gray_700 . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       SpellBad            cterm=undercurl    ctermfg=' . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       SpellCap            cterm=undercurl    ctermfg=' . s:PALETTE.white    . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       SpellLocal                             ctermfg=' . s:PALETTE.gray_700 . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       SpellRare                              ctermfg=' . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       StatusLine          cterm=bold         ctermfg=' . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       StatusLineNC        cterm=NONE         ctermfg=' . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       Title                                  ctermfg=' . s:PALETTE.gray_500 . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       Visual              cterm=reverse'
    \ . ' | highlight       WarningMsg                             ctermfg=' . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       WildMenu            cterm=bold         ctermfg=' . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.gray_800
    \ . ' | highlight       Menu                                   ctermfg=' . s:PALETTE.gray_500 . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       Tag                 cterm=underline'
    \ . ' | highlight       Punctuation         cterm=bold         ctermfg=' . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       Kind                cterm=bold         ctermfg=' . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.gray_900

  " Plugin
  execute  'highlight       OpenedDirPath       cterm=bold         ctermfg=' . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.zinc
    \ . ' | highlight       Help                cterm=bold         ctermfg=' . s:PALETTE.gray_700 . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       HelpKey             cterm=bold         ctermfg=' . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       HelpMode            cterm=bold         ctermfg=' . s:PALETTE.white    . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       PopupSelelected                        ctermfg=' . s:PALETTE.gray_700 . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       Button              cterm=bold,reverse ctermfg=' . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       UndoPopup                              ctermfg=' . s:PALETTE.gray_400 . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       MappingPunctuation  cterm=bold         ctermfg=' . s:PALETTE.gray_400 . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       MappingKind         cterm=bold         ctermfg=' . s:PALETTE.gray_600 . ' ctermbg=' . s:PALETTE.gray_900

  " Normal
  execute  'highlight       Normal              cterm=bold         ctermfg=' . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       NormalAlt           cterm=NONE         ctermfg=' . s:PALETTE.white    . ' ctermbg=' . s:PALETTE.gray_900

  " StatusLine
  execute  'highlight       User1               cterm=bold         ctermfg=' . s:PALETTE.theme    . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       User2               cterm=bold         ctermfg=' . s:PALETTE.white    . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       User3               cterm=bold         ctermfg=' . s:PALETTE.gray_400 . ' ctermbg=' . s:PALETTE.gray_900
    \ . ' | highlight       User4               cterm=bold         ctermfg=' . s:PALETTE.gray_600 . ' ctermbg=' . s:PALETTE.gray_900


  highlight  link String             Constant
  highlight  link Number             Constant
  highlight  link Boolean            Constant
  highlight  link Float              Number
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
  highlight! link StatusLineTerm     StatusLine
  highlight! link StatusLineTermNC   StatusLineNC

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

"   }}}
"   Folds {{{2
"     Functions {{{3

function! s:Unfold()
  try
    normal! za
  catch
    echohl ErrorMsg
    echomsg matchstr(v:exception, 'E[0-9]*: .*')
    echohl NONE
  endtry
endfunction

function! FoldText()
  return substitute(substitute(foldtext(), '\s*\(\d\+\)',
    \ repeat('-', 10 - len(string(v:foldend - v:foldstart + 1))) . ' \1', ''),
    \ '\(\a\+\)\s\?: ["#]\s\+', '\1 ', '')
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
"   Obsession {{{2
"     Keys {{{3

if exists('s:OBESSION_KEY') | unlet s:OBESSION_KEY | endif
const s:OBESSION_KEY = #{
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
  echomsg 'Session saved !'
endfunction

function! s:SourceObsession()
  if !argc() && empty(v:this_session) && filereadable('Session.vim')
    \ && !&modified
    source Session.vim
  endif
endfunction

"     }}}
"   }}}
"   Undotree {{{2
"     Options {{{3

set undofile
set undolevels=1000
set undodir=~/.cache/vim/undo
if !isdirectory(&undodir)
  call mkdir(&undodir, "p", 0700)
endif

"     }}}
"     Functions {{{3

function! s:ToggleUndotree()
  UndotreeToggle
endfunction

"     }}}
"   }}}
"   Rainbow {{{2
"     Variables & constants {{{3

let g:rainbow_active = 0
let g:rainbow_conf = #{
\   ctermfgs: [ 196, 208, 226, 40, 45, 33, 129, 201, ],
\ }

"     }}}
"     Functions {{{3

function! s:ActivateRainbow()
  syntax clear
  RainbowToggleOn
endfunction

function! s:ToggleRainbow()
  if !exists("b:toggle_rainbow")
    let b:toggle_rainbow = 0
  endif
  if b:toggle_rainbow == 0
    call s:ActivateRainbow()
  else
    syntax enable
    call s:LoadColorscheme()
    let l:buf_backup = bufnr()
    let l:savedview = winsaveview()
    let l:eventignore_backup = &eventignore
    set eventignore=all

    for l:each in map(filter(getbufinfo(), 'v:val.listed || !v:val.hidden'), 'v:val.bufnr')
      if l:each != l:buf_backup
        execute 'buffer ' . l:each
        if b:toggle_rainbow != 0
          call s:ActivateRainbow()
        endif
      endif
    endfor

    execute 'buffer ' . l:buf_backup
    call winrestview(l:savedview)
    let &eventignore = l:eventignore_backup
  endif
  let b:toggle_rainbow = 1 - b:toggle_rainbow
endfunction

"     }}}
"   }}}
" }}}
" Filetype specific {{{1
"   Bash {{{2

function! s:PrefillShFile()
  call append(0, [
  \                '#!/bin/sh',
  \                '',
  \              ])
endfunction

"   }}}
"   Zig {{{2

function! s:PrefillZigFile()
  call append(0, [
  \                'const std = @import ("std");',
  \                '',
  \              ])
endfunction

"   }}}
" }}}
" Mappings and Keys {{{1
"   Variables & constants {{{2

if exists('s:LEADERS') | unlet s:LEADERS | endif
const s:LEADERS = #{ global: '²', shift: '³', }

if exists('s:MAPPINGS') | unlet s:MAPPINGS | endif
const s:MAPPINGS = {
\   'SEARCH': [
\     #{
\       description: 'Next search',
\       keys: 'n',
\       mode: 'n',
\       command: '<Cmd>call <SID>NextSearch()<CR>',
\       hidden: v:true,
\     },
\     #{
\       description: 'Previous search',
\       keys: 'N',
\       mode: 'n',
\       command: '<Cmd>call <SID>PreviousSearch()<CR>',
\       hidden: v:true,
\     },
\     #{
\       description: 'Search and replace in visual area',
\       keys: ':',
\       mode: 'v',
\       command: s:SEARCH.sensitive_replace,
\       hidden: v:true,
\     },
\     #{
\       description: 'Case-insensitive search and replace',
\       keys: s:LEADERS.global . ':',
\       mode: 'v',
\       command: s:SEARCH.insensitive_replace,
\     },
\     #{
\       description: 'Case-insensitive search',
\       keys: s:LEADERS.global . '/',
\       mode: 'n',
\       command: s:SEARCH.insensitive,
\     },
\     #{
\       description: 'Insert anti-slash character easier',
\       keys: s:LEADERS.global . s:LEADERS.global,
\       mode: 'c',
\       command: '\',
\     },
\     #{
\       description: 'Insert cursor sequence easier',
\       keys: s:LEADERS.shift . s:LEADERS.shift,
\       mode: 'c',
\       command: '\zs',
\     },
\   ],
\   'HIGHLIGHT & COLORS': [
\     #{
\       description: 'No highlight search',
\       keys: s:LEADERS.global . 'é',
\       mode: 'n',
\       command: '<Cmd>nohlsearch<CR>',
\     },
\     #{
\       description: 'Toggle Redhighlight',
\       keys: s:LEADERS.global . '"',
\       mode: 'n',
\       command: '<Cmd>call <SID>ToggleRedHighlight()<CR>',
\     },
\     #{
\       description: 'Toggle Rainbow',
\       keys: s:LEADERS.global . '(',
\       mode: 'n',
\       command: '<Cmd>call <SID>ToggleRainbow()<CR>',
\     },
\   ],
\   'BUFFERS': [
\     #{
\       description: 'Next buffer',
\       keys: 'gt',
\       mode: 'n',
\       command: '<Cmd>call <SID>NextBuffer()<CR>',
\     },
\     #{
\       description: 'Previous buffer',
\       keys: 'tg',
\       mode: 'n',
\       command: '<Cmd>call <SID>PreviousBuffer()<CR>',
\     },
\   ],
\   'WINDOWING': [
\     #{
\       description: 'Next window',
\       keys: s:LEADERS.global . '<Right>',
\       mode: 'n',
\       command: '<Cmd>call <SID>NextWindow()<CR>',
\     },
\     #{
\       description: 'Previous window',
\       keys: s:LEADERS.global . '<Left>',
\       mode: 'n',
\       command: '<Cmd>call <SID>PreviousWindow()<CR>',
\     },
\     #{
\       keys: s:LEADERS.global . '=',
\       mode: 'n',
\       command: '<C-w>=',
\       description: 'Equalize splits',
\     },
\   ],
\   'TAGS': [
\     #{
\       description: 'Follow tag under cursor',
\       keys: s:LEADERS.global . 't',
\       mode: 'n',
\       command: '<Cmd>call <SID>FollowTag()<CR>',
\     },
\     #{
\       description: 'Next tag',
\       keys: 'TT',
\       mode: 'n',
\       command: '<Cmd>call <SID>NextTag()<CR>',
\     },
\     #{
\       description: 'Previous tag',
\       keys: 'tt',
\       mode: 'n',
\       command: '<Cmd>call <SID>PreviousTag()<CR>',
\     },
\   ],
\   'DEBUG': [
\     #{
\       description: 'Display log',
\       keys: s:LEADERS.global . 'l',
\       mode: 'n',
\       command: '<Cmd>messages<CR>',
\     },
\     #{
\       description: 'Clear log',
\       keys: s:LEADERS.shift . 'L',
\       mode: 'n',
\       command: '<Cmd>messages clear <Bar> messages<CR>',
\     },
\     #{
\       description: 'List mappings',
\       keys: s:LEADERS.global . 'm',
\       mode: 'n',
\       command: '<Cmd>call <SID>ListMappings()<CR>',
\     },
\   ],
\   'POPUPS': [
\     #{
\       description: 'Toggle Undotree',
\       keys: s:LEADERS.shift . 'U',
\       mode: 'n',
\       command: '<Cmd>call <SID>ToggleUndotree()<CR>',
\     },
\   ],
\   'VISUAL': [
\     #{
\       description: 'Select last visual block',
\       keys: s:LEADERS.global . 'v',
\       mode: 'n',
\       command: 'gv',
\     },
\     #{
\       description: 'Move up visual block',
\       keys: '<S-Up>',
\       mode: 'v',
\       command: ':<C-u>silent call <SID>VisualUp()<CR>',
\     },
\     #{
\       description: 'Move down visual block',
\       keys: '<S-Down>',
\       mode: 'v',
\       command: ':<C-u>silent call <SID>VisualDown()<CR>',
\     },
\     #{
\       description: 'Comment visual area',
\       keys: s:LEADERS.global . 'c',
\       mode: 'v',
\       command: ':<C-u>silent call <SID>Comment(v:true)<CR>',
\     },
\     #{
\       description: 'Uncomment visual area',
\       keys: s:LEADERS.shift . 'C',
\       mode: 'v',
\       command: ':<C-u>silent call <SID>Uncomment(v:true)<CR>',
\     },
\     #{
\       description: 'Toggle start/end of visual area',
\       keys: 'ù',
\       mode: 'v',
\       command: 'o',
\     },
\   ],
\   'UNCLASSIFIED': [
\     #{
\       description: 'Unfold',
\       keys: '<Space>',
\       mode: 'n',
\       command: '<Cmd>call <SID>Unfold()<CR>',
\     },
\     #{
\       description: 'Deep unfold in visual area',
\       keys: '<Space>',
\       mode: 'v',
\       command: ':foldopen!<CR>',
\     },
\     #{
\       description: 'Comment current line',
\       keys: s:LEADERS.global . 'c',
\       mode: 'n',
\       command: ':<C-u>silent call <SID>Comment(v:false)<CR>',
\     },
\     #{
\       description: 'Uncomment current line',
\       keys: s:LEADERS.shift . 'C',
\       mode: 'n',
\       command: ':<C-u>silent call <SID>Uncomment(v:false)<CR>',
\     },
\     #{
\       description: 'Paste unnamed register in command-line',
\       keys: s:LEADERS.global . 'p',
\       mode: 'c',
\       command: '<C-r><C-o>"',
\     },
\     #{
\       description: 'Auto-completion',
\       keys: '<S-Tab>',
\       mode: 'i',
\       command: '<C-n>',
\     },
\     #{
\       description: 'Save session',
\       keys: s:LEADERS.global . 'z',
\       mode: 'n',
\       command: '<Cmd>call <SID>Obsession()<CR>',
\     },
\     #{
\       description: 'Matchit',
\       keys: 'ù',
\       mode: 'n',
\       command: '%',
\     },
\     #{
\       description: 'Toggle number and list options',
\       keys: s:LEADERS.global . 'n',
\       mode: 'n',
\       command: '<Cmd>call <SID>ToggleTmuxCopy()<CR>',
\     },
\   ],
\ }

"   }}}
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
      let l:text = l:text . 'S ↓'
    elseif l:each == "\<S-Up>"
      let l:text = l:text . 'S ↑'
    elseif l:each == "\<S-Right>"
      let l:text = l:text . 'S →'
    elseif l:each == "\<S-Left>"
      let l:text = l:text . 'S ←'
    elseif l:each == "\<C-Down>"
      let l:text = l:text . 'C ↓'
    elseif l:each == "\<C-Up>"
      let l:text = l:text . 'C ↑'
    elseif l:each == "\<C-Right>"
      let l:text = l:text . 'C →'
    elseif l:each == "\<C-Left>"
      let l:text = l:text . 'C ←'
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

function! s:ListMappings()
  const l:MAX_KEYS = max(mapnew(flatten(values(s:MAPPINGS)),
    \ { key, val -> len(split(val.keys, '\zs')) }))
  const l:MAX_MODES = max(mapnew(values(s:MODES), 'len(v:val)'))
  for [l:type, l:submappings] in items(s:MAPPINGS)
    echohl MappingPunctuation
    echon '----- '
    echohl NONE
    echohl MappingKind
    echon l:type
    echohl NONE
    echohl MappingPunctuation
    echon ' ' . repeat('-', 80 - len(l:type) - 7) . "\n"
    echohl NONE
    for l:each in l:submappings
      if !has_key(l:each, 'hidden')
        echon tolower(s:MODES[l:each.mode])
          \ . repeat(' ', l:MAX_MODES + 1 - len(s:MODES[l:each.mode]))
        let l:start = match(l:each.keys, '<.*>')
        if l:start > -1
          if l:start > 0
            echon l:each.keys[0:l:start - 1]
          endif
          let l:end = matchend(l:each.keys, '<.*>')
          echohl SpecialKey
          echon l:each.keys[l:start:l:end - 1]
          echohl NONE
          if l:end < len(l:each.keys)
            echon l:each.keys[l:end:]
          endif
        else
          echon l:each.keys
        endif
        echon repeat(' ', l:MAX_KEYS - len(split(l:each.keys, '\zs')) + 1)
          \ . l:each.description . "\n"
      endif
    endfor
  endfor
endfunction

function! s:DefineMappings()
  for l:submappings in values(s:MAPPINGS)
    for l:each in l:submappings
      execute l:each.mode . 'noremap ' . l:each.keys . ' ' . l:each.command
    endfor
  endfor
endfunction

"   }}}

call s:DefineMappings()

" }}}
" Abbreviations {{{1

" avoid intuitive write usage
cnoreabbrev <expr> w (getcmdtype() == ':' ? "update" : "w")
cnoreabbrev <expr> wq (getcmdtype() == ':' ? "update \| quit" : "wq")

" avoid intuitive tabpage usage
cnoreabbrev <expr> tabe (getcmdtype() == ':' ? "silent tabonly" : "tabe")

" allow vertical split designation with bufnr instead of full filename
cnoreabbrev <expr> vb (getcmdtype() == ':' ? "vertical sbuffer" : "vb")

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

"     }}}
"   }}}
"   Filetype specific autocommands {{{2
"     Bash autocommands {{{3

  autocmd BufNewFile *.sh :call <SID>PrefillShFile()

"     }}}
"     Zig autocommands {{{3

  autocmd BufNewFile *.zig :call <SID>PrefillZigFile()

"     }}}
"   }}}
"   Comments autocommands {{{2

  autocmd BufEnter * :call <SID>SetCommentString()

"   }}}
"   Folds autocommands {{{2

  autocmd FileType vim,tmux,sh setlocal foldmethod=marker

"   }}}
augroup END

" }}}
