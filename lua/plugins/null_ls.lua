local function clangd_path(args)
    local bufnr = args.bufnr

    local retval = 'clang-format'
    local bufdir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ':p:h')
    local poppyfile = vim.fn.findfile('Poppyfile', bufdir .. ';')
    if poppyfile ~= '' then
        local cruiseroot = vim.fn.fnamemodify(poppyfile, ':p:h')
        retval = cruiseroot .. '/tools/clang-format'
    end

    print('setting clang-format path to ' .. retval)
    return retval
end

local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

return {
    "jose-elias-alvarez/null-ls.nvim",
    config = function()
        local null_ls = require('null-ls')
        null_ls.setup({
            sources = {
                null_ls.builtins.formatting.clang_format.with({
                    command = clangd_path
                })
            },
            on_attach = function(client, bufnr)
                if client.supports_method("textDocument/formatting") then
                    vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
                    vim.api.nvim_create_autocmd("BufWritePre", {
                        group = augroup,
                        buffer = bufnr,
                        callback = function()
                            vim.lsp.buf.format()
                        end,
                    })
                end
            end
        })
    end
}
