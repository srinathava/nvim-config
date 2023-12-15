local function python_adapter(cb, config)
    if config.request == 'attach' then
        ---@diagnostic disable-next-line: undefined-field
        local port = (config.connect or config).port
        ---@diagnostic disable-next-line: undefined-field
        local host = (config.connect or config).host or '127.0.0.1'
        cb({
            type = 'server',
            port = assert(port, '`connect.port` is required for a python `attach` configuration'),
            host = host,
            options = {
                source_filetype = 'python',
            },
        })
    else
        print("Only attach method supported")
    end
end

return {
    {
        'mfussenegger/nvim-dap',
        config = function()
            local dap = require("dap")
            dap.adapters.gdb = {
                type = "executable",
                command = "gdb",
                args = { "-i", "dap" }
            }
            dap.adapters.cppdbg = {
                id = 'cppdbg',
                type = 'executable',
                command = '/tmp/ms-vscode/extension/debugAdapters/bin/OpenDebugAD7',
            }
            dap.configurations.cpp = {
                {
                    name = "Launch",
                    type = "gdb",
                    request = "launch",
                    program = function()
                        return '/home/srinath.avadhanula/cruise/bazel-out/k8-fastbuild/bin/cruise/mla/ml_compiler/robocomp/robocomp-opt'
                    end,
                    args = {
                        "-convert-print-ops-to-annotations",
                        "--split-input-file",
                        "--canonicalize",
                        "/tmp/foo.mlir"
                    },
                    cwd = "${workspaceFolder}",
                },
            }

            dap.adapters.python = python_adapter

            dap.configurations.python = {
                {
                    name = "Python: Remote Attach",
                    type = "python",
                    request = "attach",
                    host = '127.0.0.1',
                    port = 5678,
                }
            }
        end,
        lazy = true,
    },
    {
        'rcarriga/nvim-dap-ui',
        dependencies = {
            'mfussenegger/nvim-dap'
        },
        lazy = true,
    }
}
