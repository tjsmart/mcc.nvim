local M = {}

---@class State
---@field buffer integer
---@field window integer

---@type State
local state = {
	buffer = -1,
	window = -1,
}

---@param buffer integer
---@return State
local function create_window(buffer)
	if not vim.api.nvim_buf_is_valid(buffer) then
		buffer = vim.api.nvim_create_buf(false, true)
	end

	local width = math.floor(vim.o.columns * 0.8)
	local height = math.floor(vim.o.lines * 0.8)
	local row = math.floor((vim.o.lines - height) / 2)
	local col = math.floor((vim.o.columns - width) / 2)

	---@type vim.api.keyset.win_config
	local opts = {
		relative = "editor",
		style = "minimal",
		border = "rounded",
		width = width,
		height = height,
		row = row,
		col = col,
		title = " mcc terminal ",
		title_pos = "center",
	}
	local window = vim.api.nvim_open_win(buffer, true, opts)
	return { buffer = buffer, window = window }
end

local function force_exit()
	if vim.api.nvim_win_is_valid(state.window) then
		vim.schedule(function()
			vim.api.nvim_buf_delete(state.buffer, { force = true })
		end)
	end
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
	vim.fn.chansend(job, text)
end

return M
