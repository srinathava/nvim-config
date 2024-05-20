local function dir_containing(item)
    local bufdir = vim.fn.expand('%:p')
    if bufdir == "" then
        bufdir = vim.fn.getcwd()
    end
    return require('lspconfig').util.root_pattern(item)(bufdir)
end

local function root_dir()
    return dir_containing('.git')
end

local function find_files()
    require('telescope.builtin').find_files({ cwd = root_dir() })
end

local function grep_files()
    require('telescope.builtin').live_grep({ cwd = root_dir() })
end

local function find_files_cwd()
    require('telescope.builtin').find_files({ cwd = vim.fn.getcwd() })
end

local function grep_files_cwd()
    require('telescope.builtin').live_grep({ cwd = vim.fn.getcwd() })
end

local function buffers_mru()
    require('telescope.builtin').buffers({ sort_mru = true })
end

local function cmd_history()
    -- get current text in command line
    local cmd = vim.fn.getcmdline()
    require('telescope.builtin').command_history({ default_text = cmd })
end

-- Telescope
return {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    keys = {
        { "<F4>",       find_files_cwd },
        { "<leader>fF", find_files,     desc = "Find files (root)" },
        { "<leader>ff", find_files_cwd, desc = "Find files (current dir)" },
        { "<leader>fS", grep_files,     desc = "Search in files (root)" },
        { "<leader>fs", grep_files_cwd, desc = "Search in files (current dir)" },
        { "<F3>",       buffers_mru },
        { "<C-e>",      cmd_history, desc="Command history", mode="c" }
    },
    -- This dependency allows FZF style completion, i.e., you can put
    -- spaces between characters etc.
    dependencies = {
        {
            'nvim-telescope/telescope-fzf-native.nvim',
            build =
            'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build'
        }
    },
    config = function()
        local actions = require('telescope.actions')
        require('telescope').setup({
            defaults = {
                path_display = { truncate = 2 },
                mappings = {
                    i = {
                        ["<C-d>"] = actions.delete_buffer
                    }
                }
            }
        })
        require('telescope').load_extension('fzf')
    end
}
