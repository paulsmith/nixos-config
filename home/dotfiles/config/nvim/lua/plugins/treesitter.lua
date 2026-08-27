local languages = {
	"bash",
	"c",
	"css",
	"diff",
	"dockerfile",
	"fennel",
	"forth",
	"git_config",
	"gitcommit",
	"gitignore",
	"go",
	"gomod",
	"gowork",
	"html",
	"java",
	"javascript",
	"jinja",
	"jq",
	"json",
	"llvm",
	"lua",
	"luadoc",
	"make",
	"markdown",
	"markdown_inline",
	"nginx",
	"ninja",
	"nix",
	"ocaml",
	"odin",
	"pascal",
	"perl",
	"php",
	"python",
	"racket",
	"rust",
	"sql",
	"ssh_config",
	"superhtml",
	"svelte",
	"tcl",
	"templ",
	"toml",
	"tsx",
	"typescript",
	"typst",
	"vim",
	"vimdoc",
	"xml",
	"yaml",
	"zig",
}

local filetypes = vim.list_extend(vim.deepcopy(languages), {
	"javascriptreact",
	"typescriptreact",
})

local textobject_select = {
	["a="] = { query = "@assignment.outer", desc = "Select outer part of an assignment" },
	["i="] = { query = "@assignment.inner", desc = "Select inner part of an assignment" },
	["l="] = { query = "@assignment.lhs", desc = "Select left-hand side of an assignment" },
	["r="] = { query = "@assignment.rhs", desc = "Select right-hand side of an assignment" },
	["aa"] = { query = "@parameter.outer", desc = "Select outer part of a parameter/argument" },
	["ia"] = { query = "@parameter.inner", desc = "Select inner part of a parameter/argument" },
	["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
	["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },
	["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
	["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },
	["am"] = { query = "@function.outer", desc = "Select outer part of a function/method declaration" },
	["im"] = { query = "@function.inner", desc = "Select inner part of a function/method declaration" },
	["af"] = { query = "@call.outer", desc = "Select outer part of a function call" },
	["if"] = { query = "@call.inner", desc = "Select inner part of a function call" },
	["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
	["ic"] = { query = "@class.inner", desc = "Select inner part of a class" },
}

local textobject_moves = {
	next_start = {
		["]f"] = { query = "@call.outer", desc = "Next functional call start" },
		["]m"] = { query = "@function.outer", desc = "Next function/method declaration start" },
		["]c"] = { query = "@class.outer", desc = "Next class declaration start" },
		["]i"] = { query = "@conditional.outer", desc = "Next conditional start" },
		["]l"] = { query = "@loop.outer", desc = "Next loop start" },
		["]s"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
	},
	next_end = {
		["]F"] = { query = "@call.outer", desc = "Next functional call end" },
		["]M"] = { query = "@function.outer", desc = "Next function/method declaration end" },
		["]C"] = { query = "@class.outer", desc = "Next class declaration end" },
		["]I"] = { query = "@conditional.outer", desc = "Next conditional end" },
		["]L"] = { query = "@loop.outer", desc = "Next loop end" },
	},
	previous_start = {
		["[f"] = { query = "@call.outer", desc = "Previous functional call start" },
		["[m"] = { query = "@function.outer", desc = "Previous function/method declaration start" },
		["[c"] = { query = "@class.outer", desc = "Previous class declaration start" },
		["[i"] = { query = "@conditional.outer", desc = "Previous conditional start" },
		["[l"] = { query = "@loop.outer", desc = "Previous loop start" },
	},
	previous_end = {
		["[F"] = { query = "@call.outer", desc = "Previous functional call end" },
		["[M"] = { query = "@function.outer", desc = "Previous function/method declaration end" },
		["[C"] = { query = "@class.outer", desc = "Previous class declaration end" },
		["[I"] = { query = "@conditional.outer", desc = "Previous conditional end" },
		["[L"] = { query = "@loop.outer", desc = "Previous loop end" },
	},
}

return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	lazy = false,
	build = ":TSUpdate",
	dependencies = {
		{
			"nvim-treesitter/nvim-treesitter-textobjects",
			branch = "main",
		},
	},
	config = function()
		local treesitter = require("nvim-treesitter")

		treesitter.setup({
			install_dir = vim.fn.stdpath("data") .. "/site",
		})
		treesitter.install(languages)

		vim.api.nvim_create_autocmd("FileType", {
			pattern = filetypes,
			callback = function()
				vim.treesitter.start()
				vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
			end,
		})

		require("nvim-treesitter-textobjects").setup({
			select = {
				lookahead = true,
			},
			move = {
				set_jumps = true,
			},
		})

		local select = require("nvim-treesitter-textobjects.select")
		for lhs, spec in pairs(textobject_select) do
			vim.keymap.set({ "x", "o" }, lhs, function()
				select.select_textobject(spec.query, "textobjects")
			end, { desc = spec.desc })
		end

		local swap = require("nvim-treesitter-textobjects.swap")
		vim.keymap.set("n", "<leader>na", function()
			swap.swap_next("@parameter.inner")
		end, { desc = "Swap with next parameter" })
		vim.keymap.set("n", "<leader>pa", function()
			swap.swap_previous("@parameter.inner")
		end, { desc = "Swap with previous parameter" })

		local move = require("nvim-treesitter-textobjects.move")
		for lhs, spec in pairs(textobject_moves.next_start) do
			vim.keymap.set({ "n", "x", "o" }, lhs, function()
				move.goto_next_start(spec.query, spec.query_group or "textobjects")
			end, { desc = spec.desc })
		end
		for lhs, spec in pairs(textobject_moves.next_end) do
			vim.keymap.set({ "n", "x", "o" }, lhs, function()
				move.goto_next_end(spec.query, spec.query_group or "textobjects")
			end, { desc = spec.desc })
		end
		for lhs, spec in pairs(textobject_moves.previous_start) do
			vim.keymap.set({ "n", "x", "o" }, lhs, function()
				move.goto_previous_start(spec.query, spec.query_group or "textobjects")
			end, { desc = spec.desc })
		end
		for lhs, spec in pairs(textobject_moves.previous_end) do
			vim.keymap.set({ "n", "x", "o" }, lhs, function()
				move.goto_previous_end(spec.query, spec.query_group or "textobjects")
			end, { desc = spec.desc })
		end

		local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
		vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
		vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)
		vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
		vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
		vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
		vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
	end,
}
