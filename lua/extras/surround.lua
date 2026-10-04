-- Extra "surround": mini.surround with the `gs` prefix (the default `s` prefix
-- would make the plain `s` key wait for a second key).
--   gsa{motion}{char}  add     gsd{char}  delete     gsr{old}{new}  replace
return {
    {
        "echasnovski/mini.surround",
        event = "VeryLazy",
        opts = {
            mappings = {
                add = "gsa",
                delete = "gsd",
                replace = "gsr",
                find = "gsf",
                find_left = "gsF",
                highlight = "gsh",
                update_n_lines = "gsn",
            },
        },
    },
}
