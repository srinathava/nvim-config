-- Setup nvim-cmp.
local cmp = require 'cmp'

local prev = cmp.mapping({
    i = function(fallback)
        if cmp.visible() then
            cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
        else
            fallback()
        end
    end
});

local next = cmp.mapping({
    i = function(fallback)
        if cmp.visible() then
            cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
        else
            fallback()
        end
    end
});

cmp.setup({
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<CR>'] = cmp.mapping.confirm({ select = false, behavior = cmp.ConfirmBehavior.Insert }),
        ['<tab>'] = cmp.mapping(cmp.mapping.confirm({ select = true, behavior = cmp.ConfirmBehavior.Insert }),
            { 'i', 's',
                'c' }),
        ['<C-n>'] = next,
        ['<C-j>'] = next,
        ['<Down>'] = next,
        ['<C-p>'] = prev,
        ['<C-k>'] = prev,
        ['<Up>'] = prev,
    }),
    sources = {
        { name = 'copilot',                 group_index = 2 },
        { name = 'nvim_lsp',                group_index = 2 },
        { name = 'buffer',                  group_index = 2 },
        { name = 'nvim_lsp_signature_help', group_index = 2 },
    }
})

cmp.setup.cmdline(':', {
    enabled = false,
})

cmp.setup.filetype({ 'MW_FILES' }, {
    enabled = false
})

-- Otherwise, press <tab> inserts a literal ^[ character in the command
-- line.
vim.cmd [[autocmd CmdLineEnter * silent! cunmap <tab>]]
