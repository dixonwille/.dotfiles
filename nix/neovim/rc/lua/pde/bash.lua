return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, { "bash" })
		end,
	},
	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, { "shellharden", "beautysh" })
		end,
	},
	"neovim/nvim-lspconfig",
	opts = {
		servers = {
			bashls = {},
		},
	},
	{
		"jose-elias-alvarez/null-ls.nvim",
		opts = function(_, opts)
			if type(opts.sources) == "table" then
				local nls = require("null-ls")
				vim.list_extend(opts.sources, {
					nls.builtins.formatting.shellharden,
					nls.builtins.formatting.beautysh,
				})
			end
		end,
	},
}
