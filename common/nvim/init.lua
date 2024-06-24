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

vim.g.mapleader = ","
vim.g.maplocalleader = ","
vim.g.have_nerd_font = true

vim.wo.colorcolumn = "80"
vim.opt.autoindent = true
vim.opt.cursorline = true
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 4
vim.opt.tabstop = 4
vim.opt.expandtab = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.scrolloff = 9
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.showmode = false
vim.opt.clipboard = "unnamedplus"
vim.opt.breakindent = true
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 250
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
vim.opt.inccommand = "split"
-- disable a warning
vim.g.loaded_perl_provider = 0
-- Don't like SQL ft mode's use of Ctrl-C
vim.g.ftplugin_sql_omni_key = "<C-q>"

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

require("lazy").setup({
	{ import = "plugins" },

	"github/copilot.vim",
})

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Move to window to left" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Move to window below" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Move to window above" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Move to window to right" })
vim.keymap.set("n", "<F5>", "<cmd>make<cr>", { desc = "Make" })
vim.keymap.set("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix list" })
vim.keymap.set("n", "]q", "<cmd>cnext<cr>", { desc = "Next on quickfix list" })
vim.keymap.set("n", "[q", "<cmd>cprevious<cr>", { desc = "Previous on quickfix list" })
vim.keymap.set("n", "<leader>q", "vip:j<cr>:.!fmt -w 80<cr>", { desc = "Format paragraph" })
vim.keymap.set("n", "<leader><space>", "<cmd>nohlsearch<cr>", { desc = "Clear search" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search" })
vim.keymap.set("n", "<leader>cd", "<cmd>Copilot disable<cr>", { desc = "Disable Copilot" })
vim.keymap.set("n", "<leader>ce", "<cmd>Copilot enable<cr>", { desc = "Enable Copilot" })
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, { desc = "Show diagnostic error messages" })
vim.keymap.set("n", "<leader>Q", vim.diagnostic.setloclist, { desc = "Show diagnostic quickfix list" })
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
vim.keymap.set("n", "<left>", [[<cmd>echo "Use 'h'"<cr>]])
vim.keymap.set("n", "<right>", [[<cmd>echo "Use 'l'"<cr>]])
vim.keymap.set("n", "<up>", [[<cmd>echo "Use 'k'"<cr>]])
vim.keymap.set("n", "<down>", [[<cmd>echo "Use 'j'"<cr>]])

vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("paulsmith", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})
