if exists('g:zk_autoloaded') | finish | endif
let g:zk_autoloaded = 1

function! s:joinpath(...) abort
  return fnameescape(substitute(join(a:000, '/'), "//", "/", "g"))
endfunction

function! s:format_title(filename, prefix) abort
  " Format title
  let l:title = split(split(a:filename, '/')[-1], '\.')[-2] 
  let l:title = join(split(l:title, '_'), ' ')
  let l:title = join(split(l:title, '-'), ' ')
  let l:title = substitute(l:title, '\( *[a-z]\)\([a-z]\+\)\( \|$\)', '\U\1\L\2\3','g')
  let l:title = a:prefix . l:title
  return l:title
endfunction

function! s:append(filepath, message, tofile, linenum) abort
  if !a:tofile
    return append(a:linenum, a:message)
  else
    return writefile(a:message, a:filepath, 'a')
  endif
endfunction

function! zk#Zk(bang,range_start, range_end, filename,...) abort 
  " Strip leading slash
  let l:filename = a:filename[0] == '/' ? a:filename[1:] : a:filename
  " Check if filename has extension, add default if not
  if a:filename !~ '\.\w\+$' | let l:filename .= '.' . g:zk_default_ext | endif
  let l:filepath = s:joinpath(g:zk_root, l:filename)
  let l:newfile = !filereadable(l:filepath)

  " Unfortunately, as Vim passes current line as default for empty range 
  " we are not able to write a single line range
  " Do this before the execution of :e as it changes buffer it gets lines from
  let l:quote = []
  if a:range_start != a:range_end
    let l:quote = ['']
    for line in getline(a:range_start, a:range_end)
      let l:quote = add(l:quote, '> ' . line)
    endfor
  endif

  if !a:bang
    call execute(':e' . l:filepath)
  endif
  
  " Exit early if possible, user only wanted to open file
  if !l:newfile && len(a:000) == 0 && a:range_start == a:range_end| return | endif

  let l:prefix = index(keys(g:zk_prefix_lookup),&filetype) >= 0 ? g:zk_prefix_lookup[&filetype]:  g:zk_prefix_lookup['default']

  if l:newfile && g:zk_auto_title
    let l:title = s:format_title(l:filename, l:prefix)
    call s:append(l:filepath,[l:title, ''], a:bang, 0)
  endif

  " Exit early if possible, user did not provide any message or range to write
  if len(a:000) == 0 && a:range_start == a:range_end | return | endif

  let l:message = extend([join(a:000, ' ')], l:quote)

  return s:append(l:filepath, l:message, a:bang,line('$'))

endfunction

function! zk#Ln(bang, target, link_name) abort
  " Split link_name by slashes and create any intermediate directories, then symlink
  call zk#Mkdir(fnamemodify(s:joinpath(g:zk_root, l:link_name), ':h'))
  if filereadable(a:link_name) && !a:bang
    echoerr "Target already exists. Use ZkLn! to force"
  endif
  return execute(':silent !ln -s' . (a:bang ? 'f ' : ' ')  . nameescape(l:target) . ' ' . s:joinpath(g:zk_root, l:link_name))
endfunction

function! zk#Mkdir(path) abort
  " Create all intermediate directories
  " Substitute g:zk_root to '' on path to prevent incorrect nesting
  return mkdir(s:joinpath(g:zk_root,substitute(a:path,g:zk_root,'','')), 'p')
endfunction

function zk#Mv(bang, source, target) abort
  if filreadable(s:joinpath(g:zk_root, a:target)) && !a:bang
    echoerr "Target already exists. Use ZkMv! to force"
  endif
  if rename(a:source, s:joinpath(g:zk_root, a:target)) != 0
    echoerr "Failed to move file"
  endif
endfunction

function zk#Rename(bang, source, target) abort
  return zk#Mv(a:bang, s:joinpath(g:zk_root, a:source), a:target)
endfunction

function! zk#Rg(bang,...) abort 
  " Use fzf with ripgrep to open interactive search (we follow symlinks)
  return fzf#vim#grep('rg --column --follow --line-number --no-heading --color=always --smart-case '.fzf#shellescape(join(a:000, ' ')) . ' ' . g:zk_root, fzf#vim#with_preview(), a:bang)
endfunction

function! zk#Fzf(bang,...) abort
  " Use fzf to open interactive search
  return fzf#run(fzf#wrap({'source': 'find ' . fnameescape(g:zk_root) . ' -type f' . (len(a:000) > 0 ? '-name "' . join(a:000, ' ') . '"': '') }, a:bang))
endfunction

function! zk#Ex(bang, path) abort
  " execute Explore on g:zk_root joined with path
  return execute(':Explore' . (a:bang ? '!' : '') . ' ' . s:joinpath(g:zk_root, a:path))
endfunction

function! zk#CompleteListFile(arglead, cmdline, cursorpos) abort
  let l:filter = a:arglead == '' ? '*' : '*'.a:arglead.'*'
  let l:matches = globpath(g:zk_root,'**/'.l:filter, 0, 1)
  let l:results = []
  for result in l:matches
    " Strip zk root
    "if !filereadable(result) | continue | endif
    let result = substitute(result, expand(g:zk_root) . '/', '', '')
    let l:results = add(l:results, result)
  endfor
  return l:results
endfunction

function! zk#Link(bang,...) abort

endfunction
