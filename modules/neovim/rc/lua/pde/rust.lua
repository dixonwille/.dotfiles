if vim.fn.executable("cargo") == 0 then
	return {}
end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, { "ron", "rust", "toml" })
		end,
	},
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				rust_analyzer = {},
				taplo = {},
			},
		},
	},
	{
		"saecki/crates.nvim",
		event = { "BufRead Cargo.toml" },
		dependencies = { "nvim-lua/plenary.nvim" },
		opts = {
			null_ls = {
				enabled = true,
				name = "crates",
			},
		},
		config = function(_, opts)
			require("crates").setup(opts)
		end,
	},
	{
		"hrsh7th/nvim-cmp",
		dependencies = { "crates.nvim" },
		opts = function(_, opts)
			local cmp = require("cmp")
			opts.sources = cmp.config.sources(vim.list_extend(opts.sources, { { name = "crates" } }))
		end,
	},
}
