local notes_path = (os.getenv("HOME") or "") .. "/git/notes/vault"

local function open_latest_note()
	local files = vim.fn.globpath(notes_path, "*.md", false, true)
	if vim.tbl_isempty(files) then
		vim.notify("No notes found", vim.log.levels.WARN)
		return
	end

	table.sort(files, function(a, b)
		return vim.fn.getftime(a) > vim.fn.getftime(b)
	end)
	vim.cmd.edit(vim.fn.fnameescape(files[1]))
end

return {
	"joekleinsorge/notes.nvim",
	dependencies = { "nvim-telescope/telescope.nvim" },
	keys = {
		{
			"<leader>nn",
			function()
				require("notes").new_note()
			end,
			desc = "Notes: new",
		},
		{ "<leader>nl", open_latest_note, desc = "Notes: last" },
		{
			"<leader>nf",
			function()
				require("notes").find_note()
			end,
			desc = "Notes: find",
		},
		{
			"<leader>ns",
			function()
				require("notes").search_notes()
			end,
			desc = "Notes: search",
		},
	},
}
