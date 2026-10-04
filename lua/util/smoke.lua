-- Headless smoke test (scripts/smoke-test.sh). Calls :cquit when anything fails,
-- so the shell script's exit status is reliable.
local M = {}

function M.run()
    local failures = {}
    local function check(name, fn)
        local ok, err = pcall(fn)
        if not ok then
            failures[#failures + 1] = name .. ": " .. tostring(err)
        end
    end

    check("startup errors", function()
        assert(vim.v.errmsg == "", "v:errmsg is set: " .. vim.v.errmsg)
    end)

    for _, m in ipairs({
        "util.keyguard", "util.guide", "util.welcome", "util.cheatsheet", "config.leader_groups",
        "util.extras", "util.registry", "util.helpdoc", "util.lsp", "util.languages", "loki.health",
    }) do
        check("require " .. m, function()
            assert(pcall(require, m), "failed to load " .. m)
        end)
    end

    local guide = require("util.guide")
    check("help_lines", function() assert(#guide.help_lines() > 0) end)
    check("tutor_lines", function() assert(#guide.tutor_lines() > 0) end)
    check("help topics", function()
        local registry = require("util.registry")
        for _, name in ipairs(registry.topic_order) do
            assert(#require("util.helpdoc").topic_lines(name) > 3, "empty topic " .. name)
        end
    end)
    check(":LokiHelp command", function()
        vim.cmd("LokiHelp keys")
        vim.cmd("close")
    end)
    check("LokiLsp report", function()
        assert(#require("util.lsp").report(0) > 5)
    end)
    check("language table", function()
        local problems = require("util.languages").problems()
        assert(#problems == 0, table.concat(problems, "; "))
    end)
    check("keys report", function()
        print("keys: " .. table.concat(require("util.keyguard").report_lines(), " | "))
    end)
    check("cheatsheet", function()
        print("cheatsheet: " .. require("util.cheatsheet").generate())
    end)

    if #failures > 0 then
        io.stderr:write("SMOKE TEST FAILED:\n  " .. table.concat(failures, "\n  ") .. "\n")
        vim.cmd("cquit 1")
    end
    print("smoke: ok")
end

return M
