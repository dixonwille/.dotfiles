if vim.fn.executable("go") == 0 then
	return {}
end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, { "go", "gomod", "gowork", "gosum" })
		end,
	},
	{
		"jose-elias-alvarez/null-ls.nvim",
		opts = function(_, opts)
			if type(opts.sources) == "table" then
				local nls = require("null-ls")
				vim.list_extend(opts.sources, {
					nls.builtins.code_actions.gomodifytags,
					nls.builtins.code_actions.impl,
					nls.builtins.formatting.gofumpt,
					nls.builtins.formatting.goimports_reviser,
				})
			end
		end,
	},
	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, {
				"delve",
				"gotests",
				"golangci-lint",
				"gofumpt",
				"goimports",
				"golangci-lint-langserver",
				"impl",
				"gomodifytags",
				"iferr",
				"gotestsum",
			})
		end,
	},
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				gopls = {
					settings = {
						gopls = {
							analyses = {
								unusedparams = true,
							},
							hints = {
								assignVariableTypes = true,
								compositeLiteralFields = true,
								compositeLiteralTypes = true,
								constantValues = true,
								functionTypeParameters = true,
								parameterNames = true,
								rangeVariableTypes = true,
							},
							staticcheck = true,
							semanticTokens = true,
						},
					},
				},
				golangci_lint_ls = {},
			},
			setup = {
				gopls = function(_, _)
					local lsp_utils = require("base.lsp.utils")
					lsp_utils.on_attach(function(client, bufnr)
						if client.name == "gopls" then
							if not client.server_capabilities.semanticTokensProvider then
								local semantic = client.config.capabilities.textDocument.semanticTokens
								client.server_capabilities.semanticTokensProvider = {
									full = true,
									legend = {
										tokenTypes = semantic.tokenTypes,
										tokenModifiers = semantic.tokenModifiers,
									},
									range = true,
								}
							end
						end
					end)
				end,
			},
		},
	},
	{
		"mfussenegger/nvim-dap",
		dependencies = { "leoluz/nvim-dap-go", opts = {} },
	},
}
