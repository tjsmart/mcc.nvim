local M = {}

local state = {
	---@integer
	last_index = -1,
}

function M.reload()
	package.loaded["mcc"] = nil
	package.loaded["mcc.editor"] = nil
	package.loaded["mcc.parser"] = nil
	package.loaded["mcc.terminal"] = nil
	require("mcc").setup()
end

---Run the launch code at the specified index
---@param index integer
function M.run(index)
	local parser = require("mcc.parser")
	local code = parser.read_launch_code("/tmp/launchcodes", index)
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
	-- local parser = require("mcc.parser")
	-- print(vim.inspect(parser.read_launch_code("/tmp/launchcodes", 2)))

	vim.keymap.set("n", "<leader>m", function()
		local editor = require("mcc.editor")
		editor.open("/tmp/launchcodes", { relwidth = 0.5, relheight = 0.3 })
	end)

	local terminal = require("mcc.terminal")
	local editor = require("mcc.editor")
	editor.on_enter(function()
		local code = vim.api.nvim_get_current_line()
		vim.api.nvim_win_hide(vim.api.nvim_get_current_win())
		terminal.send(code .. "\n")
	end)

	vim.keymap.set({ "n", "t" }, "<C-e>", terminal.toggle)
	vim.keymap.set({ "n", "t" }, "<C-s>", function()
		terminal.send("echo 'hello!'\n")
	end)
	vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>")

	vim.keymap.set({ "n", "t" }, "<leader>r", M.reload)

	vim.keymap.set({ "n", "t" }, "<C-m>1", function()
		M.run(1)
	end)
	vim.keymap.set({ "n", "t" }, "<C-m>2", function()
		M.run(2)
	end)
	vim.keymap.set({ "n", "t" }, "<C-m>3", function()
		M.run(3)
	end)
	vim.keymap.set({ "n", "t" }, "<C-m>r", function()
		M.rerun()
	end)

	print("setup!")
end

return M
