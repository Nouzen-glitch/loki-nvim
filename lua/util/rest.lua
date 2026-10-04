-- Minimal HTTP client for the "rest" extra. Runs the request block under the
-- cursor with curl and shows the response in a split.
--
--   ### optional title
--   POST https://example.com/api
--   Content-Type: application/json
--
--   {"name": "x"}
--
-- Blocks are separated by lines starting with ###. {{NAME}} is replaced by the
-- environment variable NAME, so tokens never live in the file.
local M = {}

local function block(lines, cur)
    local s, e = 1, #lines
    for i = cur, 1, -1 do
        if lines[i]:match("^###") then
            s = i + 1
            break
        end
    end
    for i = s, #lines do
        if lines[i]:match("^###") then
            e = i - 1
            break
        end
    end
    return vim.list_slice(lines, s, e)
end

function M.parse(lines)
    local i = 1
    while i <= #lines and (lines[i]:match("^%s*$") or lines[i]:match("^%s*#") or lines[i]:match("^%s*//")) do
        i = i + 1
    end
    local method, url = (lines[i] or ""):match("^%s*(%u+)%s+(%S+)")
    if not method then
        return nil, "No request found. Put the cursor in a block that starts with: METHOD URL"
    end
    i = i + 1
    local headers = {}
    while i <= #lines and lines[i]:match("^%s*[%w%-]+%s*:") do
        table.insert(headers, vim.trim(lines[i]))
        i = i + 1
    end
    while i <= #lines and lines[i]:match("^%s*$") do
        i = i + 1
    end
    local body = vim.trim(table.concat(vim.list_slice(lines, i, #lines), "\n"))

    local missing, used = {}, {}
    local function expand(text)
        return (text:gsub("{{%s*([%w_]+)%s*}}", function(name)
            local value = vim.env[name]
            if not value then
                table.insert(missing, name)
                return ""
            end
            if not vim.tbl_contains(used, name) then
                table.insert(used, name)
            end
            return value
        end))
    end
    url = expand(url)
    for n, h in ipairs(headers) do
        headers[n] = expand(h)
    end
    body = expand(body)
    if #missing > 0 then
        return nil, "Environment variable(s) not set: " .. table.concat(missing, ", ")
    end
    return { method = method, url = url, headers = headers, body = body ~= "" and body or nil, used = used }
end

function M.command(req)
    local cmd = { "curl", "-sS", "-i", "--max-time", "30", "-X", req.method }
    for _, h in ipairs(req.headers) do
        vim.list_extend(cmd, { "-H", h })
    end
    if req.body then
        vim.list_extend(cmd, { "--data-binary", "@-" })
    end
    table.insert(cmd, req.url)
    return cmd
end

local function show(text)
    local name = "Loki REST response"
    local buf = vim.fn.bufnr(name)
    if buf == -1 then
        buf = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].buftype = "nofile"
        vim.bo[buf].bufhidden = "wipe"
        vim.bo[buf].swapfile = false
        pcall(vim.api.nvim_buf_set_name, buf, name)
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, desc = "Close response" })
    end
    local win = vim.fn.bufwinid(buf)
    if win == -1 then
        vim.cmd("botright vsplit")
        win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(win, buf)
    end
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, vim.split((text:gsub("\r", "")), "\n"))
    vim.bo[buf].modified = false
end

function M.run()
    if vim.fn.executable("curl") ~= 1 then
        vim.notify("curl was not found in your PATH.", vim.log.levels.ERROR)
        return
    end
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local req, err = M.parse(block(lines, vim.api.nvim_win_get_cursor(0)[1]))
    if not req then
        vim.notify(err, vim.log.levels.WARN)
        return
    end
    -- A .http file from somewhere else could name any environment variable
    -- ({{AWS_SECRET_ACCESS_KEY}}), so say where they are about to be sent.
    if #req.used > 0 then
        local host = req.url:match("^%a+://[^/?#]+") or req.url
        local msg = string.format("Send this request to %s\nusing environment variable(s): %s?",
            host, table.concat(req.used, ", "))
        if vim.fn.confirm(msg, "&Send\n&Cancel", 2) ~= 1 then
            return
        end
    end
    vim.system(M.command(req), { text = true, stdin = req.body }, function(res)
        vim.schedule(function()
            if res.code ~= 0 then
                vim.notify("curl failed (" .. res.code .. "):\n" .. (res.stderr or ""), vim.log.levels.ERROR)
                return
            end
            show(res.stdout or "")
        end)
    end)
end

return M
