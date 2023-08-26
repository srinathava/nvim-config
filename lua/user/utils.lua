local M = {}
M.search_word = function()
    local searchterm = vim.fn.input("Search for: ", vim.fn.expand('<cword>'))
    vim.cmd('CtrlSF ' .. searchterm)
end

return M
