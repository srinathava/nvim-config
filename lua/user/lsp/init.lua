local lspconfig = require('lspconfig')
local opts = require('user.lsp.opts')

local servers = { "pyright", "lua_ls", "clangd", "emmet_ls", "tsserver", "rust_analyzer", "svelte", "yamlls" }

require("mason").setup {}

require("mason-lspconfig").setup {
    ensure_installed = servers
}

for _, name in pairs(servers) do
    lspconfig[name].setup(opts(name))
end
