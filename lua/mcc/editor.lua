local M = {}

local state = {
	---@type table<string, integer>
	windows = {},
	---@type function
	on_enter_cb = nil,
}

---@class ResizeOpts
---@field relwidth number
---@field relheight number

---@param opts ResizeOpts | nil
---@return vim.api.keyset.win_config
local function window_opts(opts)
	opts = opts or {}
	local width = math.floor(vim.o.columns * (opts.relwidth or 0.5))
	local height = math.floor(vim.o.lines * (opts.relheight or 0.3))
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
		border = "rounded",
		title = "MCC Editor",
		title_pos = "left",
	}
end

---@param window integer
---@param opts ResizeOpts
local function resize_window(window, opts)
	vim.api.nvim_win_set_config(window, window_opts(opts))
end

---@param buffer integer
---@return integer window
---@param opts ResizeOpts | nil
local function create_window(buffer, opts)
	local win = vim.api.nvim_open_win(buffer, true, window_opts(opts))
	vim.wo[win].number = true

	-- on enter
	vim.keymap.set("n", "<CR>", function()
		if state.on_enter_cb == nil then
			return
		end
		state.on_enter_cb()
	end, {
		buffer = buffer,
	})

	return win
end

-- function M.resize(filename, opts)
-- end

---@class OpenOpts: ResizeOpts

---@param filename string
---@param opts OpenOpts
function M.open(filename, opts)
	local buf = vim.fn.bufadd(filename)
	vim.fn.bufload(buf)

	local window = state.windows[filename]
	if window and vim.api.nvim_win_is_valid(window) then
		vim.api.nvim_set_current_win(window)
	else
		window = create_window(buf, opts)
		state.windows[filename] = window
	end
end

---When enter is pressed on a control code in the editor,
---call cb with the text of the control code.
---@param cb function
function M.on_enter(cb)
	state.on_enter_cb = cb
end

return M
