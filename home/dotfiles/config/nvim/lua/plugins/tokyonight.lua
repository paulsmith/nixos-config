return {
	"folke/tokyonight.nvim",
	lazy = false,
	priority = 1000,
	config = function()
		if vim.o.background == "dark" then
			vim.cmd([[colorscheme tokyonight-night]])
		else
			vim.cmd([[colorscheme tokyonight-storm]])
		end
	end,
}
