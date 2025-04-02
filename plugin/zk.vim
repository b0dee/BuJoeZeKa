if exists('g:loaded_zk')
  finish
endif
let g:loaded_zk = 1

if !exists('g:zk_root')
  let g:zk_root = $HOME.'/.zk'
endif

command! -bang -nargs=+ Zk call execute(':e ' . fnameescape(g:zk_root . '/' . <q-args>) )
command! -bang -nargs=+ ZkGrep call execute(':lhelpgrep! -rni ' . <f-args> . ' ' . fnameescape(g:zk_root))
command! -bang -nargs=* ZkRg call fzf#vim#grep('rg --column --line-number --no-heading --color=always --smart-case '.fzf#shellescape(<q-args>) . ' ' . g:zk_root, fzf#vim#with_preview(), <bang>0)
command! -bang -nargs=* ZkFind call execute(':lexpr! ' . system('find ' . fnameescape(g:zk_root) . ' -type f -name "' . <q-args> . '"')
command! -nargs=+ ZkMkdir call zk#Mkdir(<q-args>)
