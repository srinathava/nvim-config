local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

return {
    cmd = {
        "clangd",
        "--header-insertion=never",
        "--completion-parse=auto",
        "-j=12",
        -- otherwise nvim lsp spams us with "multiple different
        -- offset_encoding_errors"
        "--offset-encoding=utf-16",
    },
    on_new_config = function(new_config, new_root_dir)
        local vscodeSettingsFile = new_root_dir .. '/.vscode/settings.json'
        if vim.fn.filereadable(vscodeSettingsFile) then
            local fp = assert(io.open(vscodeSettingsFile, "rb"))
            local content = fp:read("*all")
            fp:close()
            local json = require('json');
            local settings = json.decode(content)

            local clangd_path = settings['clangd.path']
            if clangd_path ~= nil then
                local clangd_args = settings['clangd.arguments']
                table.insert(clangd_args, 1, clangd_path)
                -- otherwise nvim lsp spams us with "multiple different
                -- offset_encoding_errors"
                table.insert(clangd_args, '--offset-encoding=utf-16')
                new_config.cmd = clangd_args
            end
        end
    end,
    filetypes = { "c", "cpp", "cuda", "objc", "objcpp" },
    root_markers = {"mw_anchor", "compile_commands.json", ".git"},
    capabilities = capabilities
}
