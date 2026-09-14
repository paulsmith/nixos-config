local function pas_numeronym()
	local line = vim.api.nvim_get_current_line()
	local col = vim.api.nvim_win_get_cursor(0)[2]
	print("line = " .. line .. " col = " .. col)

	-- Find the start of the last word
	local word_start = line:sub(1, col):match(".*%s()")
	if not word_start then
		word_start = 1
	end

	-- Extract the last word
	local word = line:sub(word_start):match("%w+")
	if not word then
		return
	end

	local word_length = #word
	if word_length >= 4 then
		local numeronym = string.format("%s%d%s", word:sub(1, 1), word_length - 2, word:sub(-1))

		-- Replace the word with its numeronym
		local new_line = line:sub(1, word_start - 1) .. numeronym .. line:sub(word_start + word_length)
		vim.api.nvim_set_current_line(new_line)
	end
end

local numeronym_mode_active = false

local function toggle_numeronym_mode()
	numeronym_mode_active = not numeronym_mode_active
	if numeronym_mode_active then
		print("Numeronym mode activated")
		vim.api.nvim_create_autocmd("InsertCharPre", {
			pattern = "*",
			callback = function()
				local char = vim.v.char
				if char:match("[ .,:;?!]") then
					vim.schedule(function()
						pas_numeronym()
					end)
				end
			end,
		})
	else
		print("Numeronym mode deactivated")
		vim.api.nvim_clear_autocmds({ event = "InsertCharPre" })
	end
end

-- Create a user command to toggle numeronym mode
vim.api.nvim_create_user_command("NumeronymMode", toggle_numeronym_mode, {})

-- Optionally, you can map a key to toggle numeronym mode, e.g.:
vim.api.nvim_set_keymap("n", "<leader>n", ":NumeronymMode<CR>", { noremap = true, silent = true })
