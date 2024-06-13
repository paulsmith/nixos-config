print("Hello, NeoVim!")

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

require("lazy").setup({
	{ "lewis6991/gitsigns.nvim", opts = {} },

	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.opt.timeoutlen = 500
		end,
		config = function()
			require("which-key").setup()
		end,
	},

	{
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
	},

	{
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
	},

	{
		"neovim/nvim-lspconfig",
		dependencies = {
			{ "j-hui/fidget.nvim", opts = {} },
			{ "folke/neodev.nvim", opts = {} },
		},
		config = function()
			local lspconfig = require("lspconfig")
			lspconfig.gopls.setup({})
			lspconfig.clangd.setup({})
			lspconfig.lua_ls.setup({
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						workspace = {
							checkThirdParty = false,
							library = {
								unpack(vim.api.nvim_get_runtime_file("", true)),
							},
						},
						completion = {
							callSnippet = "Replace",
						},
					},
				},
			})
			lspconfig.sourcekit.setup({})

			-- https://github.com/golang/tools/blob/master/gopls/doc/vim.md#imports
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = vim.api.nvim_create_augroup("paulsmith-lsp-bufwritepre", { clear = true }),
				pattern = "*.go",
				callback = function()
					local params = vim.lsp.util.make_range_params()
					params.context = { only = { "source.organizeImports" } }
					local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
					for cid, res in pairs(result or {}) do
						for _, r in pairs(res.result or {}) do
							if r.edit then
								local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
								vim.lsp.util.apply_workspace_edit(r.edit, enc)
							end
						end
					end
					vim.lsp.buf.format({ async = false })
				end,
			})

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("paulsmith-lsp-attach", { clear = true }),
				callback = function(_event)
					vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
					vim.keymap.set(
						"n",
						"gr",
						require("telescope.builtin").lsp_references,
						{ desc = "Go to references" }
					)
					vim.keymap.set("n", "K", vim.lsp.buf.hover, { desc = "Show hover" })
					vim.keymap.set(
						"n",
						"<leader>ds",
						require("telescope.builtin").lsp_document_symbols,
						{ desc = "Document symbols" }
					)
					vim.keymap.set(
						"n",
						"<leader>ws",
						require("telescope.builtin").lsp_dynamic_workspace_symbols,
						{ desc = "Workspace symbols" }
					)
					vim.keymap.set("n", "<F2>", vim.lsp.buf.rename, { desc = "Rename" })
					vim.keymap.set("n", "<F3>", vim.lsp.buf.code_action, { desc = "Code action" })
					vim.keymap.set("n", "<F4>", vim.lsp.buf.references, { desc = "Find references" })
					vim.keymap.set("i", "<C-k>", vim.lsp.buf.signature_help, { desc = "Show signature help" })

					-- local client = vim.lsp.get_client_by_id(event.data.client_id)
					-- if client and client.server_capabilities.documentHighlightProvider then
					-- 	local group = vim.api.nvim_create_augroup("paulsmith-lsp-highlight", { clear = false })
					--
					-- 	vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
					-- 		group = group,
					-- 		buffer = event.buffer,
					-- 		callback = vim.lsp.buf.document_highlight,
					-- 	})
					--
					-- 	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
					-- 		group = group,
					-- 		buffer = event.buffer,
					-- 		callback = vim.lsp.buf.clear_references,
					-- 	})
					--
					-- 	vim.api.nvim_create_autocmd("LspDetach", {
					-- 		group = vim.api.nvim_create_augroup("paulsmith-lsp-detach", { clear = true }),
					-- 		callback = function(event2)
					-- 			vim.lsp.buf.clear_references()
					-- 			vim.api.nvim_clear_autocmds({ group = "paulsmith-lsp-highlight", buffer = event2.buf })
					-- 		end,
					-- 	})
					-- end
				end,
			})

			local capabilities = vim.lsp.protocol.make_client_capabilities()
			capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())
		end,
	},

	{
		"nvim-telescope/telescope.nvim",
		tag = "0.1.6",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope-ui-select.nvim",
			{ "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
		},
		event = "VimEnter",
		config = function()
			require("telescope").setup({
				extensions = {
					["ui-select"] = {
						require("telescope.themes").get_dropdown(),
					},
				},
			})
			local builtin = require("telescope.builtin")
			vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files" })
			vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Grep files" })
			vim.keymap.set("n", "<leader>fb", function()
				builtin.buffers({
					sort_mru = true,
					ignore_current_buffer = true,
					show_all_buffers = false,
				})
			end, { desc = "List buffers" })
			vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "List help tags" })
			pcall(require("telescope").load_extension, "fzf")
			pcall(require("telescope").load_extension, "ui-select")
		end,
	},
	{
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
			})
		end,
	},

	"github/copilot.vim",

	{
		"stevearc/conform.nvim",
		lazy = false,
		keys = {
			{
				"<leader>f",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				mode = "",
				desc = "[F]ormat buffer",
			},
		},
		opts = {
			notify_on_error = false,
			format_on_save = function(bufnr)
				local disable_filetypes = { c = true, cpp = true }
				return {
					timeout_ms = 500,
					lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
				}
			end,
			formatters_by_ft = {
				lua = { "stylua" },
				javascript = { "prettierd" },
			},
		},
	},

	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{
				"L3MON4D3/LuaSnip",
				build = (function()
					return "make install_jsregexp"
				end)(),
				dependencies = {
					"rafamadriz/friendly-snippets",
					config = function()
						require("luasnip.loaders.from_vscode").lazy_load()
					end,
				},
			},
			"saadparwaiz1/cmp_luasnip",
			"hrsh7th/cmp-nvim-lsp",
			"hrsh7th/cmp-path",
			"hrsh7th/cmp-buffer",
		},
		config = function()
			local cmp = require("cmp")
			local luasnip = require("luasnip")
			luasnip.config.setup({})

			local s = luasnip.snippet
			local t = luasnip.text_node
			luasnip.add_snippets("lua", { s("hello", { t("print('hello, world')") }) })

			cmp.setup({
				snippet = {
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				mapping = cmp.mapping.preset.insert({
					["<C-p>"] = cmp.mapping.select_prev_item(),
					["<C-n>"] = cmp.mapping.select_next_item(),
					["<C-b>"] = cmp.mapping.scroll_docs(-4),
					["<C-f>"] = cmp.mapping.scroll_docs(4),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-e>"] = cmp.mapping.close(),
					["<C-y>"] = cmp.mapping.confirm({ select = true }),
					["<A-j>"] = cmp.mapping(function()
						if luasnip.expand_or_locally_jumpable() then
							luasnip.expand_or_jump()
						end
					end, { "i", "s" }),
					["<A-k>"] = cmp.mapping(function()
						if luasnip.locally_jumpable(-1) then
							luasnip.jump(-1)
						end
					end, { "i", "s" }),
				}),
				sources = {
					{ name = "nvim_lsp" },
					{ name = "luasnip" },
					{ name = "path" },
					{ name = "buffer" },
				},
			})
		end,
	},

	{
		"folke/todo-comments.nvim",
		event = "VimEnter",
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = { signs = false },
	},

	{
		"mbbill/undotree",
		config = function()
			vim.keymap.set("n", "<leader>u", ":UndotreeToggle<CR>")
		end,
	},

	{ import = "nursery-plugins" },
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
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Show diagnostic quickfix list" })

vim.api.nvim_create_autocmd("TextYankPost", {
	group = vim.api.nvim_create_augroup("paulsmith", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

local nursery = vim.fn.stdpath("config") .. "/lua/nursery.lua"
if vim.loop.fs_stat(nursery) then
	require("nursery")
end
