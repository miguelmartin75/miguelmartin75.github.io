---
title: "Neovim Notes"
---


# Literate Programming

- Lua specific
    - https://github.com/jbyuki/carrot.nvim
- [mdeval](https://github.com/jubnzv/mdeval.nvim)
- [sniprun](https://github.com/michaelb/sniprun)

# lua
- REPL: https://github.com/bfredl/nvim-luadev


# Telescope / fuzzy finding

- From query results -> action
    - to quickfix: 
        - `telescope.actions.send_selected_toqflist()`

# Basics

## Windows

- open
    - :sp, C-w s, C-w S, C-w C-s
    - :vs, C-w v, C-w V, C-w C-s
    - :new, C-W n, C-W C-N
- quit
    - :q, C-W q
- cursor movement
    - move to previous window C-w p
- rotation
    - C-W r, C-W C-R =>
        - rotate downwards/rightwards
        - essentially a shift right or shift down
        - 1st becomes second, 2nd becomes 3rd, etc.
        - within same row or column
    - C-W R => upwards or left
        - opposite of above
    - C-W x => exchange current with next
    - C-W K => move current to top, full width of screen
    - C-W J => move current to bottom, full width of screen
    - C-W H => move current to far left, full width of screen
        - if in horizontal split => exchange to vertical split
    - C-W H => move current to far right, full width of screen
    - C-W T => move current window to a new tab
- resizing
    - C-W _, C-W C-_ => highest possible height
    - :res -N or +N
        - decrease or increase by N columns (height)
    - C-W < or > => :res with +1 or -1
    


## folds #todo
## tabs #todo
## quickfix #todo
# help

- telescope has help tags
- how to focus window? #todo
# Narrow to subtree / block

Can use zen-mode (see "plugins") - seems to use a [fold](https://github.com/Pocco81/true-zen.nvim/blob/main/lua/true-zen/narrow.lua)


Alternative:
- https://github.com/chrisbra/NrrwRgn

# markdown

## evaluation of code
```bash
echo "hi"
```

# plugins
## zen-mode
- https://github.com/Pocco81/true-zen.nvim

## zk, zk-nvim

- https://github.com/mickael-menu/zk
- https://github.com/mickael-menu/zk-nvim

