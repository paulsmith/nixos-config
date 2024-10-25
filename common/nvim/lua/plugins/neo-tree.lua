return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
		-- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
	},
	config = function()
		vim.keymap.set("n", "<leader>t", "<cmd>Neotree toggle<cr>", { desc = "Toggle Neotree" })
		require("neo-tree").setup({
			filesystem = {
				hijack_netrw_behavior = "open_current",
			},
			window = {
				width = 25,
			},
		})
	end,
}
