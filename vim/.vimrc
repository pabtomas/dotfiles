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
"   Variables & constants {{{2

if exists('s:MODES') | unlet s:MODES | endif
const s:MODES = {
\   'n': 'NORMAL', 'i': 'INSERT', 'R': 'REPLACE', 'v': 'VISUAL',
\   'V': 'VISUAL', "\<C-v>": 'VISUAL-BLOCK', 'c': 'COMMAND', 's': 'SELECT',
\   'S': 'SELECT-LINE', "\<C-s>": 'SELECT-BLOCK', 't': 'TERMINAL',
\   'r': 'PROMPT', '!': 'SHELL',
\ }

"   }}}
"   User autocommand {{{2
"     Variables {{{3

let s:user_events = #{
  \ lines: &lines,
  \ columns: &columns,
  \ buffers: [],
\ }

"     }}}
"     Functions {{{3

function! s:TriggerUserEvents(timer_id)
  let l:buffers_nr = sort(map(getbufinfo(#{ buflisted: 1 }), { _, val -> val.bufnr }), 'N')
  let l:buffers = map(l:buffers_nr, { nr -> #{ name: bufname(nr), nr: nr, hidden: empty(win_findbuf(nr)) } })
  if s:user_events.buffers != l:buffers
    doautocmd User BuffersListChanged
    let s:user_events.buffers = l:buffers
  endif
  if s:user_events.lines != &lines
    doautocmd User Resized
    let s:user_events.lines = &lines
  endif
  if s:user_events.columns != &columns
    doautocmd User Resized
    let s:user_events.columns = &columns
  endif
endfunction

"     }}}
"   }}}
"   Search {{{2
"     Variables & constants {{{3

if exists('s:SEARCH') | unlet s:SEARCH | endif
const s:SEARCH = #{
\   sensitive_replace: ':s/\%V//g<Left><Left><Left>',
\   insensitive_replace: ':s/\%V\c//g<Left><Left><Left>',
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

function! s:BuildTmuxPaneLine(buf, COLORS)
  let l:res = ''
  if a:buf.nr == bufnr('%')
    let l:res = a:COLORS.current_buf
  else
    let l:res = a:COLORS.buf
  endif
  return l:res . ' ' . a:buf.name . ' #[none]'
endfunction

function! s:UpdateTmuxPaneLine()
  if exists('${TMUX}')
    let l:tmux_pane_border = ''

    const l:COLORS = #{
      \ current_buf: '#[fg=colour' . s:PALETTE.theme
        \ . ',bold,bg=colour' . s:PALETTE.gray_900 . ']',
      \ buf: '#[fg=colour' . s:PALETTE.theme
        \ . ',underscore,bg=colour' . s:PALETTE.gray_700 . ']',
    \ }

    const l:max_len = &columns - 4

    let l:bufs = map(
        \ sort(
          \ map(getbufinfo(#{ buflisted: 1 }),
          \ { _, buf -> buf.bufnr }),
        \ 'N'),
      \ { _, nr -> { 'nr': nr, 'name': bufname(nr) }})

    if len(l:bufs) > 1
      while l:bufs[1].nr != bufnr('%')
        let l:bufs = add(l:bufs, remove(l:bufs, 0))
      endwhile
    endif

    if len(join(mapnew(l:bufs, { _, buf -> buf.name }), '  ')) + 2 >= l:max_len

      while len(substitute(l:tmux_pane_border, '#\[.\{-}\]', '', 'g')
        \ . l:bufs[0].name) + 10 + 2 <= l:max_len
          let l:tmux_pane_border .= s:BuildTmuxPaneLine(l:bufs[0], l:COLORS)
          call remove(l:bufs, 0)
      endwhile

      let l:tmux_pane_border = l:COLORS.buf . ' ... #[none]'
        \ . l:tmux_pane_border . l:COLORS.buf . ' ... #[none]'
    else
      while !empty(join(mapnew(l:bufs, { _, buf -> buf.nr }), ''))
        let l:tmux_pane_border .= s:BuildTmuxPaneLine(l:bufs[0], l:COLORS)
        call remove(l:bufs, 0)
      endwhile
    endif

    let l:command = 'tmux set-option -p pane-border-format "'
      \ . l:tmux_pane_border . '"'

    call system(l:command)
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
"   Blank {{{2

function! s:BlankUp()
  if &modifiable
    call append(line('.') - 1, repeat([''], v:count1))
  endif
endfunction

function! s:BlankDown()
  if &modifiable
    call append(line('.'), repeat([''], v:count1))
  endif
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
"   VimRC {{{2

function! s:OpenVimRC()
  vsplit $MYVIMRC
endfunction

if !exists("*s:SourceVimRC")
  function! s:SourceVimRC()
    execute 'source ' . $MYVIMRC
    call s:HighlightStatusLines()
    echomsg 'VimRC sourced !'
  endfunction
endif

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
    \ || (&filetype == "rust")
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
"     Keys {{{3

if exists('s:UNDO_KEY') | unlet s:UNDO_KEY | endif
const s:UNDO_KEY = #{
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
  let l:lines = [ '     ' . s:Key([s:UNDO_KEY.help]) . '   - Show this help',
   \ '    ' . s:Key([s:UNDO_KEY.exit]) . '  - Exit undotree',
   \ '   ' . s:Key([s:UNDO_KEY.next, s:UNDO_KEY.previous])
     \ . ' - Next/Previous change',
   \ '   ' . s:Key([s:UNDO_KEY.select]) . ' - Select change',
   \ '   ' . s:Key([s:UNDO_KEY.first, s:UNDO_KEY.last])
     \ . ' - First/Last change',
   \ '   ' . s:Key([s:UNDO_KEY.scrollup, s:UNDO_KEY.scrolldown])
     \ . ' - Scroll diff window',
  \ ]
  let l:text = []
  for l:each in l:lines
    let l:start = matchend(l:each, '^\s*< .\+ >\s* - \u')
    let l:properties = [#{ type: 'key', col: 1, length: l:start - 1 }]
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
  call popup_create(l:text,
                  \ #{
                  \   pos: 'topleft',
                  \   line: win_screenpos(0)[0] + winheight(0)
                  \     - len(l:text) - &cmdheight,
                  \   col: win_screenpos(0)[1] + s:undo.max_length + 1,
                  \   zindex: 4,
                  \   wrap: v:false,
                  \   fixed: v:true,
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
"     Functions {{{3

function! s:DiffHandler(job, status)
  let l:eventignore_backup = &eventignore
  set eventignore=all

  let l:diffbuf = ch_getbufnr(a:job, 'out')
  let l:text = getbufline(l:diffbuf, 1, '$')

  execute 'silent bdelete! ' . l:diffbuf
  if delete(s:undo.tmp[0]) != 0
    echohl ErrorMsg
    echomsg 'Personal Error Message: Can not delete temp file: '
      \ . s:undo.tmp[0]
    echohl NONE
  endif
  if delete(s:undo.tmp[1]) != 0
    echohl ErrorMsg
    echomsg 'Personal Error Message: Can not delete temp file: '
      \ . s:undo.tmp[1]
    echohl NONE
  endif

  for l:each in range(len(l:text))
    let l:properties = [#{ type: 'diffadd', col: 1,
      \ length: max([0, len(l:text[l:each]) - 1]) }]
    if l:text[l:each][0] == '-'
      let l:properties = [#{ type: 'diffdelete', col: 1,
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
    echohl ErrorMsg
    echomsg 'Personal Error Message: Can not write to temp file: '
      \ . s:undo.tmp[0]
    echohl NONE
  endif
  if writefile(l:new, s:undo.tmp[1]) == -1
    echohl ErrorMsg
    echomsg 'Personal Error Message: Can not write to temp file: '
      \ . s:undo.tmp[1]
    echohl NONE
  endif
  let s:undo.job = job_start(['/bin/bash', '-c', l:diffcommand . ' '
    \ . s:undo.tmp[0] . ' ' . s:undo.tmp[1]], #{ out_io: 'buffer',
    \ out_msg: v:false, exit_cb: expand('<SID>') . 'DiffHandler' })

  let &eventignore = l:eventignore_backup
endfunction

function! s:UndotreeFilter(winid, key)
  if a:key == s:UNDO_KEY.exit
    execute 'highlight PopupSelected ctermfg=' . s:PALETTE.gray_700
      \ . ' ctermbg=' . s:PALETTE.zinc
    call popup_clear()
    unlet s:undo
    call s:UnlockServer('fff')
  elseif a:key == s:UNDO_KEY.next
    call s:UpdateUndotree()
    call win_execute(a:winid, 'while line(".") > 1'
      \ . ' | call cursor(line(".") - 1, 0)'
      \ . ' | if (line(".") < line("w0") + 1) && (line("w0") > 1)'
      \ . ' | execute "normal! \<C-y>" | endif'
      \ . ' | if s:undo.meta[line(".") - 1] > -1 | break | endif'
      \ . ' | endwhile')
    call s:Diff(a:winid)
    call s:UndotreeButtons(a:winid)
  elseif a:key == s:UNDO_KEY.previous
    call s:UpdateUndotree()
    call win_execute(a:winid, 'while line(".") < line("$")'
      \ . ' | call cursor(line(".") + 1, 0)'
      \ . ' | if (line(".") > line("w$") - 1) && (line("$") > line("w$"))'
      \ . ' | execute "normal! \<C-e>" | endif'
      \ . ' | if s:undo.meta[line(".") - 1] > -1 | break | endif'
      \ . ' | endwhile')
    call s:Diff(a:winid)
    call s:UndotreeButtons(a:winid)
  elseif a:key == s:UNDO_KEY.first
    call s:UpdateUndotree()
    call win_execute(a:winid, 'call cursor(1, 0)')
    call s:Diff(a:winid)
    call s:UndotreeButtons(a:winid)
  elseif a:key == s:UNDO_KEY.last
    call s:UpdateUndotree()
    call win_execute(a:winid, 'call cursor(line("$"), 0)')
    call s:Diff(a:winid)
    call s:UndotreeButtons(a:winid)
  elseif a:key == s:UNDO_KEY.scrollup
    call win_execute(s:undo.diff_id,
      \ 'call cursor(line("w0") - 1, 0) | redraw')
  elseif a:key == s:UNDO_KEY.scrolldown
    call win_execute(s:undo.diff_id,
      \ 'call cursor(line("w$") + 1, 0) | redraw')
  elseif a:key == s:UNDO_KEY.select
    call win_execute(a:winid, 'let s:undo.line = line(".")')
    execute 'silent undo ' . s:undo.meta[s:undo.line - 1]
    unlet s:undo.line
    call s:UpdateUndotree()
    call popup_settext(a:winid, s:undo.text)
    call s:Diff(a:winid)
  elseif a:key == s:UNDO_KEY.help
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
        let l:index = l:each
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
            let l:index = l:each
            let l:minnode = l:slots[l:each]
            continue
          endif
        endif
        if type(l:slots[l:each]) == v:t_list
          for l:each2 in l:slots[l:each]
            if l:each2.seq < l:minseq
              let l:minseq = l:each2.seq
              let l:index = l:each
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
          if l:each < l:index
            let l:newline = l:newline . '| '
          endif
          if l:each > l:index
            let l:newline = l:newline . ' \'
          endif
        endfor
      endif
      call remove(l:slots, l:index)
    endif

    if type(l:node) == v:t_dict
      let l:newmeta = l:node.seq
      for l:each in range(len(l:slots))
        if l:index == l:each
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
    echohl ErrorMsg
    echomsg 'Personal Error Message: Unlisted or Unloaded current buffer.'
      \ . ' Can not use Undotree.'
    echohl NONE
    return
  endif

  call s:LockServer('fff')
  let s:undo = {}
  call s:UpdateUndotree()
  let s:undo.change_backup = changenr()
  execute 'highlight PopupSelected ctermfg=' . s:PALETTE.gray_700
    \ . ' ctermbg=' . s:PALETTE.zinc

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
    \ wrap: v:false,
    \ fixed: v:true,
    \ mapping: v:false,
    \ scrollbar: v:true,
    \ border: [0, 0, 0, 1],
    \ borderchars: ['│'],
    \ borderhighlight: ['VertSplit'],
  \ })
  call setwinvar(s:undo.diff_id, '&wincolor', 'UndoPopup')

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
    \ wrap: v:false,
    \ fixed: v:true,
    \ filter: expand('<SID>') . 'UndotreeFilter',
    \ mapping: v:false,
    \ scrollbar: v:false,
    \ cursorline: v:true,
  \ })
  call setwinvar(l:popup_id, '&wincolor', 'UndoPopup')
  call win_execute(l:popup_id, 'let w:line = 1 | call cursor(w:line, 0)'
  \ . ' | while s:undo.meta[line(".") - 1] != s:undo.change_backup'
  \ . ' | let w:line += 1 | call cursor(w:line, 0) | endwhile')
  call s:UndotreeButtons(l:popup_id)
  call s:HelpUndotree()
endfunction

"     }}}
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

      let l:contained_in = ''
      let l:parentheses = ['start=/(/ end=/)/ fold',
        \ 'start=/\[/ end=/\]/ fold', 'start=/{/ end=/}/ fold']
      let l:string_syntax = '"^[^[:space:]]*String[^[:space:]]*"'

      if &filetype == 'vim'
        let l:parentheses = ['start=/(/ end=/)/', 'start=/\[/ end=/\]/',
          \ 'start=/{/ end=/}/ fold']
      elseif (&filetype == 'sh') || (&filetype == 'conf')
        let l:string_syntax = '"shDoubleQuote"'
        let l:contained_in = ",shDoubleQuote"
      elseif &filetype == 'yaml'
        let l:contained_in = ",yamlFlowString"
      endif

      " syntax list must not be cleared if the it is already empty
      if !empty(l:buf_syntax)
        execute 'syntax clear ' . join(filter(filter(filter(map(filter(
          \ l:buf_syntax, 'match(v:val, "cluster") < 0'),
          \ 'matchstr(v:val, "^[[:alnum:]_]*")'), '!empty(v:val)'),
          \ 'match(v:val, "_Rainbow") < 0'),
          \ 'match(v:val, ' . l:string_syntax . ') < 0'))
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
            \ . ((l:each == 0) ? l:contained_in : '') . ' contains=TOP fold'
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

      for l:each in map(filter(getbufinfo(), 'v:val.listed || !v:val.hidden'),
        \ 'v:val.bufnr')
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
"   Tig {{{2
"     Variables & constants {{{3

let s:tig = #{
\   git_root: '',
\   popup_id: -1,
\   term_buf: -1,
\   diff_file_buf: -1,
\   diff_linecount: 0,
\ }

"     }}}
"     Functions {{{3

function! s:IsTigUsable()
  if empty(getcmdwintype())
    if executable('git') && executable('tig') && has('terminal')
      let s:tig.git_root = trim(system('cd ' . expand('%:p:h')
        \ . ' && git rev-parse --show-toplevel 2> /dev/null'))
      if !empty(s:tig.git_root)
        return v:true
      else
        echohl ErrorMsg
        echomsg 'Personal Error Message: Tig plugin needs to be in a git'
          \ . ' project.'
        echohl NONE
      endif
    else
      echohl ErrorMsg
      echomsg 'Personal Error Message: Tig plugin needs git executable, tig'
        \ . ' executable and terminal Vim feature'
      echohl NONE
    endif
  endif
  return v:false
endfunction

function! s:Tig(command, env, conf_tigrc, term_options)
  call s:LockServer('fff')
  if empty(v:servername)
    let l:id = 1
    if !empty(serverlist())
      let l:id = max(map(split(serverlist(), s:SERVER_PREFIX),
        \ "trim(v:val)")) + 1
    endif
    call s:StartServer('tig', l:id)
  else
    call s:UnlockServer('tig')
  endif

  let l:tmp_tigrc = tempname()
  if !filereadable($TIGRC_USER)
    echohl ErrorMsg
    echomsg 'Personal Error Message: ' . $TIGRC_USER . ' not readable.'
    echohl NONE
    return
  endif
  let l:tmp_tigrc_content = readfile($TIGRC_USER)
  if empty(l:tmp_tigrc_content)
    echohl ErrorMsg
    echomsg 'Personal Error Message: Can not read ' . $TIGRC_USER
    echohl NONE
    return
  endif

  let l:conf_tigrc = extend([ "bind generic e @vim --remote-expr"
    \ . " 'TigEdit(" . '"%(file)", %(lineno), %(lineno_old), "%(text)")'
    \ . "' --servername " . v:servername, "bind generic E @vim --remote-expr"
    \ . " 'TigBadd(" . '"%(file)", %(lineno), %(lineno_old), "%(text)")'
    \ . "' --servername " . v:servername, "bind blob e @vim --remote-expr"
    \ . " 'TigEdit(" . '"%(file)", %(lineno), 0, "+")'
    \ . "' --servername " . v:servername, "bind blob E @vim --remote-expr"
    \ . " 'TigBadd(" . '"%(file)", %(lineno), 0, "+")'
    \ . "' --servername " . v:servername ], a:conf_tigrc)
  call extend(l:tmp_tigrc_content, l:conf_tigrc)

  if writefile(l:tmp_tigrc_content, l:tmp_tigrc) == -1
    echohl ErrorMsg
    echomsg 'Personal Error Message: Can not write to temp tigrc file: '
      \ . l:tmp_tigrc
    echohl NONE
    return
  endif

  let s:tig.term_buf = term_start(a:command, extend(#{
    \ term_name: 'tig',
    \ term_finish: 'close',
    \ hidden: v:true,
    \ cwd: s:tig.git_root,
    \ env: extend(#{ TIGRC_USER: l:tmp_tigrc }, a:env),
  \ }, a:term_options))

  let s:tig.popup_id = popup_create(s:tig.term_buf, #{
    \ pos: 'topleft',
    \ line: win_screenpos(0)[0],
    \ col: win_screenpos(0)[1],
    \ zindex: 2,
    \ minwidth: winwidth(0),
    \ maxwidth: winwidth(0),
    \ minheight: winheight(0),
    \ maxheight: winheight(0),
    \ wrap: v:false,
    \ fixed: v:true,
    \ mapping: v:false,
    \ scrollbar: v:false,
  \ })

  setlocal nobuflisted

  call s:LockServer('tig')
  call s:UnlockServer('fff')
endfunction

function! s:TigLog()
  if s:IsTigUsable()
    call s:Tig('tig', #{}, [], #{})
  endif
endfunction

function! s:TigLogCurrentFile()
  if s:IsTigUsable()
    call s:Tig('tig ' . expand('%:p'), #{}, [], #{})
  endif
endfunction

function! s:TigStatus()
  if s:IsTigUsable()
    call s:Tig('tig status', #{}, [], #{})
  endif
endfunction

function! s:TigDiff()
  if s:IsTigUsable()
    if !empty(system('cd ' . s:tig.git_root . ' && git diff --name-only'))
      let l:startup_tig = tempname()
      let l:startup_script = ['<Enter>', ':maximize']

      if !empty(system('cd ' . s:tig.git_root
        \ . ' && git ls-files --others --exclude-standard'))
          let l:startup_script = [':move-down'] + l:startup_script
      endif

      if writefile(l:startup_script, l:startup_tig) == -1
        echohl ErrorMsg
        echomsg 'Personal Error Message: Can not write to startup tig temp'
          \ . ' file: ' . l:startup_tig
        echohl NONE
        return
      endif
      call s:Tig('tig', #{ TIG_SCRIPT: l:startup_tig },
        \ ['bind generic q quit'], #{})
    else
      echohl ErrorMsg
      echomsg 'Personal Error Message: No change detected'
      echohl NONE
      return
    endif
  endif
endfunction

function! s:TigDiffCurrentFileHandler(diff_job, status)
  let s:tig.diff_file_buf = ch_getbufnr(job_getchannel(a:diff_job), 'out')
  while filter(getbufinfo(), 'v:val.bufnr=='
    \ . s:tig.diff_file_buf)[0].linecount < s:tig.diff_linecount
      sleep 1m
  endwhile
  call s:Tig('tig', #{},
    \ ["bind pager q @vim --remote-expr 'TigDiffCurrentFileClose()'"
      \ . " --servername " . v:servername, "bind pager Q @vim --remote-expr"
      \ . " 'TigDiffCurrentFileClose()' --servername " . v:servername],
    \ #{ in_io: 'buffer', in_buf: s:tig.diff_file_buf })
endfunction

function! s:TigDiffCurrentFile()
  if s:IsTigUsable()
    let l:file = expand('%:p')
    let s:tig.diff_linecount =
      \ len(systemlist('cd ' . s:tig.git_root . ' && git diff ' . l:file))
    if s:tig.diff_linecount > 0
      call job_start(['/bin/bash', '-c', 'cd ' . s:tig.git_root
        \ . ' && git diff ' . l:file], #{ out_io: "buffer",
        \ out_msg: v:false,
        \ exit_cb: expand('<SID>') . 'TigDiffCurrentFileHandler' })
    else
      echohl ErrorMsg
      echomsg 'Personal Error Message: No change detected for ' . l:file
      echohl NONE
      return
    endif
  endif
endfunction

function! s:TigBlame()
  if s:IsTigUsable()
    let l:startup_tig = tempname()
    let l:startup_script = [':' . line('w0')]

    for l:each in range(1, line('w$') - line('w0') - 2)
      call add(l:startup_script, ':move-down')
    endfor

    if line('.') < line('w$') - 1
      for l:each in range(1, line('w$') - 2 - line('.'))
        call add(l:startup_script, ':move-up')
      endfor
    else
      for l:each in range(1, abs(line('w$') - 2 - line('.')))
        call add(l:startup_script, ':move-down')
      endfor
    endif

    if writefile(l:startup_script, l:startup_tig) == -1
      echohl ErrorMsg
      echomsg 'Personal Error Message: Can not write to startup tig temp file: '
        \ . l:startup_tig
      echohl NONE
      return
    endif
    call s:Tig('tig blame ' . expand('%:p'), #{ TIG_SCRIPT: l:startup_tig },
      \ ["bind blame q @vim --remote-expr 'TigBlameSyncCursors(%(lineno))'"
        \ . " --servername " . v:servername, "bind blame Q @vim --remote-expr"
        \ . " 'TigBlameSyncCursors(%(lineno))' --servername " . v:servername],
        \ #{})
  endif
endfunction

function! s:TigGrep(pattern)
  if s:IsTigUsable()
    call s:Tig('tig grep ' . a:pattern, #{}, [], #{})
  endif
endfunction

function! s:TigFinder()
  if s:IsTigUsable()
    let l:startup_tig = tempname()
    let l:startup_script = [':view-blob']

    if writefile(l:startup_script, l:startup_tig) == -1
      echohl ErrorMsg
      echomsg 'Personal Error Message: Can not write to startup tig temp file: '
        \ . l:startup_tig
      echohl NONE
      return
    endif
    call s:Tig('tig', #{ TIG_SCRIPT: l:startup_tig }, [], #{})
  endif
endfunction

function! s:TigBaddSyncCursors()
  if exists('b:tig_line')
    call cursor(b:tig_line, 0)
    normal! zz
    unlet b:tig_line
  endif
endfunction

function! TigDiffCurrentFileClose()
  call popup_close(s:tig.popup_id)
  execute 'silent bdelete! ' . s:tig.diff_file_buf
endfunction

function! TigBlameSyncCursors(lineno)
  let l:first_line = matchstr(matchstr(
    \ term_getline(s:tig.term_buf, '1'), '[0-9]\+│'), '[0-9]\+')
  call popup_close(s:tig.popup_id)
  call cursor(l:first_line, 0)
  normal! zt
  call cursor(a:lineno, 0)
endfunction

function! TigEdit(file, lineno, lineno_old, text)
  let l:filename = s:tig.git_root . '/' . a:file
  if filereadable(l:filename)

    call popup_close(s:tig.popup_id)

    let l:command = 'view'
    if filewritable(l:filename)
      let l:command = 'edit'
    endif

    execute l:command . ' ' . l:filename

    if ((a:text[0] == '+') && (a:lineno > 0))
      \ || ((a:text[0] == '-') && (a:lineno_old > 0))
        call cursor((a:text[0] == '+') ? a:lineno : a:lineno_old, 0)
    endif
  else
    echohl ErrorMsg
    echomsg 'Personal Error Message: ' . l:filename . ' is not a file or is'
      \ . ' not readable.'
    echohl NONE
  endif
endfunction

function! TigBadd(file, lineno, lineno_old, text)
  let l:filename = s:tig.git_root . '/' . a:file
  if !empty(glob(l:file_name)) && !isdirectory(l:file_name)

    execute 'badd ' . l:filename

    echohl OpenedDirPath
    echo l:filename
    echohl NONE
    echon ' added to buffers list'

    if ((a:text[0] == '+') && (a:lineno > 0))
      \ || ((a:text[0] == '-') && (a:lineno_old > 0))
        let l:buf = bufnr(l:filename)
        call setbufvar(l:buf, 'tig_line',
          \ (a:text[0] == '+') ? a:lineno : a:lineno_old)
    endif
  else
    echohl ErrorMsg
    echomsg 'Personal Error Message: ' . l:filename . ' is not a file.'
    echohl NONE
  endif
endfunction

"     }}}
"     Commands {{{3

command! -nargs=1 TigGrep call <SID>TigGrep(<args>)

"     }}}
"   }}}
"   fff {{{2

function! FFFedit(file)
  if s:IsServerReachable('fff')
    execute 'edit ' . a:file
    redraw!
  endif
endfunction

function! s:ToggleFFFpane()
  if exists('${TMUX}')
    if s:IsServerReachable('fff')
    else
      let l:id = 1
      if !empty(serverlist())
        let l:id = max(map(split(serverlist(), s:SERVER_PREFIX),
          \ "trim(v:val)")) + 1
      endif
      call s:StartServer('fff', l:id)
      call system('tmux split-window -h -b -l 30 fff')
    endif
  endif
endfunction

"   }}}
" }}}
" Filetype specific {{{1
"   Bash {{{2

function! s:PrefillShFile()
  call append(0, [
  \                '#!/usr/bin/env bash',
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
"   Variables & constants {{{2

if exists('s:leaders') | unlet s:leaders | endif
"\   global:    '²',
"\   shift:     '³',
const s:LEADERS = #{
\   global:    '`',
\   shift:     '~',
\   tig:       '&',
\   tig_shift: '1',
\ }

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
\   'VIMRC': [
\     #{
\       description: 'Open .vimrc in vertical split',
\       keys: s:LEADERS.global . '&',
\       mode: 'n',
\       command: '<Cmd>call <SID>OpenVimRC()<CR>',
\     },
\     #{
\       description: 'Source .vimrc',
\       keys: s:LEADERS.shift . '1',
\       mode: 'n',
\       command: '<Cmd>call <SID>SourceVimRC()<CR>',
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
\       description: 'Open Undotree',
\       keys: s:LEADERS.shift . 'U',
\       mode: 'n',
\       command: '<Cmd>call <SID>Undotree()<CR>',
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
\   'TIG': [
\     #{
\       description: 'Tig main view',
\       keys: s:LEADERS.tig . 'l',
\       mode: 'n',
\       command: '<Cmd>call <SID>TigLog()<CR>',
\     },
\     #{
\       description: 'Tig blame view',
\       keys: s:LEADERS.tig . 'b',
\       mode: 'n',
\       command: '<Cmd>call <SID>TigBlame()<CR>',
\     },
\     #{
\       description: 'Tig blob view',
\       keys: s:LEADERS.tig . 'f',
\       mode: 'n',
\       command: '<Cmd>call <SID>TigFinder()<CR>',
\     },
\     #{
\       description: 'Tig status view',
\       keys: s:LEADERS.tig . 's',
\       mode: 'n',
\       command: '<Cmd>call <SID>TigStatus()<CR>',
\     },
\     #{
\       description: 'Tig main view for current file',
\       keys: s:LEADERS.tig_shift . 'L',
\       mode: 'n',
\       command: '<Cmd>call <SID>TigLogCurrentFile()<CR>',
\     },
\     #{
\       description: 'Tig grep view',
\       keys: s:LEADERS.tig . 'g',
\       mode: 'n',
\       command: ':TigGrep ""<Left>',
\     },
\     #{
\       description: 'Tig stage view',
\       keys: s:LEADERS.tig . 'd',
\       mode: 'n',
\       command: '<Cmd>call <SID>TigDiff()<CR>',
\     },
\     #{
\       description: 'Tig stage view for current file',
\       keys: s:LEADERS.tig_shift . 'D',
\       mode: 'n',
\       command: '<Cmd>call <SID>TigDiffCurrentFile()<CR>',
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
\       description: 'Blank line under current line',
\       keys: '<CR>',
\       mode: 'n',
\       command: '<Cmd>call <SID>BlankDown()<CR>',
\     },
\     #{
\       description: 'Blank line above current line',
\       keys: s:LEADERS.global . '<CR>',
\       mode: 'n',
\       command: '<Cmd>call <SID>BlankUp()<CR>',
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

" save buffer as sudo user
cnoreabbrev <expr> w!! (getcmdtype() == ':' ?
  \ "silent write ! sudo tee % > /dev/null \| echo ''" : "w!!")

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
"   User autocommands {{{2

  autocmd VimEnter * :silent call timer_start(200, function('s:TriggerUserEvents'), {'repeat': -1})

"   }}}
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
"   Tmux autocommands {{{2

  autocmd VimResized :doautocmd User Resized
  autocmd User BuffersListChanged :silent call <SID>UpdateTmuxPaneLine()
  autocmd User Resized :silent call <SID>UpdateTmuxPaneLine()
  autocmd VimResume * :silent call <SID>UpdateTmuxPaneLine()
  autocmd VimSuspend,VimLeavePre * :silent call systemlist('tmux set-option -p pane-border-format " [#P] "')

"   }}}
"   Plugins autocommands {{{2
"     Obsession autocommands {{{3

  autocmd VimEnter * nested :call <SID>SourceObsession()

"     }}}
"     Rainbow autocommands {{{3

  autocmd BufEnter,CmdwinEnter * :silent call <SID>RefreshRainbow()

"     }}}
"     Tig autocommands {{{3

  autocmd BufEnter * :silent call <SID>TigBaddSyncCursors()

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
"   Comments autocommands {{{2

  autocmd BufEnter * :call <SID>SetCommentString()

"   }}}
"   Folds autocommands {{{2

  autocmd FileType vim,tmux,sh setlocal foldmethod=marker

"   }}}
augroup END

" }}}
