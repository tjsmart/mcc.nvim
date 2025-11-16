local M = {}

---@param filename string
---@return boolean
local function file_exists(filename)
	local f = io.open(filename, "rb")
	if f then
		f:close()
	end
	return f ~= nil
end

---@param filename string
---@return string[]
local function readlines(filename)
	local lines = {} ---@type string[]
	if file_exists(filename) then
		for line in io.lines(filename) do
			table.insert(lines, line)
		end
	end
	return lines
end

---@param filename string
---@return string[]
function M.read_launch_codes(filename)
	return readlines(filename)
end

---@param filename string
---@param index integer
---@return string | nil
function M.read_launch_code(filename, index)
	for i, code in ipairs(M.read_launch_codes(filename)) do
		if i == index then
			return code
		end
	end
	return nil
end

return M
