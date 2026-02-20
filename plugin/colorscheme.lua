local util = require('tokyonight.util')

-- comment to check color
require("tokyonight").setup({
    style = "storm",
    on_colors = function(colors)
        colors.comment = '#58b872'
    end,
    on_highlights = function(hl, colors)
        hl.LineNr = {
            fg = util.lighten(colors.fg_gutter, 0.6)
        }
        hl.CursorLineNr = {
            fg = util.lighten(colors.fg_gutter, 0.4),
            bold = true
        }
        hl.Comment = {
            fg = colors.comment,
            italic = true
        }
        -- DAP breakpoint signs
        hl.DapBreakpoint         = { fg = colors.red }
        hl.DapBreakpointCondition = { fg = colors.yellow }
        hl.DapLogPoint           = { fg = colors.blue }
        hl.DapStopped            = { fg = colors.green }
        hl.DapBreakpointRejected = { fg = colors.orange }
    end
})

vim.cmd[[colorscheme tokyonight]]
