# zk.vim

Yet another Zettelkasten for Vim

No, this one isn't a wrapper for [zk](https://github.com/zk-org/zk), it doesn't use the zk binary.

I've written this in pure vimscript (and will write a cli utility to go with)

All of this is only supporting Linux as I can use WSL.

> [!WARNING]
> Warning: This plugin is still under heavy design and development changes and may
> not be fully tested.

## Why

Wanted a personalised one. The zk binary organises everything using a sqlite file,
which has many benefits, but I feel mine solves these with better design choices
to allow for better searching, tagging, linking and integrating with existing
systems.

The "purist" Zettelkasten approach is to have a single zk to manage everything,
so everything exists inside a single zk_root directory rather than a sqlite file. I
don't impose any ideology, you can create
"notebooks"/"categories"/"<replace-organisation-term-here>" directories as you see
fit. Since we are working with the filesystem, we have the ability to symlink to existing files/directories, immediately
incorperating them to the Zettlecastle. See some [drawbacks](#drawbacks) while I
work out/ of this design.

## Drawbacks

tbd...

## Dependencies

You _can_ get by without them, but life is much better with

* [FZF](https://github.com/junegunn/fzf.vim) (ofc requires [FZF](https://github.com/junegunn/fzf) binary)
* [RipGrep](https://github.com/jremmen/vim-ripgrep) (ofc requires [RipGrep](https://github.com/BurntSushi/ripgrep) binary)

## Setup

If you use vim-plug, in your .vimrc

```vim
Plug 'b0dee/zk.vim'
```

The source your .vimrc and run `:PlugInstall`

## Usage

```vimhelp
*zk.vim* Yet another Zettelkasten plugin for Vim

CONTENTS                                            *zk.vim-contents* 

1. Commands                         |commands|
2. Settings                         |settings|
3. Mappings                         |mappings|
4. API                              |api|

=========================================================================
1. Commands                                         *commands*

                                                    *:Zk*
:Zk {filepath}      Create or open {filepath} relative to g:zk_root

                                                    *:ZkLink*
:ZkLink[!] [target] [link_name] [flags]
                    Create link in current file to another file. Optional bang
                    launches interactive.

                                                    *:ZkLn*
:ZkLn[!] {target} {link_name} [flags]
                    Create symlink to target using new link link_name. 
                    Uses ln API under the hood with flags appended to command. 
                    Creates any missing parent directories.
                    Provide optional bang '!' to force action.

                                                    *:ZkMkdir*
:ZkMkdir {path}     Create directory structure relative to g:zk_root.
                    Any intermediate directories in {path} are created (-p).

                                                    *:ZkMv*
:ZkMv[!] {source} {target}
                    Move source to target within g:zk_root. Use optional bang
                    '!' to force the action.

                                                    *:ZkRg*
:ZkRg[!] [arguments]
                    Search with ripgrep, using g:zk_root as base, passing
                    [arguments] direct to the binary. Opens, in full screen if
                    optional bang '!' provided, an FZF interactive window with
                    the results.

                                                    *:ZkGrep*
:ZkGrep[!] [arguments]
                    The builtin alternative for |:ZkRg|. Uses lgrep to
                    populate location-list. Use vim lgrep syntax for
                    arguments. Optional bang takes you to first result.

                                                    *:ZkFzf*
:ZkFzf[!] [search]
                    Search filenames for [search] with FZF, using g:zk_root as
                    a base. Opens, in full screen if optional bang '!'
                    provided, an interactive FZF window with results.

                                                    *:ZkFind*
:ZkFind[!] [arguments]
                    The builtin alternative for ZkFzf. Uses find binary to 
                    populate location list with results. Use find syntax for
                    arguments. Optional bang takes you to first result.

=========================================================================
2. Settings                                         *settings*

                                                    *g:zk_root*
g:zk_root          string (default $HOME/.zk) 

      The variable defining zk root

                                                    *g:zk_auto_title*
g:zk_auto_title    boolean (default v:true)         
      
      Boolean to control if new files automatically get header inserted.
      There is a lookup table of extension by prefix s:comment_prefix in
      autoload/zk.vim.

                                                    *g:zk_auto_title_replacement_regex*
g:zk_auto_title_replacement_regex    
                    string (default '_')         
      
      Replace with spaces any occurances of pattern in filename when inserting
      title.

=========================================================================
3. Mappings                                         *mappings*


=========================================================================
4. API                                              *api*

See autoload/zk.vim as it is a very lightweight and simple API. Creating your 
own extensions should be easy enough, see example below.

Create your own `:Journal` command to open a daily journal organised within a Journal
directory: >
      :command! -nargs=* Journal call zk#Zk(0,strftime("journals/%Y-%m-%d.txt"))

```

## TODO

* Custom completion function for paths
