if vim.fn.executable("dotnet") == 0 then
	return {}
end

local function fix_tokens(client)
	local function to_snake_case(str)
		return string.gsub(str, "%s*[- ]%s*", "_")
	end
	local tokenModifiers = client.server_capabilities.semanticTokensProvider.legend.tokenModifiers
	for i, v in ipairs(tokenModifiers) do
		tokenModifiers[i] = to_snake_case(v)
	end
	local tokenTypes = client.server_capabilities.semanticTokensProvider.legend.tokenTypes
	for i, v in ipairs(tokenTypes) do
		tokenTypes[i] = to_snake_case(v)
	end
end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, { "c_sharp" })
		end,
	},
	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, { "netcoredbg" })
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "Hoffs/omnisharp-extended-lsp.nvim" },
		opts = {
			servers = {
				omnisharp = {
					organize_imports_on_format = true,
					enable_import_completion = true,
				},
			},
			setup = {
				omnisharp = function(_, opts)
					local lsp_utils = require("base.lsp.utils")
					opts.handlers = {
						["textDocument/definition"] = require("omnisharp_extended").handler,
					}
					lsp_utils.on_attach(function(client, _)
						if client.name == "omnisharp" then
							fix_tokens(client)
						end
					end)
				end,
			},
		},
	},
	{
		"mfussenegger/nvim-dap",
		opts = {
			setup = {
				netcoredbg = function(_, _)
					local dap = require("dap")

					local function get_debugger()
						local mason_registry = require("mason-registry")
						local debugger = mason_registry.get_package("netcoredbg")
						return debugger:get_install_path() .. "/netcoredbg"
					end

					dap.configurations.cs = {
						{
							type = "coreclr",
							name = "launch - netcoredbg",
							request = "launch",
							program = function()
								return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/", "file")
							end,
						},
					}
					dap.adapters.coreclr = {
						type = "executable",
						command = get_debugger(),
						args = { "--interpreter=vscode" },
					}
					dap.adapters.netcoredbg = {
						type = "executable",
						command = get_debugger(),
						args = { "--interpreter=vscode" },
					}
				end,
			},
		},
	},
}
