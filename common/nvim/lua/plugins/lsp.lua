return {
	"neovim/nvim-lspconfig",
	dependencies = {
		{ "j-hui/fidget.nvim", opts = {} },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		local servers = {
			clangd = true,
			gopls = true,
			lua_ls = {
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
			},
			sourcekit = true,
			zls = true,
		}

		local capabilities = vim.lsp.protocol.make_client_capabilities()
		capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

		local lspconfig = require("lspconfig")

		for name, config in pairs(servers) do
			if config == true then
				config = {}
			end
			config = vim.tbl_deep_extend("force", {}, {
				capabilities = capabilities,
			}, config)
			lspconfig[name].setup(config)
		end

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
			callback = function()
				vim.keymap.set("n", "gd", vim.lsp.buf.definition, { desc = "Go to definition" })
				vim.keymap.set("n", "gr", require("telescope.builtin").lsp_references, { desc = "Go to references" })
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
	end,
}
