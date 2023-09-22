local M = {}

function M.on_attach(client, buffer)
	local self = M.new(client, buffer)

	self:map("gd", "Telescope lsp_definitions", { desc = "[G]oto [D]efinition" })
	self:map("gD", vim.lsp.buf.declaration, { desc = "[G]oto [D]eclaration" })
	self:map("gi", "Telescope lsp_implementations", { desc = "[G]oto [I]mplementations" })
	self:map("gr", "Telescope lsp_references", { desc = "[G]et [R]eferences" })
	self:map("K", vim.lsp.buf.hover, { desc = "Hover" })
	self:map("gK", vim.lsp.buf.signature_help, { desc = "Signature Help", has = "signatureHelp" })
	self:map(
		"<leader>la",
		vim.lsp.buf.code_action,
		{ desc = "[L]sp [A]ction", mode = { "n", "v" }, has = "codeAction" }
	)
	self:map("<leader>ls", "Telescope lsp_document_symbols", { desc = "[L]sp document [S]ymbols" })
	self:map("<leader>lS", "Telescope lsp_workspace_symbols", { desc = "[L]sp workspace [S]ymbols" })
	self:map("<leader>lr", vim.lsp.buf.rename, { expr = true, desc = "[L]sp [R]ename", has = "rename" })
	self:map("<leader>ld", function()
		vim.diagnostic.open_float(nil, { focus = false })
	end, { desc = "[L]sp [D]iagnostics" })
	self:map("[d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
	self:map("]d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })

	local formatter = require("base.lsp.format")
	self:map("<leader>lf", formatter.format, { desc = "[L]sp [F]ormat Document", has = "documentFormatting" })
	self:map(
		"<leader>lf",
		formatter.format,
		{ desc = "[L]sp [F]ormat Range", mode = "v", has = "documentRangeFormatting" }
	)
	self:map("<leader>lF", formatter.toggle, { desc = "Toggle Auto Formatting" })
end

function M.new(client, buffer)
	return setmetatable({ client = client, buffer = buffer }, { __index = M })
end

function M:has(cap)
	return self.client.server_capabilities[cap .. "Provider"]
end
function M:map(lhs, rhs, opts)
	opts = opts or {}
	if opts.has and not self:has(opts.has) then
		return
	end
	vim.keymap.set(
		opts.mode or "n",
		lhs,
		type(rhs) == "string" and ("<cmd>%s<cr>"):format(rhs) or rhs,
		{ silent = true, buffer = self.buffer, expr = opts.expr, desc = opts.desc }
	)
end

return M
