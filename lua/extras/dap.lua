-- Extra "dap": nvim-dap with nvim-dap-ui. Adapters are installed by Mason
-- (debugpy, codelldb, js-debug-adapter). To add or change an adapter or
-- configuration without editing this file, see docs/EXTRAS.md: listen for the
-- `User LokiDapSetup` event from lua/user/options.lua.
return {
    {
        "mfussenegger/nvim-dap",
        lazy = true,
        dependencies = { "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio" },
        config = function()
            local dap = require("dap")
            local dapui = require("dapui")
            dapui.setup()

            -- The UI follows the session: open on start, close on exit.
            dap.listeners.after.event_initialized["loki_dapui"] = function() dapui.open() end
            dap.listeners.before.event_terminated["loki_dapui"] = function() dapui.close() end
            dap.listeners.before.event_exited["loki_dapui"] = function() dapui.close() end

            local mason = vim.fn.stdpath("data") .. "/mason"
            local function exe(path, fallback)
                return vim.uv.fs_stat(path) and path or fallback
            end

            dap.adapters.python = {
                type = "executable",
                command = exe(mason .. "/packages/debugpy/venv/bin/python", "python3"),
                args = { "-m", "debugpy.adapter" },
            }
            dap.adapters.codelldb = {
                type = "server",
                port = "${port}",
                executable = { command = exe(mason .. "/bin/codelldb", "codelldb"), args = { "--port", "${port}" } },
            }
            dap.adapters["pwa-node"] = {
                type = "server",
                host = "localhost",
                port = "${port}",
                executable = { command = exe(mason .. "/bin/js-debug-adapter", "js-debug-adapter"), args = { "${port}" } },
            }

            dap.configurations.python = {
                {
                    type = "python",
                    request = "launch",
                    name = "Launch current file",
                    program = "${file}",
                    pythonPath = function()
                        local venv = vim.env.VIRTUAL_ENV
                        return venv and (venv .. "/bin/python") or "python3"
                    end,
                },
            }
            local native = {
                {
                    type = "codelldb",
                    request = "launch",
                    name = "Launch executable",
                    program = function()
                        return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntry = false,
                },
            }
            dap.configurations.c = native
            dap.configurations.cpp = native
            dap.configurations.rust = native
            local node = {
                {
                    type = "pwa-node",
                    request = "launch",
                    name = "Launch current file",
                    program = "${file}",
                    cwd = "${workspaceFolder}",
                },
            }
            dap.configurations.javascript = node
            dap.configurations.typescript = node

            vim.api.nvim_exec_autocmds("User", { pattern = "LokiDapSetup" })
        end,
    },

    {
        -- Install the debug adapters with the formatters and tools.
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "debugpy", "codelldb", "js-debug-adapter" })
        end,
    },
}
