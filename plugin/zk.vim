if exists('g:loaded_zk')
  finish
endif
let g:loaded_zk = 1

" Default variables
let s:zk_vars = {
\ 'zk_root': $HOME.'/.zk',
\ 'zk_auto_title': v:true,
\ 'zk_auto_title_replacement_regex': '_',
\ 'zk_default_ext': 'md',
\ 'zk_prefix_lookup': {
\   'vim': '" ',
\   'c': '// ',
\   'default': '# ',
\ }
\ }

" Set default variables
for [key, value] in items(s:zk_vars)
  if !exists('g:' . key)
    let g:{key} = value
  endif
endfor

augroup zk
  autocmd! 
  " Create intermediate directories on write when under g:zk_root
  execute "autocmd BufWrite,BufWritePre,FileWritePre " . g:zk_root . "/* call zk#Mkdir(fnamemodify(expand('%'), ':p:h'))"
augroup END

command! -nargs=+ -bang Zk       call zk#Zk(<bang>0, <q-args>)
command! -nargs=+ -bang ZkLn     call zk#Ln(<bang>0, <f-args>)
command! -nargs=* -bang ZkRg     call zk#Rg(<bang>0, <f-args>)
command! -nargs=* -bang ZkFzf    call zk#Fzf(<bang>0, <f-args>)
command! -nargs=+       ZkMkdir  call zk#Mkdir(<q-args>)
command! -nargs=+ -bang ZkMv     call zk#Mv(<bang>0, <f-args>)
command! -nargs=+ -bang ZkRename call zk#Rename(<bang>0, <f-args>)
command! -nargs=* -bang ZkLink   call zk#Link(<bang>0, <f-args>)
