return {
    -- My plugins here
    "nvim-lua/plenary.nvim", -- Useful lua functions used by lots of plugins

    -- Colorschemes
    { 'folke/tokyonight.nvim', lazy = true },

    { "catppuccin/nvim",       name = "catppuccin", priority = 1000 },

    -- LSP
    {
        "neovim/nvim-lspconfig", -- enable LSP
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason-lspconfig.nvim",
            "jose-elias-alvarez/null-ls.nvim",
            "williamboman/mason.nvim",
            { "folke/neodev.nvim", opts = {} },
        },
        config = function()
            require("user.lsp")
        end
    },

    {
        "williamboman/mason.nvim",
        build = ":MasonUpdate", -- :MasonUpdate updates registry contents
        cmd = "Mason"
    },

    -- cmp plugins
    {
        "hrsh7th/nvim-cmp",             -- The completion plugin
        dependencies = {
            "hrsh7th/cmp-buffer",       -- buffer completions
            "saadparwaiz1/cmp_luasnip", -- snippet completions
            "hrsh7th/cmp-nvim-lsp",
            'hrsh7th/cmp-nvim-lsp-signature-help',

            -- snippets
            "L3MON4D3/LuaSnip",             --snippet engine
            "rafamadriz/friendly-snippets", -- a bunch of snippets to use
        },
        event = "InsertEnter",
        config = function()
            require('user.cmp')
        end
    },

    {
        "akinsho/toggleterm.nvim",
        cmd = "ToggleTerm",
        config = function()
            require("toggleterm").setup({
                shell = "/usr/bin/zsh"
            })
        end
    },

    {
        'folke/which-key.nvim',
        config = function()
            require('user.whichkey').setup()
        end
    },

    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        cmd = "Neotree",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
        }
    },

    {
        "tpope/vim-fugitive",
        cmd = { "Git", "Gvdiffsplit", "Gdiffsplit" }
    },

    {
        "lewis6991/gitsigns.nvim",
        -- cmd = { "Gitsigns" },
        config = function()
            require('gitsigns').setup()
        end
    },

    {
        "jay-babu/mason-null-ls.nvim",
        event = { "BufReadPre", "BufNewFile" },
        dependencies = {
            "williamboman/mason.nvim",
            "jose-elias-alvarez/null-ls.nvim",
        },
        config = function()
            require("mason-null-ls").setup({
                ensure_installed = { "clang-format" },
                automatic_installation = true
            })
        end,
    },

    {
        'tpope/vim-abolish',
        cmd = { "Subvert" }
    },

    {
        -- Super useful plugin for navigating C++ code. Shows a live
        -- context of which function you are in the middle of when
        -- scrolling through ginormous functions.
        'nvim-treesitter/nvim-treesitter-context',
        config = function()
            require('treesitter-context').setup({
                enable = true,
                max_lines = 5,
                trim_scope = 'inner'
            })
        end,
    },

    {
        'dyng/ctrlsf.vim',
        cmd = { 'CtrlSF', 'CtrlSFOpen', 'CtrlSFToggle' },
        config = function()
            vim.g.ctrlsf_auto_close = {
                normal = 0,
                compact = 0
            }
            vim.g.ctrlsf_winsize = '30%'
        end
    }


}
