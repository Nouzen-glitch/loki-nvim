-- Extra "sessions": restore the files and splits of a folder. Never restores
-- by itself: use <leader>ss (this folder) or <leader>sl (last session).
return {
    {
        "folke/persistence.nvim",
        event = "BufReadPre",
        opts = {},
        config = function(_, opts)
            -- Headless runs (smoke test, cheatsheet watcher) must not write sessions.
            if #vim.api.nvim_list_uis() == 0 then
                return
            end
            -- No "terminal": toggleterm buffers do not restore well.
            vim.o.sessionoptions = "buffers,curdir,tabpages,winsize,skiprtp,folds"
            require("persistence").setup(opts)
            -- nvim-tree buffers do not restore either: close it before saving.
            vim.api.nvim_create_autocmd("User", {
                pattern = "PersistenceSavePre",
                callback = function()
                    if package.loaded["nvim-tree.api"] then
                        pcall(function()
                            require("nvim-tree.api").tree.close()
                        end)
                    end
                end,
            })
        end,
    },
}
