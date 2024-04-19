# Portal (zsh plugin)

https://github.com/anasouardini/portal/assets/114059811/57d9e0e2-2353-4057-9b90-9f08c72ead61

A very basic script for jumping to/from paths without having to write the whole path, open multiple terminal sessions or do a file system search using `fzf`.

## Install

(If there is enough interest, I'll probably redo it in Golang and try to distribute so you can install it as you would with any other package)

If you don't have `zsh-zap` installed, download the script from the repository and `source` it in your `.zshrc` file: add `source portal.plugin.zsh` in you `.zshrc`. Otherwise In your `zsh` session, with `zsh-zap` installed, add `plug anasouardini/portal` to your `.zshrc`.

## Usage

For a quick Usage menu, type `portal help`.

A basic way to use Portal is by visiting paths as you would normally, and then every path you visited once, you can access it by vaguely typing it: like "im" for "~/.config/nvim", like it's demonstrated in the video above.

The 2nd way you can use Portal is by explicitly storing a path with a name using the command `portal create [name]`, so you can always access it with that same name, use this with paths that always exist since they'd never get changed.

Use both methods whenever you see fit.

Another feature Portal gives you is a history of paths you've visited in that shell session, so you can easily browse back and forth with no effort: you can either use `cdd` for going down/back and `cdu` for up/forwards or with the keybindings `Ctrl+j` and `Ctrl+k` respectively.

Almost everything is stored as a file so you can change anything you'd like manually.

The lists are stored respectively in:
1. `$HOME/.local/share/portal/implicit-portals`
2. `$HOME/.local/share/portal/explicit-portals`
3. The history is session-based; stored in memory.

The bindings you set using `portal bind` are stored in: `$HOME/.local/share/portal/bindings`. Portal doesn't set short aliases/bindings for all commands so it doesn't conflict with any of your other aliases. 

While, by default, portal helps you *navigate* you paths, that's only a default way to use it: At it's core, Portal is executing commands on given paths (implicitly or explicitly), by default it's the command `cd`. for instance:

The command `portal im tree fig` would list a tree of the path, without having to navigate to it just to do the `tree` command. Or if you prefer the explicit method: `portal ex tree conf`.

**HAPPY TELEPORTATION!**
