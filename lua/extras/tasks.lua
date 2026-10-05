-- Extra "tasks": run and watch build/test/run tasks (VS Code's Tasks). overseer.nvim
-- detects Makefile, npm scripts, cargo, just, VS Code tasks.json and more.
-- Keys: util/registry.lua.
return {
    {
        "stevearc/overseer.nvim",
        cmd = { "OverseerRun", "OverseerToggle", "OverseerOpen", "OverseerClose", "OverseerBuild", "OverseerQuickAction" },
        opts = {},
    },
}
