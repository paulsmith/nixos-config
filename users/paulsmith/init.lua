print('Hello, NeoVim!')

-- change_background updates the light/dark mode based on the system-wide
-- setting (macOS's Appearance system setting)
local function change_background()
	local m = vim.fn.system("defaults read -g AppleInterfaceStyle")
	m = m:gsub("%s+", "")
	if m == "Dark" then
		vim.o.background = "dark"
	else
		vim.o.background = "light"
	end
end

change_background()

vim.g.mapleader = ','

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

vim.wo.colorcolumn = '80'
vim.opt.autoindent = true
vim.opt.cursorline = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 9
-- disable a warning
vim.g.loaded_perl_provider = 0
-- Don't like SQL ft mode's use of Ctrl-C
vim.g.ftplugin_sql_omni_key = '<C-q>'

require("lazy").setup({
    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 1000,
        config = function()
            if vim.o.background == "dark" then
                vim.cmd[[colorscheme tokyonight-night]]
            else
                vim.cmd[[colorscheme tokyonight]]
            end
        end
    },
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            local configs = require("nvim-treesitter.configs")
            configs.setup({
                ensure_installed = {
                    "c",
                    "css",
                    "go",
                    "html",
                    "javascript",
                    "lua",
                    "nix",
                    "rust",
                    "sql",
                    "vim",
                    "vimdoc",
                    "zig",
                },
                sync_install = false,
                highlight = { enable = true },
                indent = { enable = true },
            })
        end
    },
    {
        "neovim/nvim-lspconfig",
        config = function()
            require('lspconfig').gopls.setup{}
            require('lspconfig').clangd.setup{}
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, {})
            vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, {})
            vim.keymap.set('n', '<F3>', vim.lsp.buf.code_action, {})
            vim.keymap.set('n', '<F4>', vim.lsp.buf.references, {})
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, {})
            vim.keymap.set('n', 'gK', vim.lsp.buf.signature_help, {})
        end
    },
    {
        "nvim-telescope/telescope.nvim",
        tag = "0.1.6",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local builtin = require("telescope.builtin")
            vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
            vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
            vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
            vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
        end
    },
    {
        -- Extensible UI for Neovim notifications and LSP progress messages
        "j-hui/fidget.nvim",
        opts = {},
    },
    {
        "preservim/nerdtree",
        config = function()
            vim.keymap.set('n', '<leader>t', "<cmd>NERDTreeToggle<cr>", { desc = "Toggle NERDTree" })
        end
    },
    "fatih/vim-go",
    "github/copilot.vim",
})

vim.keymap.set('n', '<C-h>', "<C-w>h", { desc = "Move to window to left" })
vim.keymap.set('n', '<C-j>', "<C-w>j", { desc = "Move to window below" })
vim.keymap.set('n', '<C-k>', "<C-w>k", { desc = "Move to window above" })
vim.keymap.set('n', '<C-l>', "<C-w>l", { desc = "Move to window to right" })
vim.keymap.set('n', '<F5>', "<cmd>make<cr>", { desc = "Make" })
vim.keymap.set('n', '<leader>xq', "<cmd>copen<cr>", { desc = "Quickfix list" })
vim.keymap.set('n', ']q', "<cmd>cnext<cr>", { desc = "Next on quickfix list" })
vim.keymap.set('n', '[q', "<cmd>cprevious<cr>", { desc = "Previous on quickfix list" })
vim.keymap.set('n', '<leader>q', "vip:j<cr>:.!fmt -w 80<cr>", { desc = "Format paragraph" })
