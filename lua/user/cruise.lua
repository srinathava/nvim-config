local M = {}

local lspconfig = require('lspconfig')

local function curdir()
    return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':p:h')
end

M.rootdir = function()
    return lspconfig.util.root_pattern('.git')(curdir())
end

M.projdir = function()
    return lspconfig.util.root_pattern('BUILD')(curdir())
end

return M
