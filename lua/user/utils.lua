local M = {}
M.get_search_term = function()
    local mode = vim.api.nvim_get_mode().mode
    if mode:match('^[vV]') then
        local _, ls, cs = unpack(vim.fn.getpos('v'))
        local _, le, ce = unpack(vim.fn.getpos('.'))
        local lines = vim.api.nvim_buf_get_text(0, ls - 1, cs - 1, le - 1, ce, {})
        return '"' .. table.concat(lines, "\n") .. '"'
    else
        return vim.fn.expand('<cword>')
    end
end

M.search_word = function()
    local searchterm = vim.fn.input("Search for: ", M.get_search_term())
    vim.cmd('CtrlSF ' .. searchterm)
end

return M
