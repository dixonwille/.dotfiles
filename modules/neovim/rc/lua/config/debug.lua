local M = {}

local Popup = require("nui.popup")
local event = require("nui.utils.autocmd").event
local defPopupOpts = {
	enter = true,
	focusable = true,
	border = {
		style = "rounded",
	},
	position = "50%",
	size = {
		width = "80%",
		height = "60%",
	},
	buf_options = {
		readonly = true,
		filetype = "lua",
	},
}

function M.display(val, opts)
	local popupOpts = vim.tbl_deep_extend("force", defPopupOpts, opts or {})
	local popup = Popup(popupOpts)

	local str = ""
	if type(val) == "table" then
		str = vim.inspect(val)
	elseif type(val) == "string" then
		str = val
	else
		return
	end

	local lines = {}
	local count = 0

	for l in str:gmatch("[^\r\n]+") do
		table.insert(lines, l)
		count = count + 1
	end
	popup:mount()

	popup:on(event.BufLeave, function()
		popup:unmount()
	end, { once = true })

	vim.api.nvim_buf_set_lines(popup.bufnr, 0, count, false, lines)
end
return M
