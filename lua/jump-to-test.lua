local M = {}

local function scan_dir(dir, search)
	local handle = vim.loop.fs_scandir(dir)
	if not handle then
		return nil
	end

	while true do
		local name, type = vim.loop.fs_scandir_next(handle)
		if not name then
			break
		end

		local full_path = dir .. "/" .. name
		if type == "file" and name == search then
			return full_path
		elseif type == "directory" then
			local result = scan_dir(full_path, search)
			if result then
				return result
			end
		end
	end
end

function M.jump_to_test()
	local root_dir = vim.fn.getcwd()

	local filepath = vim.api.nvim_buf_get_name(0)
	local file_ext = vim.fn.fnamemodify(filepath, ":e")
	local filename = vim.fn.fnamemodify(filepath, ":t")
	local test_filename = vim.fn.fnamemodify(filename, ":r") .. "Tests." .. file_ext

	local test_file_path = scan_dir(root_dir, test_filename)

	if not test_file_path then
		print("could not find test file: ", test_filename)
	end

	vim.cmd("edit " .. test_file_path)
end

function M.jump_to_source()
	local root_dir = vim.fn.getcwd()

	local filepath = vim.api.nvim_buf_get_name(0)
	local filename = vim.fn.fnamemodify(filepath, ":t")
	local source_filename = filename:gsub("Tests", "")

	local source_file_path = scan_dir(root_dir, source_filename)

	if not source_file_path then
		print("could not find source file: ", source_filename)
		return
	end

	vim.cmd("edit " .. source_file_path)
end

return M
