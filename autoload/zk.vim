function! s:joinpath(...) abort
  return fnameescape(substitute(join(a:000, '/'), "//", "/", "g"))
endfunction

function! zk#Zk(bang,filename) abort 
  " if g:zk_root doesn't exist create it 
  return execute(':e ' . s:joinpath(g:zk_root, a:filename))
endfunction

function! zk#Mkdir(path) abort
  " Create all directories in path under g:zk_root replacing 
  " any duplicate slashes caused by string concatenation/ user provided
  return mkdir(s:joinpath(g:zk_root, a:path), 'p')
endfunction

function zk#Mv(bang, source, target) abort
  " Move source to target under g:zk_root

endfunction

function! zk#Ln(bang, target, link_name, ...) abort
  " Split link_name by slashes and create any intermediate directories, then symlink
  call zk#Mkdir(fnamemodify(a:link_name, ':h'))
  return execute(':silent !ln -s ' . fnameescape(a:target) . ' ' . fnameescape(g:zk_root . '/' . a:link_name))
endfunction

function! zk#ZkGrep(bang,...) abort 
  " Populate location list with grep results
  return execute(':lhelpgrep' . a:bang ? ' ' : '! ' . '-rni ' . a:000 . ' ' . fnameescape(g:zk_root))
endfunction

function! zk#ZkRg(bang,...) abort 
  " Use fzf with ripgrep to open interactive search
  return fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case '.fzf#shellescape(a:000) . ' ' . g:zk_root, fzf#vim#with_preview(), a:bang)
endfunction

function! zk#ZkFind(bang,...) abort 
  " Use find to populate location list
  return execute(':lexpr' . a:bang ? ' ' : '! ' . system('find ' . fnameescape(g:zk_root) . ' -type f -name "' . <q-args> . '"')
endfunction


function! zk#Fzf(bang,...) abort
  " Use fzf to open interactive search
  return fzf#run(fzf#wrap({'source': 'find ' . fnameescape(g:zk_root) . ' -type f -name "' . join(a:000, ' ') . '"'}, a:bang))
endfunction

function! zk#Link(bang,...) abort

endfunction
