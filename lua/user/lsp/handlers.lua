local M = {}

M.setup = function()
    local config = {
        virtual_text = false,
        update_in_insert = true,
        underline = true,
        severity_sort = true,
        float = {
            focusable = false,
            style = "minimal",
            border = "rounded",
            source = "always",
            header = "",
            prefix = "",
        },
    }

    vim.diagnostic.config(config)

    vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "rounded",
    })

    vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "rounded",
    })
end

local lastline = -1
local function onCursorHold()
    local curline = vim.fn.getpos('.')[2]
    if curline ~= lastline then
        lastline = curline
        vim.diagnostic.open_float()
    end
end

local function lsp_highlight_document(client, bufnr)
    vim.o.updatetime = 500
    if client.server_capabilities.documentHighlightProvider then
        vim.api.nvim_exec2(
            [[
        augroup lsp_document_highlight
            autocmd! * <buffer>
            autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
            autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
        augroup END
        ]],
            { output = false }
        )
    end
    vim.api.nvim_create_autocmd({ "CursorHold" }, {
        buffer = bufnr,
        callback = onCursorHold
    })
end

local function lsp_keymaps(bufnr)
    local opts = { noremap = true, silent = true }
    local map = function(k, v)
        vim.api.nvim_buf_set_keymap(bufnr, "n", k, v, opts)
    end
    map("gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
    map("gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
    map("g?", "<cmd>lua vim.lsp.buf.hover()<CR>")
    map("gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
    map("<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
    map("gr", "<cmd>lua vim.lsp.buf.references()<CR>")
    map("gR", "<cmd>lua vim.lsp.buf.rename()<CR>")
    map("[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>')
    map("gl", '<cmd>lua vim.diagnostic.open_float({ border = "rounded" })<CR>')
    map("]d", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>')
    map("<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>")
end

M.on_attach = function(client, bufnr)
    -- use a custom clang-format
    if client.name == "tsserver" then
        client.server_capabilities.documentFormattingProvider = false
    end
    lsp_keymaps(bufnr)
    lsp_highlight_document(client, bufnr)

    local augroup = vim.api.nvim_create_augroup("LspFormatting", {})
    if client.supports_method("textDocument/formatting") then
        print('setting up formatting for ' .. client.name)
        vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format()
            end,
        })
    end

    vim.api.nvim_buf_set_option(0, 'formatexpr', 'v:lua.vim.lsp.formatexpr()')
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

local cmp_nvim_lsp = require("cmp_nvim_lsp")
M.capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

return M
