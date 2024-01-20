if vim.fn.executable("pwsh") == 0 then
	return {}
end

return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				powershell_es = {},
			},
		},
	},
}
