local M = {}

local function scan_dir(dir, results)
	local handle = vim.loop.fs_scandir(dir)
	if not handle then
		return
	end

	while true do
		local name, entry_type = vim.loop.fs_scandir_next(handle)
		if not name then
			break
		end

		local full_path = dir .. "/" .. name
		if entry_type == "file" then
			table.insert(results, full_path)
		elseif entry_type == "directory" then
			scan_dir(full_path, results)
		end
	end
end

local function find_files(root_dir, predicate)
	local files = {}
	scan_dir(root_dir, files)

	local matches = {}
	for _, path in ipairs(files) do
		if predicate(path) then
			table.insert(matches, path)
		end
	end

	table.sort(matches)
	return matches
end

local function is_test_file(filepath)
	local filename = vim.fn.fnamemodify(filepath, ":t")
	return filename:lower():find("test", 1, true) ~= nil
end

local function open_match(matches, message)
	if #matches == 0 then
		vim.notify(message, vim.log.levels.WARN)
		return
	end

	local function open_file(path)
		if path then
			vim.cmd("edit " .. vim.fn.fnameescape(path))
		end
	end

	if #matches == 1 then
		open_file(matches[1])
		return
	end

	vim.ui.select(matches, {
		prompt = "Select a file:",
		format_item = function(path)
			return vim.fn.fnamemodify(path, ":~:.")
		end,
	}, open_file)
end

function M.toggle()
	if is_test_file(vim.api.nvim_buf_get_name(0)) then
		M.jump_to_source()
		return
	end

	M.jump_to_test()
end

function M.jump_to_test()
	local root_dir = vim.fn.getcwd()
	local filepath = vim.api.nvim_buf_get_name(0)
	local filename = vim.fn.fnamemodify(filepath, ":t")
	local file_ext = vim.fn.fnamemodify(filepath, ":e")
	local source_name = vim.fn.fnamemodify(filename, ":r"):lower()
	if filepath == "" or source_name == "" then
		vim.notify("Cannot find tests for an unnamed buffer", vim.log.levels.WARN)
		return
	end

	local matches = find_files(root_dir, function(path)
		local candidate = vim.fn.fnamemodify(path, ":t")
		return vim.fn.fnamemodify(path, ":e") == file_ext
			and candidate:lower():find(source_name, 1, true) ~= nil
			and is_test_file(candidate)
	end)

	open_match(matches, "Could not find a test file for " .. filename)
end

function M.jump_to_source()
	local root_dir = vim.fn.getcwd()
	local filepath = vim.api.nvim_buf_get_name(0)
	local filename = vim.fn.fnamemodify(filepath, ":t")
	local file_ext = vim.fn.fnamemodify(filepath, ":e")
	local test_name = vim.fn.fnamemodify(filename, ":r"):lower():gsub("test", ""):gsub("[^%w]", "")
	if filepath == "" or test_name == "" then
		vim.notify("Cannot find a source file for " .. filename, vim.log.levels.WARN)
		return
	end

	local matches = find_files(root_dir, function(path)
		local candidate = vim.fn.fnamemodify(path, ":t")
		local candidate_name = vim.fn.fnamemodify(candidate, ":r"):lower():gsub("[^%w]", "")
		return vim.fn.fnamemodify(path, ":e") == file_ext
			and not is_test_file(candidate)
			and candidate_name ~= ""
			and (candidate_name:find(test_name, 1, true) ~= nil or test_name:find(candidate_name, 1, true) ~= nil)
	end)

	open_match(matches, "Could not find a source file for " .. filename)
end

return M
