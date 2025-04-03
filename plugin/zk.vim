if exists('g:loaded_zk')
  finish
endif
let g:loaded_zk = 1

" Default variables
let s:zk_vars = {
\ 'zk_root': $HOME.'/.zk',
\ 'zk_auto_title': v:true,
\ 'zk_auto_title_replacement_regex': '_'
\ }

" Set default variables
for [key, value] in items(s:zk_vars)
  if !exists('g:' . key)
    let g:{key} = value
  endif
endfor

command! -bang -nargs=+ Zk      call execute(':e ' . fnameescape(g:zk_root . '/' . <q-args>) )
command! -bang -nargs=* ZkLink  call execute(':e ' . fnameescape(g:zk_root . '/' . <q-args>))
command! -bang -nargs=* ZkLn    call execute(':e ' . fnameescape(g:zk_root . '/' . <q-args>))
command! -bang -nargs=+ ZkGrep  call execute(':lhelpgrep! -rni ' . <f-args> . ' ' . fnameescape(g:zk_root))
command! -bang -nargs=* ZkRg    call fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case '.fzf#shellescape(<q-args>) . ' ' . g:zk_root, fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=* ZkFind  call execute(':lexpr! ' . system('find ' . fnameescape(g:zk_root) . ' -type f -name "' . <q-args> . '"')
command! -nargs=+       ZkMkdir call zk#Mkdir(<q-args>)
command! -bang -nargs=+ ZkMv    call execute(':e ' . fnameescape(g:zk_root . '/' . <q-args>) )
