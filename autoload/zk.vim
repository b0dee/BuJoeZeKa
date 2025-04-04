function! s:joinpath(...) abort
  return fnameescape(substitute(join(a:000, '/'), "//", "/", "g"))
endfunction

function! zk#Zk(bang,filename) abort 
  " Check if filename has extension, add default if not
  let l:filename = a:filename
  if a:filename !~ '\.\w\+$' | let l:filename .= '.' . g:zk_default_ext | endif
  " We don't create missing intermediate directories in case they don't save file
  " TODO: Add BuffWritePre autocommand to create missing directories in g:zk_root
  " using path of current file 
  call execute(':e' . (a:bang ? '! ' : ' ')  . s:joinpath(g:zk_root, l:filename))
  if index(keys(g:zk_prefix_lookup),&filetype) >= 0 
    let l:prefix = g:zk_prefix_lookup[&filetype]
  else
    let l:prefix = g:zk_prefix_lookup['default']
  endif
  let l:title = split(split(l:filename, '/')[-1], '\.')[-2] 
  let l:title = join(split(l:title, '_'), ' ')
  let l:title = join(split(l:title, '-'), ' ')
  let l:title = l:prefix . " " . l:title
  return append(0,l:title)
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

function! zk#Link(bang,...) abort

endfunction
