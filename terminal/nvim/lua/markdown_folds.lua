local M = {}

local cache = {}

local function is_fence(line)
	return line:match("^%s*([`~])%1%1+")
end

local function atx_heading_level(line)
	local hashes = line:match("^%s*(#+)%s+%S")
	if not hashes then
		return nil
	end

	local level = #hashes
	if level > 6 then
		return nil
	end

	return level
end

local function setext_heading_level(lines, lnum)
	local line = lines[lnum]
	local next_line = lines[lnum + 1]

	if not line or not next_line or line:match("^%s*$") then
		return nil
	end

	if next_line:match("^%s*=+%s*$") then
		return 1
	end

	if next_line:match("^%s*-+%s*$") then
		return 2
	end

	return nil
end

local function build_levels(bufnr)
	local changedtick = vim.api.nvim_buf_get_changedtick(bufnr)
	local cached = cache[bufnr]
	if cached and cached.changedtick == changedtick then
		return cached.levels
	end

	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	local levels = {}
	local setext_underlines = {}
	local current_level = 0
	local in_fence = false
	local fence_char = nil

	for lnum, line in ipairs(lines) do
		local fence = is_fence(line)

		if fence then
			if not in_fence then
				in_fence = true
				fence_char = fence
			elseif fence == fence_char then
				in_fence = false
				fence_char = nil
			end

			levels[lnum] = current_level
		elseif in_fence then
			levels[lnum] = current_level
		elseif setext_underlines[lnum] then
			levels[lnum] = setext_underlines[lnum]
		else
			local heading_level = atx_heading_level(line) or setext_heading_level(lines, lnum)
			if heading_level then
				current_level = heading_level
				levels[lnum] = current_level

				if setext_heading_level(lines, lnum) then
					setext_underlines[lnum + 1] = current_level
				end
			else
				levels[lnum] = current_level
			end
		end
	end

	cache[bufnr] = {
		changedtick = changedtick,
		levels = levels,
	}

	return levels
end

function M.expr()
	local bufnr = vim.api.nvim_get_current_buf()
	local levels = build_levels(bufnr)
	return levels[vim.v.lnum] or 0
end

return M
