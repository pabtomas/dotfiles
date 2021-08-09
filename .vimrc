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
    quit
  endif
endfunction

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

"   }}}
" }}}
" Buffers -----------------------------{{{

" allow to switch between buffers without writting them
set hidden

" return number of listed-buffers displayed in a window
function! WindowedListedBuffers()
  return len(filter(range(1, winnr('$')), 'buflisted(winbufnr(v:val))'))
endfunction

" - quit current window & delete buffer inside, IF there are 2 listed-buffers
"   windows or more,
" - come back to the previous listed-buffer and delete current buffer IF
"   there are 1 listed-buffer window (OR 1 or more unlisted-buffer windows + 1
"   listed-buffer window),
" - quit Vim IF there are 1 listed-buffer window (OR 1 or more unlisted-buffer
"   windows + 1 listed-buffer window) AND no other listed-buffer.
function! Quit()
  if &modified == 0
    if len(filter(range(1, bufnr('$')), 'buflisted(v:val)')) > 1
      let l:first_buf = bufnr("%")
      if winnr('$') == 1 || (winnr('$') > 1 && (WindowedListedBuffers() == 1))
        execute "normal! \<C-O>"
      else
        silent quit
      endif
      execute "silent bdelete" . l:first_buf
    else
      silent quit
    endif
    return v:true
  else
    echo bufname(bufnr('%')) . " has unsaved modifications"
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

" resize the command window, display listed buffers and hilight current
" buffer
function DisplayBuffersList(prompt_hitting)
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
function! BuffersListNavigation(direction)
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
let s:check_cb = 100
let s:update_cb = 100
let s:nb_period = 100
let s:clock = s:nb_period * s:update_cb

function! ResetTimer()
  let s:clock = 0
endfunction

function! s:EraseBuffersList(timer_id)
  if s:clock >= s:nb_period * s:update_cb
    set cmdheight=1
  endif
endfunction

let s:size_buffers = 1
let s:bufferslist_changed = v:false

function! s:MonitorBuffersList(timer_id)
  if s:bufferslist_changed == v:true
    let l:tmp = len(filter(range(1, bufnr('$')), 'buflisted(v:val)'))
    if s:size_buffers != l:tmp
      let s:size_buffers = l:tmp
      call ResetTimer()
    endif
    let s:bufferslist_changed = v:false
  endif
endfunction

function! s:UpdateBuffersList(timer_id)
  if s:clock < s:nb_period * s:update_cb
    let s:clock = s:clock + s:update_cb
    redraw
    set cmdheight=1
    call DisplayBuffersList(v:false)
  endif
endfunction

" detect buffers list modifications
let s:monitor_timer =
  \ timer_start(s:check_cb, function('s:MonitorBuffersList'), {'repeat': -1})

" update the displayed buffers list in the command window
let s:update_timer =
  \ timer_start(s:update_cb, function('s:UpdateBuffersList'), {'repeat': -1})

" erase the displayed buffers list by resizing the command window
let s:erase_timer =
  \ timer_start(s:update_cb, function('s:EraseBuffersList'), {'repeat': -1})

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
" FileType-specific -----------------------------------{{{
" }}}
" Mappings -------------------------------------{{{

" leader key
let mapleader = "²"

" search and replace
vnoremap : :s/\%V//g<Left><Left><Left>

" search and replace (case-insensitive)
vnoremap <leader>: :s/\%V\c//g<Left><Left><Left>

" search (case-insensitive)
nnoremap <leader>/ /\c

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

" buffers menu
nnoremap <leader>a :call DisplayBuffersList(v:true)<CR>:buffer<Space>

" buffers navigation
nnoremap <silent> <Tab> :call ResetTimer() <bar>
  \ :call BuffersListNavigation(1)<CR>
nnoremap <silent> <S-Tab> :call ResetTimer() <bar>
  \ :call BuffersListNavigation(-1)<CR>

function! NextWindow()
  if winnr() < winnr('$')
    execute winnr() + 1 . "wincmd w"
  else
    1wincmd w
  endif
endfunction

function! PreviousWindow()
  if winnr() > 1
    execute winnr() - 1 . "wincmd w"
  else
    execute winnr('$') . "wincmd w"
  endif
endfunction

" windows navigation
nnoremap <silent> <leader><Up> :call NextWindow()<CR>
nnoremap <silent> <leader><Down> :call PreviousWindow()<CR>

" make space more useful
nnoremap <space> za

" }}}
" Abbreviations --------------------------------------{{{

" disable write usage
cnoreabbrev wincmd wincmd w
cnoreabbrev w update
cnoreabbrev wr update
cnoreabbrev wri update
cnoreabbrev writ update
cnoreabbrev write update
cnoreabbrev wa update all
cnoreabbrev wal update all
cnoreabbrev wall update all

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

" allow intuitive usage of Quit and WriteQuit functions
cnoreabbrev q call Quit()
cnoreabbrev qu call Quit()
cnoreabbrev qui call Quit()
cnoreabbrev quit call Quit()
cnoreabbrev wq call WriteQuit()

cnoreabbrev bd call Quit()
cnoreabbrev bde call Quit()
cnoreabbrev bdel call Quit()
cnoreabbrev bdele call Quit()
cnoreabbrev bdelet call Quit()
cnoreabbrev bdelete call Quit()

cnoreabbrev bw call Quit()
cnoreabbrev bwi call Quit()
cnoreabbrev bwip call Quit()
cnoreabbrev bwipe call Quit()
cnoreabbrev bwipeo call Quit()
cnoreabbrev bwipeou call Quit()
cnoreabbrev bwipeout call Quit()

cnoreabbrev bu call Quit()
cnoreabbrev bun call Quit()
cnoreabbrev bunl call Quit()
cnoreabbrev bunlo call Quit()
cnoreabbrev bunloa call Quit()
cnoreabbrev bunload call Quit()

cnoreabbrev qa call QuitAll()
cnoreabbrev qal call QuitAll()
cnoreabbrev qall call QuitAll()
cnoreabbrev wqa call WriteQuitAll()
cnoreabbrev wqal call WriteQuitAll()
cnoreabbrev wqall call WriteQuitAll()

" disable intuitive usage of unused commands
cnoreabbrev UNUSED_quit quit
cnoreabbrev UNUSED_qall qall
cnoreabbrev UNUSED_write write
cnoreabbrev UNUSED_wq wq
cnoreabbrev UNUSED_wqall wqall
cnoreabbrev UNUSED_bdelete bdelete
cnoreabbrev UNUSED_bwipeout bwipeout
cnoreabbrev UNUSED_bunload bunload
cnoreabbrev UNUSED_tab tab
cnoreabbrev UNUSED_tabnew tabnew
cnoreabbrev UNUSED_tabedit tabedit
cnoreabbrev UNUSED_tabfind tabfind

" }}}
" Performance -----------------------------{{{

" draw only when needed
set lazyredraw

" indicates terminal connection, Vim will be faster
set ttyfast

" max column where syntax is applied (default: 3000)
set synmaxcol=81

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

  if v:version >= 801
    autocmd WinEnter set wincolor=NormalAlt
  endif

"     }}}
"     Good Practices Autocommands Group -----------------------------------{{{

  autocmd BufEnter * :silent call ExtraSpaces() | silent call OverLength()

"     }}}
"     Buffers Autocommand Groups ----------------------------------------{{{

  " display buffers list when a buffer is added/deleted to buffers list
  autocmd BufAdd,BufDelete * execute "let s:bufferslist_changed = v:true"

  " entering commandline erase displayed buffers list
  autocmd CmdlineEnter * execute "let s:clock = s:nb_period * s:update_cb" |
    \ call s:EraseBuffersList(s:erase_timer) | redraw

  " timer stops incremental search, those lines renable this feature
  autocmd CmdlineEnter * call timer_pause(s:monitor_timer, v:true) |
    \ call timer_pause(s:update_timer, v:true) |
    \ call timer_pause(s:erase_timer, v:true)
  autocmd CmdlineLeave * call timer_pause(s:monitor_timer, v:false) |
    \ call timer_pause(s:update_timer, v:false) |
    \ call timer_pause(s:erase_timer, v:false)

"     }}}
"     NERDTree Autocommand Groups ----------------------------------------{{{

  autocmd BufEnter * :silent call CloseLonelyNERDTreeWindow()
  autocmd BufEnter * :silent call BringBackNERDTree()

  " avoid commandline for NERDTree buffers
  autocmd BufEnter * :if bufname('%') =~ 'NERD_tree_\d\+' |
    \ nnoremap <buffer> : <Esc> | endif

"     }}}
"     Vimscript fyletype Autocommand Group---------------------------------{{{

  autocmd FileType vim setlocal foldmethod=marker

"     }}}
augroup END

"   }}}
" }}}
