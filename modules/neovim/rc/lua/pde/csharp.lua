if vim.fn.executable("dotnet") == 0 then
	return {}
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
					opts.handlers = {
						["textDocument/definition"] = require("omnisharp_extended").handler,
					}
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
