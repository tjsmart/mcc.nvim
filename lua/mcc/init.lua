local M = {}

local parser = require("mcc.parser")
local terminal = require("mcc.terminal")
local editor = require("mcc.editor")

---@class __MCCState
---@field launch_file string
---@type __MCCState
local state = {
	launch_file = "/tmp/launchcodes",
}

function M.reload()
	package.loaded["mcc"] = nil
	package.loaded["mcc.editor"] = nil
	package.loaded["mcc.parser"] = nil
	package.loaded["mcc.terminal"] = nil
	package.loaded["mcc.notes"] = nil
	require("mcc").setup()
end

---Opens the MCC Launch Code editor
function M.editor()
	editor.open(state.launch_file)
end

---Run the Launch Code at the specified index
---@param index integer
function M.run(index)
	local code = parser.read_launch_code(state.launch_file, index)
	if code == nil then
		local msg = string.format("no launch code at index %d", index)
		vim.notify(msg, vim.log.levels.WARN)
		return
	end
	terminal.send(code .. "\n")
end

---Rerun the most recently ran launch code
function M.rerun()
	terminal.resend()
end

function M.setup()
	editor.on_enter(function()
		local lnum = vim.api.nvim_win_get_cursor(0)[1]
		vim.api.nvim_win_hide(vim.api.nvim_get_current_win())
		M.run(lnum)
	end)
end

return M
