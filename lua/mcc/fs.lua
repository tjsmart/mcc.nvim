local M = {}

local base_dir = vim.fn.stdpath("data") .. "/mcc"

---@param dir string
function M.ensure_dir_exists(dir)
	vim.fn.mkdir(dir, "p")
end

---Path to mcc's data directory
---@return string
function M.base_dir()
	M.ensure_dir_exists(base_dir)
	return base_dir
end

---Returns a project specific directory inside of
---mcc's data directory
---@return string
function M.project_dir()
	local cwd = vim.fn.getcwd()
	local hash = vim.fn.sha256(cwd):sub(1, 16)
	local dir = base_dir .. "/" .. hash
	M.ensure_dir_exists(dir)
	return dir
end

return M
