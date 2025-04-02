function! zk#Zk(bang,filename) abort 
  return execute(':e ' . fnameescape(g:zk_root . '/' . a:filename) )
endfunction

function! zk#Mkdir(path) abort
  " Create all directories in path under g:zk_root replacing 
  " any duplicate slashes caused by string concatenation/ user provided
  return mkdir(substitute(join([g:zk_root, a:path], '/'), '//', '/', 'g'), 'p')
endfunction

function! zk#ZkGrep(bang,...) abort 
  return execute(':lhelpgrep! -rni ' . a:000 . ' ' . fnameescape(g:zk_root))
endfunction

function! zk#ZkRg(bang,...) abort 
  return fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case '.fzf#shellescape(a:000) . ' ' . g:zk_root, fzf#vim#with_preview(), a:bang)
endfunction

function! zk#ZkFind(bang,...) abort 
  return execute(':lexpr! ' . system('find ' . fnameescape(g:zk_root) . ' -type f -name "' . <q-args> . '"')
endfunction


function! zk#Fzf(bang,...) abort
  " Using fzf#run search g:zk_root for optional arguments joined by spaces
  " creating a new fzf window
  return fzf#run(fzf#wrap({'source': 'find ' . fnameescape(g:zk_root) . ' -type f -name "' . join(a:000, ' ') . '"'}, a:bang))
endfunction
