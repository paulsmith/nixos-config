return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.opt.timeoutlen = 500
	end,
	config = function()
		require("which-key").setup()
	end,
}
