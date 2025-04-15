if exists('g:zk_autoloaded') | finish | endif
let g:zk_autoloaded = 1

let s:buffers = {}

if !exists('g:zk_prefix_lookup') | let g:zk_prefix_lookup = {} | endif
let s:prefix_lookup = extend({
\   'vim' : '" ',
\   'bat' : ':: ',
\   'cmd' : ':: ',
\   'sql' : '-- ',
\   'c'   : '// ',
\   'h'   : '// ',
\   'cpp' : '// ',
\   'vb'  : '// ',
\   'vbs' : '// ',
\   'rss' : '// ',
\   'js'  : '// ',
\   '*'   : '# ',
\ }, g:zk_prefix_lookup)

function! s:joinpath(...) abort
  return fnameescape(substitute(join(a:000, '/'), "//", "/", "g"))
endfunction

function! s:format_title(filename, prefix) abort
  " Format title
  let l:title = split(split(a:filename, '/')[-1], '\.')[-2] 
  let l:title = join(split(l:title, g:zk_auto_title_regex), ' ')
  let l:title = substitute(l:title, '\( *[a-z]\)\([a-z]\+\)\( \|$\)', '\U\1\L\2\3','g')
  let l:title = a:prefix . l:title
  return l:title
endfunction

function s:system(...) abort
  return system(join(add(a:000,'2>/dev/null')," "))
endfunction

function s:setfattr(filepath, key, value) abort
  return system('attr -Lqs ' . a:key . ' -V ' . shellescape(a:value) . ' ' . a:filepath)
endfunction

function! s:getfattr(filepath, key) abort
  return system('attr -Lqg ' . a:key . ' ' . a:filepath . ' 2&>/dev/null')
endfunction

function! zk#append(filepath, message, tofile, linenum) abort
  if !a:tofile
    return append(a:linenum-1, a:message)
  else
    return writefile(a:message, a:filepath, 'a')
  endif
endfunction

function! zk#zk(bang,range_start, range_end, filename,...) abort 
  " Strip leading slash
  let l:filename = a:filename[0] == '/' ? a:filename[1:] : a:filename

  " Check if filename has extension, add default if not
  if a:filename !~ '\.\w\+$' | let l:filename .= '.' . g:zk_default_ext | endif
  let l:fext = split(l:filename, '\.')[-1]
  let l:prefix = get(s:prefix_lookup, l:fext, s:prefix_lookup['*'])
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
    let l:command = getbufinfo('%')[0].changed ? ':vsplit ' : ':e '
    call execute(l:command . l:filepath)
  endif
  
  if l:newfile && g:zk_auto_title
    let l:title = s:format_title(l:filename, l:prefix)
    call zk#append(l:filepath,[l:title, ''], a:bang, 1)
  endif

  let l:message = extend([join(a:000, ' ')], l:quote)
  call zk#append(l:filepath, l:message, a:bang,line('$'))

  if !a:bang && len(l:message) > 0
    " Move cursor to line of appended message
    call cursor(line('$'),0)
  endif

  return
endfunction

function! zk#ln(bang, target, link_name, ...) abort
  " Split link_name by slashes and create any intermediate directories, then symlink
  let l:link_name = s:joinpath(g:zk_root, a:link_name)
  let l:target = expand(a:target)
  let l:args = join(a:000, ' ')
  if filereadable(l:link_name) && l:args !~ 'f'
    echoerr "Destination file already exists."
  endif

  " Create intermediate directories stripping filename
  call zk#mkdir(fnamemodify(l:link_name, ':p:h'))

  call system('ln -s ' . join([l:target, l:link_name, l:args], ' '))
  if a:bang
    call execute(':e ' . l:link_name)
  endif
  return 
endfunction

function! zk#mkdir(path) abort
  " Create all intermediate directories
  " Substitute g:zk_root to '' on path to prevent incorrect nesting
  let l:path = s:joinpath(expand(g:zk_root),substitute(expand(a:path),expand(g:zk_root),'',''))
  return mkdir(l:path, 'p')
endfunction

function zk#mv(bang, source, target) abort
  let l:path = s:joinpath(g:zk_root, a:target)
  if filereadable(l:path) && !a:bang
    echoerr "Target already exists. Use ! to force"
  endif
  if rename(fnameescape(expand(a:source)), l:path) != 0
    echoerr "Failed to move file"
  endif
  return 
endfunction

function zk#rename(bang, source, target) abort
  return zk#mv(a:bang, s:joinpath(g:zk_root, a:source), a:target)
endfunction

function! zk#rg(bang,...) abort 
  " Use fzf with ripgrep to open interactive search (we follow symlinks)
  return fzf#vim#grep('rg --column --follow --line-number --no-heading --color=always --smart-case '.fzf#shellescape(join(a:000, ' ')) . ' ' . g:zk_root, fzf#vim#with_preview(), a:bang)
endfunction

function! zk#fzf(bang,...) abort
  " Use fzf to open interactive search
  return fzf#run(fzf#wrap({'source': 'find ' . fnameescape(g:zk_root) . ' -type f' . (len(a:000) > 0 ? '-name "' . join(a:000, ' ') . '"': '') }, a:bang))
endfunction

function! zk#explore(bang, path) abort
  " execute Explore on g:zk_root joined with path
  return execute(':Explore' . (a:bang ? '!' : '') . ' ' . s:joinpath(g:zk_root, a:path))
endfunction

function! zk#complete(arglead, cmdline, cursorpos) abort
  let l:arglead = a:arglead
  let l:argleadchar = l:arglead[0]
  " TODO: Better handling of other paths i.e. '~/*' '/*'
  if l:argleadchar != '' && stridx('~/.',l:argleadchar) >= 0 && a:cmdline !~ '^ZkRe'
    " User is trying to search outside g:zk_root
    let l:lastslash = strridx(l:arglead, '/')
    let l:searchbase = l:arglead[:l:lastslash]
    let l:arglead = l:arglead[l:lastslash+1:]
  else 
    let l:searchbase = g:zk_root
  endif
  let l:filter = l:arglead == '' ? '*' : '*'.l:arglead.'*'
  let l:matches = globpath(l:searchbase,l:filter, 0, 1)
  let l:results = []
  for result in l:matches
    if isdirectory(result) | let result .= '/' | endif
    let result = substitute(result, expand(g:zk_root) . '/', '', '')
    let result = substitute(result, expand($HOME) . '/', '~/', '')
    let l:results = add(l:results, result)
  endfor
  return l:results
endfunction
