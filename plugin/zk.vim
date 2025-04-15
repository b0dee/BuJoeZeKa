if exists('g:loaded_zk')
  finish
endif
let g:loaded_zk = 1

" Default variables
let s:zk_vars = {
\ 'zk_root': $HOME.'/.zk',
\ 'zk_auto_title': v:true,
\ 'zk_auto_title_regex': '[_-]',
\ 'zk_default_ext': 'md',
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
  execute "autocmd BufWrite,BufWritePre,FileWritePre " . g:zk_root . "/* call zk#mkdir(fnamemodify(expand('%'), ':p:h'))"
augroup END

command! -nargs=+ -bang -complete=customlist,zk#complete -range Zk        call zk#zk(<bang>0, <line1>, <line2>, <f-args>)
command! -nargs=+ -bang -complete=customlist,zk#complete        ZkLn      call zk#ln(<bang>0, <f-args>)
command! -nargs=? -bang -complete=customlist,zk#complete        ZkExplore call zk#explore(<bang>0, <q-args>)
command! -nargs=+ -bang -complete=customlist,zk#complete        ZkMv      call zk#mv(<bang>0, <f-args>)
command! -nargs=+ -bang -complete=customlist,zk#complete        ZkRename  call zk#rename(<bang>0, <f-args>)
command! -nargs=+       -complete=customlist,zk#complete        ZkMkdir   call zk#mkdir(<q-args>)
command! -nargs=* -bang                                         ZkRg      call zk#rg(<bang>0, <f-args>)
command! -nargs=* -bang                                         ZkFzf     call zk#fzf(<bang>0, <f-args>)

