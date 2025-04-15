# zk.vim

Yet another [Zettelkasten](https://zettelkasten.de) for Vim

No, this one isn't a wrapper for the [zk](https://github.com/zk-org/zk) binary.

This is my own Zettelkasten implementation, written in pure vimscript, a cli companion is being made [here](https://github.com/b0dee/zk.sh).

> [!NOTE]
> All of this is only supporting Linux (not handling Windows paths, binaries etc.) as I can use WSL. If you want to make it
> Windows compatible, feel free.


## Core Principles

1. [x] Simple - in design and use
2. [x] Flexible - No enforcement of ideology, use it how _you_ want to
3. [x] Compatible - Easy to adopt and migrate to
4. [x] Fast - Rapid entry
5. [x] Fun - Remove blockers from all areas of note taking

## Why

Wanted a personalised one. I've tried ([and made plugins
for](https://github.com/b0dee/vim-bujo)) other note taking
methods, but Zettelkasten is the soundest I've come across.

I am a fan of simplicity. I firmly believe, when done correctly, it produces
the least obtrusve and most flexible way, allowing for easy extension and
customisation (totally not because I'm lazy!).

## Design

Everything exists inside a single zk_root directory.  This makes searching and
tagging easier. I don't impose any ideology either, you can (but dont't have to)
create "notebooks"/ "categories"/ "\<replace-organisation-term-here\>"
directories as you see fit. Since we are working with the filesystem, we have
the ability to symlink to existing files/directories, immediately incorperating
them to the Zettelkasten.

## Dependencies

* [FZF.vim](https://github.com/junegunn/fzf.vim) (ofc requires [FZF](https://github.com/junegunn/fzf) binary)
* [RipGrep](https://github.com/BurntSushi/ripgrep)

## Setup

If you use vim-plug, in your .vimrc

```vim
Plug 'b0dee/zk.vim'
```

Configure g:zk_root to your liking, the default is `~/.zk`

> [!IMPORTANT]
> You *MUST* relaunch Vim after changing g:zk_root for the autocmds to pick it
> up. They're defned in plugin/zk.vim which is loaded on Vim startup

The source your .vimrc and run `:PlugInstall`

## Usage

### Note Taking

The primary interface is the `:Zk` command, which will create or open a file.

```vimhelp
:[range]Zk[!] {filename} [msg] 
                    Create or open {filename} relative to *g:zk_root*. Provided
                    {filename} can contain '/'. Missing directories will not be made
                    until either a BufWrite* or FileWritePre event is triggered, 
                    this only applies when current buffer is in g:zk_root.

                    {filename} does not need to have a file extension, a default
                    one is added if this is omitted - see |g:zk_default_ext|.

                    If it is a new file and *g:zk_auto_title* is true it
                    automatically inserts a title. 

                    If a [msg] is provided it is appended to the file without any
                    prefix, you do not need to use quotes, everything after
                    the filename is joined as a single string.

                    If [range] is provided, the selection range is appended as a 
                    quoteblock after the [msg], if it was provided, with an
                    empty line between.

                    It is not possible to have a single line selection range.

                    Providing optional bang '!' to the command will skip 
                    opening {filename}, [range] and [msg] will be written to
                    the file as normal (rapid entry).
```

### Searcing

All searching commands launch an interactive FZF window.

#### Content Search

Searching through files is done with `:ZkRg`.

```vimhelp
:ZkRg[!] [arguments]
                    Search with ripgrep, using g:zk_root as base, passing
                    [arguments] direct to the binary. Opens, in full screen if
                    optional bang '!' provided, an FZF interactive window with
                    the results.
                    Running without arguments shows all files in
                    interactive mode.
```

#### File Name Search

Searching through file names is done with `:ZkFzf`

```vimhelp
:ZkFzf[!] [search]
                    Search filenames for [search] with FZF, using g:zk_root as
                    a base. Opens, in full screen if optional bang '!'
                    provided, an interactive FZF window with results.
                    Running without arguments shows all files in
                    interactive mode.
```

### Settings

Customisable settings

```vim
let g:zk_root = '~/MyZettelkasten'  " Default is '$HOME/.zk'
let g:zk_default_ext = 'txt'        " Extension without dot. Default is 'md'
let g:zk_auto_title = v:false       " Default is true
let g:zk_prefix_lookup = {          " Extends and overwrites default
\  '<ext>': '<prefix><space>'       " <ext> is without dot, i.e. "asm", include space as part of prefix
\ }
```

See vim help doc for more info.
