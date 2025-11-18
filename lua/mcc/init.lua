local M = {}

local editor = require("mcc.editor")
local fs = require("mcc.fs")
local notes = require("mcc.notes")
local parser = require("mcc.parser")

local state = {
	terminal = require("mcc.terminal").Terminal:new(),
	last_send_cmd = nil,
}

---@return string
local function launch_file()
	return fs.project_dir() .. "/" .. "codes"
end

---Opens the MCC Launch Code editor
function M.editor()
	editor.open(launch_file())
end

---Run the Launch Code at the specified index
---@param index integer
function M.run(index)
	local code = parser.read_launch_code(launch_file(), index)
	if code == nil then
		local msg = string.format("no launch code at index %d", index)
		vim.notify(msg, vim.log.levels.WARN)
		return
	end
	state.last_send_cmd = code .. "\n"
	state.terminal:send(state.last_send_cmd)
end

---Rerun the most recently ran launch code
function M.rerun()
	if state.last_send_cmd == nil then
		vim.notify("no previously ran command", vim.log.levels.WARN)
	else
		state.terminal:send(state.last_send_cmd)
	end
end

---@return string
local function notes_file()
	return fs.project_dir() .. "/" .. "notes"
end

---Opens project notes
function M.notes()
	notes.open(notes_file())
end

---Toggle the terminal
function M.terminal()
	state.terminal:toggle()
end

function M.setup()
	editor.on_enter(function()
		local lnum = vim.api.nvim_win_get_cursor(0)[1]
		vim.api.nvim_win_hide(vim.api.nvim_get_current_win())
		M.run(lnum)
	end)
end

return M
