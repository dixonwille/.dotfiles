if vim.fn.executable("npm") == 0 then
	return {}
end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, { "astro" })
		end,
	},
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				astro = {},
			},
		},
	},
}
