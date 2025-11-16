local M = {}

---@class __MCCState
---@field last_index integer
---@field launch_file string
---@type __MCCState
local state = {
	last_index = -1,
	launch_file = "/tmp/launchcodes",
}

function M.reload()
	package.loaded["mcc"] = nil
	package.loaded["mcc.editor"] = nil
	package.loaded["mcc.parser"] = nil
	package.loaded["mcc.terminal"] = nil
	require("mcc").setup()
end

---Opens the MCC Launch Code editor
function M.editor()
	local editor = require("mcc.editor")
	editor.open(state.launch_file)
end

---Run the Launch Code at the specified index
---@param index integer
function M.run(index)
	local parser = require("mcc.parser")
	local code = parser.read_launch_code(state.launch_file, index)
	if code == nil then
		local msg = string.format("no launch code at index %d", index)
		vim.notify(msg, vim.log.levels.WARN)
		return
	end
	state.last_index = index
	local terminal = require("mcc.terminal")
	terminal.send(code .. "\n")
end

---Rerun the most recently ran launch code
function M.rerun()
	if state.last_index < 1 then
		M.run(1)
	else
		M.run(state.last_index)
	end
end

function M.setup()
	local terminal = require("mcc.terminal")
	local editor = require("mcc.editor")

	editor.on_enter(function()
		local lnum = vim.api.nvim_win_get_cursor(0)[1]
		vim.api.nvim_win_hide(vim.api.nvim_get_current_win())
		M.run(lnum)
	end)

	vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>")
	vim.keymap.set({ "n", "t" }, "<C-e>", terminal.toggle)

	vim.keymap.set({ "n", "t" }, "<C-m>e", M.editor)
	vim.keymap.set({ "n", "t" }, "<leader>r", M.reload)

	local function run_with(index)
		return function()
			M.run(index)
		end
	end
	vim.keymap.set({ "n", "t" }, "<C-m>1", run_with(1))
	vim.keymap.set({ "n", "t" }, "<C-m>2", run_with(2))
	vim.keymap.set({ "n", "t" }, "<C-m>3", run_with(3))
	vim.keymap.set({ "n", "t" }, "<C-m>4", run_with(4))
	vim.keymap.set({ "n", "t" }, "<C-m>5", run_with(5))
	vim.keymap.set({ "n", "t" }, "<C-m>r", M.rerun)

	print("setup!")
end

return M
