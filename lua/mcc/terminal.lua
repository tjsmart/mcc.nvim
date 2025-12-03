local M = {}

---@return vim.api.keyset.win_config
local function window_opts()
	local lines_available = vim.o.lines - vim.o.cmdheight
	local width = math.floor(vim.o.columns * 1)
	local height = math.floor(lines_available * 1)
	local row = math.floor((lines_available - height) / 2)
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

---@param window integer
local function resize_window(window)
	vim.api.nvim_win_set_config(window, window_opts())
end

---@param buffer integer
local function create_window(buffer)
	if not vim.api.nvim_buf_is_valid(buffer) then
		buffer = vim.api.nvim_create_buf(false, true)
	end

	local window = vim.api.nvim_open_win(buffer, true, window_opts())
	return { buffer = buffer, window = window }
end

---@class Terminal
---@field cmd string | nil
---@field win_conf vim.api.keyset.win_config | nil
---@field buffer integer
---@field window integer
Terminal = {}
Terminal.__index = Terminal

---@class __TerminalOpts
---@field cmd string | nil Command to execute when window is opened.
---@field win_conf vim.api.keyset.win_config | nil

---@param opts __TerminalOpts | nil
---@return Terminal
function Terminal:new(opts)
	vim.api.nvim_create_autocmd("VimResized", {
		callback = function()
			if vim.api.nvim_win_is_valid(self.window) then
				vim.schedule(function()
					resize_window(self.window)
				end)
			end
		end,
	})

	opts = opts or {}
	return setmetatable({
		cmd = opts.cmd,
		win_conf = opts.win_conf,
		window = -1,
		buffer = -1,
	}, self)
end

function Terminal:open()
	if not vim.api.nvim_win_is_valid(self.window) then
		local win = create_window(self.buffer)
		if self.win_conf ~= nil then
			vim.api.nvim_win_set_config(win.window, self.win_conf)
		end
		self.window = win.window
		self.buffer = win.buffer
	end

	if vim.bo[self.buffer].buftype ~= "terminal" then
		if self.cmd ~= nil then
			vim.cmd.terminal(self.cmd)
		else
			vim.cmd.terminal()
		end

		-- terminal won't automatically exit if there was
		-- an error, this will force it to exit
		vim.api.nvim_create_autocmd("TermClose", {
			buffer = self.buffer,
			callback = function()
				vim.schedule(function()
					vim.api.nvim_win_close(self.window, true)
					vim.api.nvim_buf_delete(self.buffer, { force = true })
				end)
			end,
		})

		vim.api.nvim_create_autocmd("WinLeave", {
			buffer = self.buffer,
			callback = function()
				vim.schedule(function()
					if vim.api.nvim_win_is_valid(self.window) then
						vim.api.nvim_win_close(self.window, true)
					end
				end)
			end,
		})

		vim.api.nvim_create_autocmd("BufEnter", {
			buffer = self.buffer,
			callback = function()
				vim.cmd.startinsert()
			end,
		})
	end

	vim.cmd.startinsert()
end

function Terminal:toggle()
	if not vim.api.nvim_win_is_valid(self.window) then
		self:open()
	else
		vim.api.nvim_win_hide(self.window)
	end
end

---@param text string
function Terminal:send(text)
	self:open()
	local job = vim.b[self.buffer].terminal_job_id
	vim.fn.chansend(job, text)
end

M.Terminal = Terminal

return M
