local opts = require('user.lsp.opts')

local servers = { "lua_ls", "clangd", "yamlls" }

require("mason").setup {}

require("mason-lspconfig").setup {
    ensure_installed = servers
}

for _, name in pairs(servers) do
    vim.lsp.config[name] = opts(name)
    vim.lsp.enable(name)
end
