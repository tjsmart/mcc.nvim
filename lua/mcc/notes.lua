local M = {}

---@class __MCCNotesState
---@field window integer
---@type __MCCNotesState
local state = {
	window = -1,
}

---@return vim.api.keyset.win_config
local function window_opts()
	local width = math.floor(vim.o.columns * 1)
	local height = math.floor(vim.o.lines * 1)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)
	---@type vim.api.keyset.win_config
	return {
		relative = "editor",
		style = "minimal",
		width = width,
		height = height,
		row = row,
		col = col,
		border = { "", " ", "", "", "", "", "", "" },
		title = "MCC Notes",
		title_pos = "left",
	}
end

---@param window integer
local function resize_window(window)
	vim.api.nvim_win_set_config(window, window_opts())
end

---@param buffer integer
---@return integer window
local function create_window(buffer)
	local win = vim.api.nvim_open_win(buffer, true, window_opts())
	-- vim.wo[win].number = true
	return win
end

---@param filename string
function M.open(filename)
	local buf = vim.fn.bufadd(filename)
	vim.fn.bufload(buf)

	if not vim.api.nvim_win_is_valid(state.window) then
		state.window = create_window(buf)
		vim.bo[buf].filetype = "markdown"
		vim.api.nvim_create_autocmd("BufLeave", {
			buffer = buf,
			callback = function()
				if vim.api.nvim_win_is_valid(state.window) then
					vim.api.nvim_win_close(state.window, true)
				end
			end,
		})
	end
end

-- window resizing
vim.api.nvim_create_autocmd("VimResized", {
	callback = function()
		if vim.api.nvim_win_is_valid(state.window) then
			resize_window(state.window)
		end
	end,
})

return M
