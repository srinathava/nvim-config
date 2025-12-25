local opts = require('user.lsp.opts')

local servers = { "lua_ls", "clangd", "yamlls", "jedi_language_server" }

require("mason").setup {}

require("mason-lspconfig").setup {
    ensure_installed = servers
}

for _, name in pairs(servers) do
    vim.lsp.enable(name, opts(name))
end
