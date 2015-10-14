" Jumps extension for CtrlP
"
" Maintainer:   DeaR <nayuri@kuonn.mydns.jp>
" Last Change:  14-Oct-2015.
" License:      Vim License  (see :help license)

if exists('g:loaded_ctrlp_jumps') && g:loaded_ctrlp_jumps
  finish
endif
let g:loaded_ctrlp_jumps = 1

call add(g:ctrlp_ext_vars, {
\ 'init'   : 'ctrlp#jumps#init(s:crbufnr,s:crfile)',
\ 'accept' : 'ctrlp#jumps#accept',
\ 'lname'  : 'jumps',
\ 'sname'  : 'jmp',
\ 'type'   : 'tabe',
\ 'sort'   : 0,
\ 'nolim'  : 1})

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

function! s:jumplist(jump, crbufnr, crfile)
  let parts = matchlist(a:jump, '\v^.\s*\d+\s+(\d+)\s+(\d+)\s')
  if empty(parts)
    return ''
  endif
  let rest = a:jump[len(parts[0]):]
  if bufloaded(rest)
    let path  = rest
    let bufnr = bufnr(rest)
    let text  = get(getbufline(bufnr, parts[1]), 0, '')
  elseif filereadable(rest)
    let path  = rest
    let bufnr = 0
    let text  = '== UNLOADED =='
  elseif getbufline(a:crbufnr, parts[1]) == [rest]
    let path  = a:crfile
    let bufnr = a:crbufnr
    let text  = rest
  else
    return ''
  endif
  return
  \ text . "\t|" . bufnr . ':' . path . '|' .
  \ parts[1] . ':' . parts[2] . '|'
endfunction

function! s:syntax()
  if !ctrlp#nosy()
    call ctrlp#hicheck('CtrlPBufName', 'Directory')
    call ctrlp#hicheck('CtrlPTabExtra', 'Comment')
    syntax match CtrlPBufName '\t|\d\+:\zs[^|]\+\ze|\d\+:\d\+|$'
    syntax match CtrlPTabExtra '\zs\t.*\ze$' contains=CtrlPBufName
  endif
endfunction

function! ctrlp#jumps#init(crbufnr,crfile)
  redir => res
  silent! jumps
  redir END
  let clines = []
  for each in split(res, "\n")[1:]
    let line = s:jumplist(each, a:crbufnr, a:crfile)
    if !empty(line)
      call add(clines, line)
    endif
  endfor

  call s:syntax()
  return reverse(filter(clines, 'count(clines, v:val) == 1'))
endfunction

function! ctrlp#jumps#accept(mode, str)
  let info = matchlist(a:str, '\t|\(\d\+\):\([^|]\+\)|\(\d\+\):\(\d\+\)|$')
  let bufnr = str2nr(get(info, 1))
  call ctrlp#acceptfile(a:mode, bufnr ? bufnr : get(info, 2))
  call cursor(get(info, 3), get(info, 4))
  silent! normal! zvzz
endfunction

function! ctrlp#jumps#id()
  return s:id
endfunction
