local M = {}

---@class __TerminalState
---@field buffer integer
---@field window integer
---@field last_send string
---@type __TerminalState
local state = {
	buffer = -1,
	window = -1,
	last_send = "",
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
		border = "none",
		width = width,
		height = height,
		row = row,
		col = col,
	}
end

local function force_exit()
	if vim.api.nvim_win_is_valid(state.window) then
		vim.schedule(function()
			vim.api.nvim_buf_delete(state.buffer, { force = true })
		end)
	end
end

---@param window integer
local function resize_window(window)
	vim.api.nvim_win_set_config(window, window_opts())
end

---@param buffer integer
---@return TerminalState
local function create_window(buffer)
	if not vim.api.nvim_buf_is_valid(buffer) then
		buffer = vim.api.nvim_create_buf(false, true)
	end

	local window = vim.api.nvim_open_win(buffer, true, window_opts())
	return { buffer = buffer, window = window }
end

--- Opens the terminal, if it is not already open
function M.open()
	if not vim.api.nvim_win_is_valid(state.window) then
		state = create_window(state.buffer)
	end

	if vim.bo[state.buffer].buftype ~= "terminal" then
		vim.cmd.terminal()

		-- terminal won't automatically exit if there was
		-- an error, this will force it to exit
		vim.api.nvim_create_autocmd("TermClose", {
			buffer = state.buffer,
			callback = force_exit,
		})
	end

	vim.cmd.startinsert()
end

--- Toggles the terminal open/close
function M.toggle()
	if not vim.api.nvim_win_is_valid(state.window) then
		M.open()
	else
		vim.api.nvim_win_hide(state.window)
	end
end

--- Sends text to the terminal
--- @param text string
function M.send(text)
	M.open()
	local job = vim.b[state.buffer].terminal_job_id
	state.last_send = text
	vim.fn.chansend(job, text)
end

---@param default string | nil
function M.resend(default)
	local text = state.last_send or default
	if text == nil then
		vim.notify("nothing sent yet and no default provided", vim.log.levels.WARN)
	else
		M.send(text)
	end
end

-- handle window resizing
vim.api.nvim_create_autocmd("VimResized", {
	callback = function()
		if vim.api.nvim_win_is_valid(state.window) then
			vim.schedule(function()
				resize_window(state.window)
			end)
		end
	end,
})

return M
