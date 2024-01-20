if vim.fn.executable("nix") == 0 then
	return {}
end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, { "nix" })
		end,
	},
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				-- nil_ls = {},
			},
		},
	},
}
