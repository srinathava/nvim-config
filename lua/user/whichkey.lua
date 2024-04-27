local wk = require("which-key")
local Terminal = require('toggleterm.terminal').Terminal

-- https://stackoverflow.com/questions/6380820/get-containing-path-of-lua-file
local function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

local function create_lazygit_term()
    local cmd = 'lazygit'
    if vim.fn.executable('nvr') == 1 then
        -- If nvr is found, then use it within neovim
        cmd = 'lazygit -ucf ~/.config/lazygit/config.yml,' .. script_path() .. 'lazygit_nvr.yml'
    end
    cmd = "VIM= VIMRUNTIME= " .. cmd
    return Terminal:new({
        cmd = cmd,
        hidden = true,
        direction = "float"
    })
end
local lazygit = create_lazygit_term()
local function toggle_lazygit()
    lazygit:toggle()
end

local terminals_created = {}

local function new_terminal()
    local name                                = vim.fn.input('Enter a name for the terminal: ')
    local term                                = Terminal:new({
        hidden = true,
        direction = "float",
    })
    terminals_created[#terminals_created + 1] = term
    local curnum                              = #terminals_created
    wk.register({
        ["<space>t" .. curnum] = { function() term:toggle() end, "Terminal " .. curnum .. ": " .. name }
    })
    term:toggle()
end

local M = {}

M.setup = function()
    -- timeoutlen of a reasonably small number works best to bring up the
    -- window for not so frequently used shortcuts "fast enough"
    vim.o.timeoutlen = 200

    wk.setup()
    wk.register({
        m = {
            name = "Project",
            c = { "<cmd>lua require('user.myproj').copygithub()<cr>", "Copy GitHub URL" },
            r = { "<cmd>lua require('user.myproj').copyrelpath()<cr>", "Copy relative path" },
            a = { "<cmd>lua require('user.myproj').copyabspath()<cr>", "Copy absolute path" },
        },
        t = {
            name = "Terminal",
            f = { "<cmd>ToggleTerm direction=float<cr>", "Floating" },
            n = { new_terminal, "New terminal" },
        },
        G = { toggle_lazygit, "Lazygit" }
    }, { prefix = "<space>" })
    require('user.bookmarks').refresh_bookmarks()
end

return M
