return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = {
				"c",
				"css",
				"diff",
				"go",
				"html",
				"javascript",
				"markdown",
				"lua",
				"luadoc",
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
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<C-space>",
					node_incremental = "<C-space>",
					scope_incremental = false,
					node_decremental = "<bs>",
				},
			},
			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["af"] = { query = "@function.outer", desc = "Select outer function declaration" },
						["if"] = { query = "@function.inner", desc = "Select inner function declaration" },
					},
				},
				swap = {
					enable = true,
					swap_next = {
						["<leader>np"] = "@parameter.inner",
					},
					swap_previous = {
						["<leader>pp"] = "@parameter.inner",
					},
				},
			},
		})
	end,
}
