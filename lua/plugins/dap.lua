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

            -- DAP sign definitions (colours come from the highlight groups set in colorscheme.lua)
            vim.fn.sign_define('DapBreakpoint',          { text = '●', texthl = 'DapBreakpoint',         linehl = '', numhl = '' })
            vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DapBreakpointCondition', linehl = '', numhl = '' })
            vim.fn.sign_define('DapLogPoint',            { text = '◉', texthl = 'DapLogPoint',            linehl = '', numhl = '' })
            vim.fn.sign_define('DapStopped',             { text = '▶', texthl = 'DapStopped',             linehl = 'DapStopped', numhl = '' })
            vim.fn.sign_define('DapBreakpointRejected',  { text = '○', texthl = 'DapBreakpointRejected',  linehl = '', numhl = '' })
        end,
        lazy = true,
    },
    {
        'mfussenegger/nvim-dap-python',
        ft = 'python',
        dependencies = {
            'mfussenegger/nvim-dap',
        },
        config = function()
            -- Use whatever python3 is on PATH so this works across machines.
            require('dap-python').setup(vim.fn.exepath('python3'))

            -- Additional configurations on top of the defaults provided by
            -- nvim-dap-python (launch current file, attach to a running process)
            local dap = require('dap')
            table.insert(dap.configurations.python, {
                name = 'Python: Remote Attach',
                type = 'python',
                request = 'attach',
                connect = {
                    host = '127.0.0.1',
                    port = 5678,
                },
                pathMappings = {
                    {
                        localRoot = '${workspaceFolder}',
                        remoteRoot = '.',
                    },
                },
            })
        end,
    },
    {
        'rcarriga/nvim-dap-ui',
        dependencies = {
            'mfussenegger/nvim-dap',
            'nvim-neotest/nvim-nio',
        },
        keys = {
            { '<space>du', function() require('dapui').toggle() end, desc = 'DAP: Toggle UI' },
        },
        config = function()
            local dapui = require('dapui')
            dapui.setup({
                layouts = {
                    {
                        elements = {
                            { id = 'scopes',      size = 0.40 },
                            { id = 'breakpoints', size = 0.20 },
                            { id = 'stacks',      size = 0.20 },
                            { id = 'watches',     size = 0.20 },
                        },
                        size = 40,
                        position = 'left',
                    },
                    {
                        elements = {
                            { id = 'repl',    size = 0.5 },
                            { id = 'console', size = 0.5 },
                        },
                        size = 10,
                        position = 'bottom',
                    },
                },
            })
            -- Auto-open/close the UI when a debug session starts/ends
            local dap = require('dap')
            dap.listeners.after.event_initialized['dapui_config'] = function()
                dapui.open()
                vim.cmd('stopinsert')
            end
            dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
            dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end
        end,
        lazy = true,
    },
}
