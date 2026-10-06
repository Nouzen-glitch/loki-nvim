-- Extra "dap": nvim-dap with nvim-dap-ui. Adapters are installed by Mason
-- (debugpy, codelldb, js-debug-adapter, delve). It also reads
-- .vscode/launch.json. To add or change an adapter or configuration without
-- editing this file, see docs/EXTRAS.md: listen for the `User LokiDapSetup`
-- event from lua/user/options.lua.
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

            local function ask(prompt)
                return vim.fn.input(prompt)
            end
            -- "--a 1 --b" -> { "--a", "1", "--b" }
            local function ask_args()
                return vim.split(ask("Arguments: "), "%s+", { trimempty = true })
            end

            -- Adapters ------------------------------------------------------
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
            dap.adapters.delve = {
                type = "server",
                port = "${port}",
                executable = { command = exe(mason .. "/bin/dlv", "dlv"), args = { "dap", "-l", "127.0.0.1:${port}" } },
            }

            -- Configurations ------------------------------------------------
            local function python_path()
                local venv = vim.env.VIRTUAL_ENV
                return venv and (venv .. "/bin/python") or "python3"
            end
            dap.configurations.python = {
                {
                    type = "python", request = "launch", name = "Launch current file",
                    program = "${file}", pythonPath = python_path,
                },
                {
                    type = "python", request = "launch", name = "Launch current file (with arguments)",
                    program = "${file}", args = ask_args, pythonPath = python_path,
                },
                {
                    type = "python", request = "attach", name = "Attach to debugpy (host:port)",
                    connect = function()
                        local hp = vim.split(vim.fn.input("host:port ", "127.0.0.1:5678"), ":", { plain = true })
                        return { host = hp[1], port = tonumber(hp[2]) or 5678 }
                    end,
                    pythonPath = python_path,
                },
            }

            local native = {
                {
                    type = "codelldb", request = "launch", name = "Launch executable",
                    program = function() return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file") end,
                    cwd = "${workspaceFolder}", stopOnEntry = false,
                },
                {
                    type = "codelldb", request = "launch", name = "Launch executable (with arguments)",
                    program = function() return vim.fn.input("Executable: ", vim.fn.getcwd() .. "/", "file") end,
                    args = ask_args, cwd = "${workspaceFolder}", stopOnEntry = false,
                    -- Edit the environment through lua/user/options.lua (LokiDapSetup) when needed.
                    env = {},
                },
            }
            dap.configurations.c = native
            dap.configurations.cpp = native
            dap.configurations.rust = native

            local node = {
                {
                    type = "pwa-node", request = "launch", name = "Launch current file",
                    program = "${file}", cwd = "${workspaceFolder}",
                },
                {
                    type = "pwa-node", request = "attach", name = "Attach to a Node process (port 9229)",
                    port = 9229, cwd = "${workspaceFolder}",
                },
            }
            dap.configurations.javascript = node
            dap.configurations.typescript = node

            dap.configurations.go = {
                { type = "delve", request = "launch", name = "Launch current file", program = "${file}" },
                { type = "delve", request = "launch", name = "Launch package", program = "${fileDirname}" },
                { type = "delve", request = "launch", mode = "test", name = "Debug tests in this package", program = "${fileDirname}" },
            }

            -- .vscode/launch.json ------------------------------------------
            -- Maps the "type" used in launch.json to Neovim filetypes.
            local types = {
                python = { "python" },
                debugpy = { "python" },
                codelldb = { "c", "cpp", "rust" },
                cppdbg = { "c", "cpp" },
                ["pwa-node"] = { "javascript", "typescript" },
                node = { "javascript", "typescript" },
                delve = { "go" },
                go = { "go" },
            }
            local function load_launch_json()
                local ok, vscode = pcall(require, "dap.ext.vscode")
                if not ok or vim.fn.filereadable(vim.fn.getcwd() .. "/.vscode/launch.json") ~= 1 then
                    return
                end
                local loaded, err = pcall(vscode.load_launchjs, nil, types)
                if not loaded then
                    vim.notify("launch.json could not be read:\n" .. tostring(err), vim.log.levels.WARN)
                end
            end
            load_launch_json()
            vim.api.nvim_create_autocmd("DirChanged", {
                group = vim.api.nvim_create_augroup("LokiDapLaunchJson", { clear = true }),
                callback = load_launch_json,
            })

            vim.api.nvim_exec_autocmds("User", { pattern = "LokiDapSetup" })
        end,
    },

    {
        -- Install the debug adapters with the formatters and tools.
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            vim.list_extend(opts.ensure_installed, { "debugpy", "codelldb", "js-debug-adapter", "delve" })
        end,
    },
}
