local lspconfig = require('lspconfig')
local opts = require('user.lsp.opts')

local servers = { "lua_ls", "clangd", "emmet_ls", "ts_ls", "rust_analyzer", "svelte", "yamlls",
    "jedi_language_server" }

require("mason").setup {}

require("mason-lspconfig").setup {
    ensure_installed = servers
}

for _, name in pairs(servers) do
    lspconfig[name].setup(opts(name))
end

local lsp_server_path = vim.fn.getenv('MLIR_LSP_SERVER_PATH')
if lsp_server_path ~= vim.NIL and vim.fn.executable(lsp_server_path) == 1 then
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    lspconfig.mlir_lsp_server.setup {
        cmd = { lsp_server_path },
        filetypes = { "mlir" },
        root_dir = lspconfig.util.root_pattern(".git"),
        capabilities = capabilities,
    }
end
