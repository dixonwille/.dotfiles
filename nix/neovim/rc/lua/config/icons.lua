local M = {}

M.status = {
	error = "",
	warn = "",
	info = "",
	hint = "",
}

M.mods = {
	added = "",
	modified = "󰜥",
	removed = "",
	readonly = "",
	unsaved = "",
	renamed = "",
}

M.git = {
	staged = "",
	unstaged = "",
	ignored = "",
	conflict = "",
	untracked = "",
}

M.misc = {
	clock = "",
}

vim.fn.sign_define("DiagnosticSignError", { text = M.status.error, texthl = "DiagnosticSignError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = M.status.warn, texthl = "DiagnosticSignWarn" })
vim.fn.sign_define("DiagnosticSignInfo", { text = M.status.info, texthl = "DiagnosticSignInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = M.status.hint, texthl = "DiagnosticSignHint" })

return M
