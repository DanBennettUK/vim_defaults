source $VIMRUNTIME/vimrc_example.vim
source $VIMRUNTIME/mswin.vim
behave mswin

"Personal Settings.
"More to be added soon.
execute pathogen#infect()
filetype plugin indent on

if has("gui_running")
  function! ScreenFilename()
    if has('amiga')
      return "s:.vimsize"
    elseif has('win32')
      return $HOME.'\_vimsize'
    else
      return $HOME.'/.vimsize'
    endif
  endfunction

  function! ScreenRestore()
    " Restore window size (columns and lines) and position
    " from values stored in vimsize file.
    " Must set font first so columns and lines are based on font size.
    let f = ScreenFilename()
    if has("gui_running") && g:screen_size_restore_pos && filereadable(f)
      let vim_instance = (g:screen_size_by_vim_instance==1?(v:servername):'GVIM')
      for line in readfile(f)
        let sizepos = split(line)
        if len(sizepos) == 5 && sizepos[0] == vim_instance
          silent! execute "set columns=".sizepos[1]." lines=".sizepos[2]
          silent! execute "winpos ".sizepos[3]." ".sizepos[4]
          return
        endif
      endfor
    endif
  endfunction

  function! ScreenSave()
    " Save window size and position.
    if has("gui_running") && g:screen_size_restore_pos
      let vim_instance = (g:screen_size_by_vim_instance==1?(v:servername):'GVIM')
      let data = vim_instance . ' ' . &columns . ' ' . &lines . ' ' .
            \ (getwinposx()<0?0:getwinposx()) . ' ' .
            \ (getwinposy()<0?0:getwinposy())
      let f = ScreenFilename()
      if filereadable(f)
        let lines = readfile(f)
        call filter(lines, "v:val !~ '^" . vim_instance . "\\>'")
        call add(lines, data)
      else
        let lines = [data]
      endif
      call writefile(lines, f)
    endif
  endfunction

  if !exists('g:screen_size_restore_pos')
    let g:screen_size_restore_pos = 1
  endif
  if !exists('g:screen_size_by_vim_instance')
    let g:screen_size_by_vim_instance = 1
  endif
  autocmd VimEnter * if g:screen_size_restore_pos == 1 | call ScreenRestore() | endif
  autocmd VimLeavePre * if g:screen_size_restore_pos == 1 | call ScreenSave() | endif
endif

" Automatically delete swapfiles older than the actual file.
" Look at this travesty.  vim already has this information but doesn't expose
" it, so I have to reparse the swap file.  Ugh.
function! s:SwapDecide()
python << endpython
import os
import struct

import vim

# Format borrowed from:
# https://github.com/nyarly/Vimrc/blob/master/swapfile_parse.rb
SWAPFILE_HEADER = "=BB10sLLLL40s40s898scc"
size = struct.calcsize(SWAPFILE_HEADER)
with open(vim.eval('v:swapname'), 'rb') as f:
    buf = f.read(size)
(
    id0, id1, vim_version, pagesize, writetime,
    inode, pid, uid, host, filename, flags, dirty
) = struct.unpack(SWAPFILE_HEADER, buf)

try:
    # Test whether the pid still exists.  Could get fancy and check its name
    # or owning uid but :effort:
    os.kill(pid, 0)
except OSError:
    # NUL means clean, \x55 (U) means dirty.  Yeah I don't know either.
    if dirty == b'\x00':
        # Appears to be from a crash, so just nuke it
        vim.command('let v:swapchoice = "d"')

endpython
endfunction

if has("python")
    augroup gvim_swapfile
        autocmd!
        autocmd SwapExists * call s:SwapDecide()
    augroup END
endif

" Toggle Toolbar
function! ToggleGUICruft()
  if &guioptions=='i'
    exec('set guioptions=imrL')
  else
    exec('set guioptions=i')
  endif
endfunction

map <F11> <Esc>:call ToggleGUICruft()<cr>

" by default, hide gui menus
set guioptions=i

set nocompatible
filetype plugin on
augroup litecorrect
    autocmd!
    autocmd FileType markdown,mkd call litecorrect#init()
    autocmd FileType textile call litecorrect#init()
augroup END


" whitespace
set autoindent                  " keep indenting on <CR>
set shiftwidth=4                " one tab = four spaces (autoindent)
set softtabstop=4               " one tab = four spaces (tab key)
set expandtab                   " never use hard tabs
set shiftround                  " only indent to multiples of shiftwidth
set smarttab                    " DTRT when shiftwidth/softtabstop diverge
set fileformats=unix            " unix linebreaks in new files please
set tabstop=4
set sessionoptions-=options
syntax enable
set background=dark
colorscheme PaperColor
"colorscheme hybrid
set guifont=Lucida_Sans_Typewriter:h10
set conceallevel=2              " e.g. Makes links appear as just text instead of the markdown format unless hovered over
set wrap
set linebreak
set nolist
set encoding=UTF-8
set hlsearch " highlight search matches
set incsearch " highlight search matches as I type
set spell spelllang=en_gb
set completefunc=emoji#complete
set laststatus=2
set ff=unix
set history=1000         " remember more commands and search history
set undolevels=1000      " use many muchos levels of undo
set title                " change the terminal's title
set visualbell           " don't beep
set noerrorbells         " don't beep

" Uncomment below to prevent 'tilde backup files' (eg. myfile.txt~) from being created
set nobackup

" Uncomment below to cause 'tilde backup files' to be created in a different dir so as not to clutter up the current file's directory (probably a better idea than disabling them altogether)
set backupdir=C:\Windows\Temp "Windows
"set backupdir=/tmp "Linux

" Uncomment below to disable 'swap files' (eg. .myfile.txt.swp) from being created
set noswapfile

" Don't save hidden and unloaded buffers in sessions.
set sessionoptions-=buffers

" Don't persist options and mappings because it can corrupt sessions.
set sessionoptions-=options

let g:vim_markdown_folding_disabled = 1
let g:vim_markdown_frontmatter = 1 "highlight YAML
"let g:vim_markdown_conceal = 1 "conceal markdown items
let g:auto_save = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline_theme='raven'
let g:indent_guides_guide_size = 1
let g:indent_guides_color_change_percent = 3
let g:indent_guides_enable_on_vim_startup = 1
let g:table_mode_corner="|"
let g:session_autosave = 'no'
let g:session_directory = 'C:\Users\DanBennett\Vim\vimfiles\sessions' "Windows
"let g:session_directory = '~/.vim/sessions' "Linux


" Insert current time plus Header4
nmap <F3> i<C-R>=strftime("#### %H:%M")<CR><Return><Return>
imap <F3> <C-R>=strftime("#### %H:%M")<CR><Return><Return>

" Insert horizontal line
nmap <F4> i---<Return><Return>
imap <F4> ---<Return><Return>

"Convert [ticket:number] to helpspot URL
nmap <silent><F2> :%s#\[ticket:\(\d\+\)\]#[\#\1](https://help.howtomoodle.com/admin.php?pg=request\&reqid=\1)#<CR>
imap <F2> <Esc>:%s#\[ticket:\(\d\+\)\]#[\#\1](https://help.howtomoodle.com/admin.php?pg=request\&reqid=\1)#<CR>gi
