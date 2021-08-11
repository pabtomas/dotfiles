" TODO -----------------------------------{{{

" - disable opening directories
" - test unlisted-buffers autocmd
" - rewrite <leader>a mapping:
"   1) to display only hidden listed-buffers
"   2) to open only hidden listed-buffer

" }}}
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

" always display the number of changes after a command
set report=0

function! CheckDependencies()
  if v:version < 801
    echoe 'Your VimRC needs Vim 8.1 to be functionnal'
    quit
  endif

  if exists('g:NERDTree') == v:false ||
  \ exists('g:NERDTreeMapOpenInTab') == v:false ||
  \ exists('g:NERDTreeMapOpenInTabSilent') == v:false ||
  \ exists('g:NERDTreeNaturalSort') == v:false ||
  \ exists('g:NERDTreeMouseMode') == v:false ||
  \ exists('g:NERDTreeHighlightCursorline') == v:false ||
  \ exists(':NERDTreeToggle') == v:false
    echoe 'Your VimRC needs NERDTree plugin to be functionnal'
    quit
  endif
endfunction

" }}}
" Colors --------------------------{{{
"   Palette --------------------------{{{

let s:red = 196
let s:orange = 202
let s:purple_1 = 62
let s:purple_2 = 140
let s:purple_3 = 176
let s:blue_1 = 69
let s:blue_2 = 105
let s:blue_3 = 111
let s:green = 42
let s:white_1 = 147
let s:white_2 = 153
let s:grey_1 = 235
let s:grey_2 = 236
let s:black = 232

"   }}}
"   Scheme --------------------{{{

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
    \      highlight       OpenedBuffer   term=bold           cterm=bold         ctermfg=' . s:green    . ' ctermbg=' . s:black    . ' |
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
  highlight       OpenedBuffer   term=bold           cterm=bold           ctermfg=Red
endif

execute s:redhighlight_cmd

"   }}}
"   Good practices -------------------------{{{

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
" Listed-Buffers -----------------------------{{{

" return number of opened listed-buffers
function! OpenedListedBuffers()
  return len(filter(range(1, winnr('$')), 'buflisted(winbufnr(v:val))'))
endfunction

" resize the command window, display listed buffers and hilight current
" buffer
function DisplayBuffersList(prompt_hitting)
  let l:buf_nb = len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) + 1

  if a:prompt_hitting == v:true
    let l:buf_nb = len(filter(range(1, bufnr('$')),
    \ 'buflisted(v:val) && (len(win_findbuf(v:val)) == 0)')) + 1
  endif

  execute 'set cmdheight=' . l:buf_nb
  for l:buf in filter(range(1, bufnr('$')), 'buflisted(v:val)')
    let l:result = " " . l:buf . ": \"" . bufname(l:buf) . "\""
    let l:result = l:result .
      \ repeat(" ", &columns - 1 - strlen(l:result)) . "\n"
    if l:buf == bufnr('%')
      echohl CurrentBuffer | echon l:result | echohl None
    elseif len(win_findbuf(l:buf)) > 0
      if a:prompt_hitting == v:false
        echohl OpenedBuffer | echon l:result | echohl None
      endif
    else
      echon l:result
    endif
  endfor
endfunction

" go to the next/previous undisplayed listed buffer
function! BuffersListNavigation(direction)
  let l:cycle = []
  if a:direction == 1
    let l:cycle = range(bufnr('%'), bufnr('$')) + range(1, bufnr('%'))
  elseif a:direction == -1
    let l:cycle = range(bufnr('%'), 1, -1) + range(bufnr('$'), bufnr('%'), -1)
  endif

  for l:buf in filter(l:cycle, 'buflisted(v:val)')
    if len(win_findbuf(l:buf)) == 0
      execute 'silent buffer ' . l:buf
      break
    endif
  endfor
endfunction

" }}}
" Unlisted-Buffers ---------------------------{{{

" close Vim if only unlisted-buffers are opened
function! CloseLonelyUnlistedBuffers()
  if OpenedListedBuffers() == 0
    quitall
  endif
endfunction

" disable risky keys for unlisted-buffers
function! DisableMappingsUnlistedBuffer()
  if buflisted(bufnr('%')) == v:false

    let l:dict = maparg(':', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer') == v:true
      if l:dict.buffer == v:false
        nnoremap <buffer> : <Esc>
      endif
    else
      nnoremap <buffer> : <Esc>
    endif

    let l:dict = maparg('q', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer') == v:true
      if l:dict.buffer == v:false
        nnoremap <buffer> q :quit<CR>
      endif
    else
      nnoremap <buffer> q :quit<CR>
    endif

    let l:dict = maparg('<Tab>', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer') == v:true
      if l:dict.buffer == v:false
        nnoremap <buffer> <Tab> <Esc>
      endif
    else
      nnoremap <buffer> <Tab> <Esc>
    endif

    let l:dict = maparg('<S-Tab>', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer') == v:true
      if l:dict.buffer == v:false
        nnoremap <buffer> <S-Tab> <Esc>
      endif
    else
      nnoremap <buffer> <S-Tab> <Esc>
    endif

    let l:dict = maparg('<leader>a', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer') == v:true
      if l:dict.buffer == v:false
        nnoremap <buffer> <leader>a <Esc>
      endif
    else
      nnoremap <buffer> <leader>a <Esc>
    endif

    let l:dict = maparg("<leader>'", 'n', v:false, v:true)
    if has_key(l:dict, 'buffer') == v:true
      if l:dict.buffer == v:false
        nnoremap <buffer> <leader>' <Esc>
      endif
    else
      nnoremap <buffer> <leader>' <Esc>
    endif

    let l:dict = maparg(':', 'v', v:false, v:true)
    if has_key(l:dict, 'buffer') == v:true
      if l:dict.buffer == v:false
        vnoremap <buffer> : <Esc>
      endif
    else
      vnoremap <buffer> : <Esc>
    endif

    let l:dict = maparg('<leader>:', 'v', v:false, v:true)
    if has_key(l:dict, 'buffer') == v:true
      if l:dict.buffer == v:false
        vnoremap <buffer> <leader>: <Esc>
      endif
    else
      vnoremap <buffer> <leader>: <Esc>
    endif

    let l:dict = maparg('<leader>&', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer') == v:true
      if l:dict.buffer == v:false
        nnoremap <buffer> <leader>& <Esc>
      endif
    else
      nnoremap <buffer> <leader>& <Esc>
    endif

    let l:dict = maparg('ZQ', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer') == v:true
      if l:dict.buffer == v:false
        nnoremap <buffer> ZQ <Esc>
      endif
    else
      nnoremap <buffer> ZQ <Esc>
    endif

    let l:dict = maparg('ZZ', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer') == v:true
      if l:dict.buffer == v:false
        nnoremap <buffer> ZZ <Esc>
      endif
    else
      nnoremap <buffer> ZZ <Esc>
    endif

    let l:dict = maparg('<leader>q', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer') == v:true
      if l:dict.buffer == v:false
        vnoremap <buffer> <leader>q <Esc>
      endif
    else
      vnoremap <buffer> <leader>q <Esc>
    endif

    let l:dict = maparg('<leader>w', 'n', v:false, v:true)
    if has_key(l:dict, 'buffer') == v:true
      if l:dict.buffer == v:false
        vnoremap <buffer> <leader>w <Esc>
      endif
    else
      vnoremap <buffer> <leader>w <Esc>
    endif

  endif
endfunction

" }}}
" Quit Buffers -----------------------------{{{

" allow to switch between buffers without writting them
set hidden

" - quit current window & delete buffer inside, IF there are 2 opened
"   listed-buffers or more,
" - come back to the previous listed-buffer and delete current buffer IF
"   there are 1 opened listed-buffer (OR 1 or more opened unlisted-buffer + 1
"   opened listed-buffer),
" - quit Vim IF there are 1 opened listed-buffer (OR 1 or more opened
"   unlisted-buffer + 1 opened listed-buffer) AND no other listed-buffer.
function! Quit()
  if &modified == 0
    if len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) > 1
      let l:first_buf = bufnr('%')
      if winnr('$') == 1 || (winnr('$') > 1 && (OpenedListedBuffers() == 1))
        execute "normal! \<C-O>"
      else
        silent quit
      endif
      execute 'silent bdelete' . l:first_buf
    else
      silent quit
    endif
    return v:true
  else
    echo bufname('%') . ' has unsaved modifications'
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

" }}}
" Timers --------------------------------{{{

" timer variables
let s:tick = 100
let s:nb_ticks = 100
let s:elapsed_time = s:nb_ticks * s:tick

let s:lasttick_sizebuflist =
  \ len(filter(range(1, bufnr('$')), 'buflisted(v:val)'))
let s:lasttick_buffer = bufnr('%')

" update the buffers list displayed in commandline
function! s:UpdateCommandline(timer_id)
  if s:elapsed_time < s:nb_ticks * s:tick
    let s:elapsed_time = s:elapsed_time + s:tick
    redraw
    set cmdheight=1
    call DisplayBuffersList(v:false)
  else
    call StopTimer()
  endif
endfunction

" run when displaying buffers list is needed
let s:update_timer =
  \ timer_start(s:tick, function('s:UpdateCommandline'), {'repeat': -1})

function! StartTimer()
  call timer_pause(s:update_timer, v:false)
  let s:elapsed_time = 0
endfunction

let s:redraw_allowed = v:true

function! DisableRedraw()
  let s:redraw_allowed = v:false
endfunction

function! StopTimer()
  call timer_pause(s:update_timer, v:true)
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
  let l:current_sizebufist =
    \ len(filter(range(1, bufnr('$')), 'buflisted(v:val)'))
  let l:current_buffer = bufnr('%')
  if (s:lasttick_sizebuflist != l:current_sizebufist) ||
  \ ((s:lasttick_buffer != l:current_buffer) && buflisted(l:current_buffer))
    let s:lasttick_sizebuflist = l:current_sizebufist
    let s:lasttick_buffer = l:current_buffer
    call StartTimer()
  endif

  " avoid commandline and risky commands for unlisted-buffers
  if buflisted(l:current_buffer) == v:false
    call DisableMappingsUnlistedBuffer()
  endif

endfunction

" always running except during commandline mode
let s:monitor_timer =
  \ timer_start(s:tick, function('s:MonitorBuffersList'), {'repeat': -1})

" }}}
" NERDTree ---------------------------------------{{{

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
" FileType-specific -------------------------------------{{{
"   Bash -------------------------------------{{{

function! PrefillShFile()
  call append(0, [ '#!/bin/bash',
  \                '', ])
endfunction

"   }}}
" }}}
" Mappings -------------------------------------{{{

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

" for debug purposes
nnoremap <leader>M :messages<CR>
nnoremap <leader>m :map<CR>

" open .vimrc in a vertical split window
nnoremap <silent> <leader>& :vsplit $MYVIMRC<CR>

" compile .vimrc
nnoremap <leader>é :source $MYVIMRC<CR>

" stop highlighting from the last search
nnoremap <silent> <leader>" :nohlsearch<CR>

" open NERDTree in a vertical split window
nnoremap <silent> <leader>' :NERDTreeToggle<CR>

" Quit() functions
nnoremap <silent> ZQ :call Quit()<CR>
nnoremap <silent> ZZ :call WriteQuit()<CR>
nnoremap <silent> <leader>q :call Quit()<CR>
nnoremap <silent> <leader>w :call WriteQuit()<CR>

" buffers menu
nnoremap <leader>a :call DisableRedraw() <bar>
  \ call DisplayBuffersList(v:true)<CR>:buffer<Space>

" buffers navigation
nnoremap <silent> <Tab> :call BuffersListNavigation(1)<CR>
nnoremap <silent> <S-Tab> :call BuffersListNavigation(-1)<CR>

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

" windows navigation
nnoremap <silent> <leader><Right> :call NextWindow()<CR>
nnoremap <silent> <leader><Left> :call PreviousWindow()<CR>

" make space more useful
nnoremap <space> za

" }}}
" Abbreviations --------------------------------------{{{

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

" avoid intuitive bnext/bprevious usage
cnoreabbrev bn call BuffersListNavigation(1)
cnoreabbrev bp call BuffersListNavigation(-1)

" avoid intuitive buffer usage
cnoreabbrev b Buffer

" }}}
" Performance -----------------------------{{{

" draw only when needed
set lazyredraw

" indicates terminal connection, Vim will be faster
set ttyfast

" max column where syntax is applied (default: 3000)
set synmaxcol=79

" avoid visual mod lags
set noshowcmd

"   Autocommands -------------------------------------------{{{

augroup vimrc_autocomands
  autocmd!
"     VimEnter Autocommands Group -----------------------------------------{{{

  " clear jump list
  autocmd VimEnter * silent clearjump

  " check vim dependencies before opening
  autocmd VimEnter * :call CheckDependencies()

"     }}}
"     Color Autocommands Group -------------------------------------------{{{

  autocmd WinEnter * set wincolor=NormalAlt

"     }}}
"     Good Practices Autocommands Group -----------------------------------{{{

  autocmd BufEnter * :silent call ExtraSpaces() | silent call OverLength()

"     }}}
"     Listed-Buffers Autocommands Group ----------------------------------{{{

  " 1) entering commandline erases displayed buffers list,
  " 2) renable incremental search
  autocmd CmdlineEnter * call StopTimer() |
    \ call timer_pause(s:monitor_timer, v:true)
  autocmd CmdlineLeave * call timer_pause(s:monitor_timer, v:false)

"     }}}
"     Unlisted-Buffers Autocommands Group ---------------------------------{{{

  autocmd BufEnter * :silent call CloseLonelyUnlistedBuffers()

"     }}}
"     Vimscript filetype Autocommands Group -------------------------------{{{

  autocmd FileType vim setlocal foldmethod=marker

"     }}}
"     Bash filetype Autocommands Group --------------------------------{{{

  autocmd BufNewFile *.sh :call PrefillShFile()

"     }}}
augroup END

"   }}}
" }}}
