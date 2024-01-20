if vim.fn.executable("npm") == 0 then
	return {}
end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, { "vue" })
		end,
	},
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				volar = {},
			},
			setup = {
				volar = function()
					local lsp_utils = require("base.lsp.utils")
					lsp_utils.on_attach(function(_, buffer)
						local tsserver = vim.lsp.get_active_clients({ bufnr = buffer, name = "tsserver" })[1]
						local volar = vim.lsp.get_active_clients({ bufnr = buffer, name = "volar" })[1]
						if volar and tsserver then
							tsserver.stop()
						end
					end)
				end,
			},
		},
	},
}
