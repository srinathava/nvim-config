local M = {}

local function curdir()
    return vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':p:h')
end

M.rootdir = function()
    local lspconfig = require('lspconfig')
    return lspconfig.util.root_pattern('.git')(curdir())
end

M.projdir = function()
    local lspconfig = require('lspconfig')
    return lspconfig.util.root_pattern('BUILD')(curdir())
end

local function getrelpath()
    local bufpath = vim.api.nvim_buf_get_name(0)
    local rootpath = M.rootdir()
    return string.sub(bufpath, string.len(rootpath) + 2)
end

M.copygithub = function()
    local relpath = getrelpath()
    local reponame = vim.fn.fnamemodify(M.rootdir(), ':p:h:t')
    local url = 'https://sourcegraph.robot.car/github.robot.car/cruise/' .. reponame .. '/-/blob/' ..
        relpath .. '?L' .. vim.fn.line('.')
    vim.fn.setreg('+', url)
end

return M
