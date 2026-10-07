-- Extra "tasks": run and watch build/test/run tasks (VS Code's Tasks). overseer.nvim
-- detects Makefile, npm scripts, cargo, just, VS Code tasks.json and more.
-- Tasks from tasks.json get the components below: output goes to the quickfix
-- list (parsed with 'errorformat') and is shown as diagnostics.
-- Keys: util/registry.lua.
return {
    {
        "stevearc/overseer.nvim",
        cmd = {
            "OverseerRun",
            "OverseerToggle",
            "OverseerOpen",
            "OverseerClose",
            "OverseerBuild",
            "OverseerQuickAction",
        },
        opts = {
            component_aliases = {
                default_vscode = {
                    "default",
                    { "on_output_quickfix", set_diagnostics = true },
                    "on_result_diagnostics",
                },
            },
        },
    },
}
