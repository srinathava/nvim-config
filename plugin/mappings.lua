vim.keymap.set({'n', 'v'}, "g/", "<CMD>lua require('user.utils').search_word()<CR>",
    { desc = "Search for word under cursor" })
