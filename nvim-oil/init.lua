-- Disable all default plugins to speed up startup
vim.g.loaded_gzip = 1
vim.g.loaded_zip = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tar = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_getscript = 1
vim.g.loaded_getscriptPlugin = 1
vim.g.loaded_vimball = 1
vim.g.loaded_vimballPlugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_logiPat = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1
vim.g.loaded_netrwFileHandlers = 1
vim.g.loaded_matchit = 1
vim.g.loaded_matchparen = 1
vim.g.loaded_sql_completion = 1
vim.g.loaded_syntax_completion = 1
vim.g.loaded_xmlformat = 1

-- Minimal settings
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "no"
vim.opt.laststatus = 0
vim.opt.cmdheight = 1
vim.opt.showmode = false
vim.opt.ruler = false
vim.opt.showcmd = false

-- Leader key
vim.g.mapleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- Setup only Oil.nvim and theme
require("lazy").setup({
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        config = function()
            vim.cmd.colorscheme("catppuccin-mocha")
        end,
    },
    {
        "stevearc/oil.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require("oil").setup({
                default_file_explorer = true,
                skip_confirm_for_simple_edits = true,

                keymaps = {
                    ["<CR>"] = {
                        function()
                            local oil = require("oil")
                            local entry = oil.get_cursor_entry()
                            local dir = oil.get_current_dir()

                            -- Only intercept files, let Oil handle directories normally
                            if entry and entry.type == "file" and dir and vim.g.oil_open_in_zed then
                                local file_path = dir .. entry.name
                                vim.fn.jobstart({ "zed", file_path }, { detach = true })
                                vim.cmd("qa!")
                            else
                                -- Use normal Oil behavior for directories and non-Zed contexts
                                require("oil.actions").select.callback()
                            end
                        end,
                    },
                    ["<C-s>"] = { "actions.select", opts = { vertical = true } },
                    ["<C-h>"] = { "actions.select", opts = { horizontal = true } },
                    ["<C-t>"] = { "actions.select", opts = { tab = true } },
                    ["<C-p>"] = "actions.preview",
                    ["<C-c>"] = "actions.close",
                    ["<C-r>"] = "actions.refresh",
                    ["-"] = "actions.parent",
                    ["_"] = "actions.open_cwd",
                    ["`"] = "actions.cd",
                    ["gs"] = "actions.change_sort",
                    ["gx"] = "actions.open_external",
                    ["g."] = "actions.toggle_hidden",
                    ["q"] = "actions.close",
                    ["<Esc>"] = "actions.close",
                },

                use_default_keymaps = false,

                view_options = {
                    show_hidden = true,
                    is_always_hidden = function(name)
                        return name == ".." or name == ".git"
                    end,
                    natural_order = true,
                    sort = {
                        { "type", "asc" },
                        { "name", "asc" },
                    },
                },
            })

            -- Global mappings
            vim.keymap.set("n", "-", "<CMD>Oil<CR>")
            vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>")
        end,
    },
    {
        "nvim-tree/nvim-web-devicons",
        config = function()
            require("nvim-web-devicons").setup({
                default = true,
            })
        end,
    },
}, {
    defaults = { lazy = false },
    install = { missing = true },
    checker = { enabled = false },
    change_detection = { enabled = false },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip", "matchit", "matchparen", "netrwPlugin",
                "tarPlugin", "tohtml", "tutor", "zipPlugin",
            },
        },
    },
})

-- Quick quit mapping
vim.keymap.set("n", "q", "<CMD>qa!<CR>")

-- Auto-open Oil if started with a directory
vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
        local args = vim.fn.argv()
        if #args == 1 and vim.fn.isdirectory(args[1]) == 1 then
            vim.defer_fn(function()
                require("oil").open(args[1])
            end, 10)
        elseif #args == 0 then
            vim.defer_fn(function()
                require("oil").open(".")
            end, 10)
        end
    end,
})
