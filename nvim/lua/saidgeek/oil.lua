local M = {}

local zedAddCmd = function(path)
    return { "zed", "--add", path }
end

local zedOpenCmd = function(path)
    return { "zed", path }
end

local jid = function(cmd)
    local jid = vim.fn.jobstart(cmd, { detach = true })
    assert(jid > 0, "Failed to start job")
end

M.addInZed = {
    desc = "Open the entry under the cursor in to Zed Editor",
    callback = function(opts, callback)
        opts = opts or {}
        callback = callback or nil

        local oil = require("oil")
        local entry = oil.get_cursor_entry()
        local dir = oil.get_current_dir()

        if not entry or not dir then
            return
        end

        local path = dir .. entry.name

        if entry.type == "directory" then
            oil.select(opts, callback)
            return
        end

        jid(zedAddCmd(path))
        vim.cmd('q!')
    end,
}

M.addDirInZed = {
    desc = "Open the entry under the cursor in to Zed Editor",
    callback = function(opts, callback)
        opts = opts or {}
        callback = callback or nil

        local oil = require("oil")
        local entry = oil.get_cursor_entry()
        local dir = oil.get_current_dir()
        if not entry or not dir then
            return
        end

        if entry.type ~= "directory" then
            return
        end

        local path = dir .. entry.name

        jid(zedAddCmd(path))
        vim.cmd('q!')
    end,
}

M.openDirInNewZed = {
    desc = "Open r in new Zed Editor",
    callback = function(opts, callback)
        opts = opts or {}
        callback = callback or nil

        local oil = require("oil")
        local entry = oil.get_cursor_entry()
        local dir = oil.get_current_dir()

        if not entry or not dir then
            return
        end

        if entry.type ~= "directory" then
            return
        end

        local path = dir .. entry.name

        jid(zedOpenCmd(path))

        vim.cmd('q!')
    end,
}

M.closeOil = {
    desc = "Close Oil in zed",
    callback = function()
        vim.cmd('q!')
    end,
}

return M
