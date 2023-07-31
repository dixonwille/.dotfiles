return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, { "javascript", "typescript", "tsx" })
		end,
	},
	{
		"williamboman/mason.nvim",
		opts = function(_, opts)
			vim.list_extend(opts.ensure_installed, { "eslint_d", "prettierd", "js-debug-adapter" })
		end,
	},
	{
		"pmizio/typescript-tools.nvim",
		opts = {},
		config = function(_, opts)
			require("base.lsp.utils").on_attach(function(client, bufnr)
				if client.name == "tsserver" then
					vim.keymap.set(
						"n",
						"<leader>lo",
						"<cmd>TSToolsOrganizeImports<cr>",
						{ buffer = bufnr, desc = "Organize Imports" }
					)
					vim.keymap.set(
						"n",
						"<leader>lO",
						"<cmd>TSToolsSortImports<cr>",
						{ buffer = bufnr, desc = "Sort Imports" }
					)
					vim.keymap.set(
						"n",
						"<leader>lu",
						"<cmd>TSToolsRemoveUnused<cr>",
						{ buffer = bufnr, desc = "Removed Unused" }
					)
					vim.keymap.set(
						"n",
						"<leader>lz",
						"<cmd>TSToolsGoToSourceDefinition<cr>",
						{ buffer = bufnr, desc = "Go To Source Definition" }
					)
					vim.keymap.set(
						"n",
						"<leader>lR",
						"<cmd>TSToolsRemoveUnusedImports<cr>",
						{ buffer = bufnr, desc = "Removed Unused Imports" }
					)
					vim.keymap.set("n", "<leader>lF", "<cmd>TSToolsFixAll<cr>", { buffer = bufnr, desc = "Fix All" })
					vim.keymap.set(
						"n",
						"<leader>lA",
						"<cmd>TSToolsAddMissingImports<cr>",
						{ buffer = bufnr, desc = "Add Missing Imports" }
					)
				end
			end)
			require("typescript-tools").setup(opts)
		end,
	},
	{
		"neovim/nvim-lspconfig",
		dependencies = { "pmizio/typescript-tools.nvim" },
		opts = {
			-- make sure mason installs the server
			servers = {
				-- ESLint
				eslint = {
					settings = {
						-- helps eslint find the eslintrc when it's placed in a subfolder instead of the cwd root
						workingDirectory = { mode = "auto" },
					},
				},
			},
			setup = {
				eslint = function()
					-- Format on save when you use https://github.com/prettier/eslint-plugin-prettier
					vim.api.nvim_create_autocmd("BufWritePre", {
						callback = function(event)
							local client = vim.lsp.get_active_clients({ bufnr = event.buf, name = "eslint" })[1]
							if client then
								local diag = vim.diagnostic.get(
									event.buf,
									{ namespace = vim.lsp.diagnostic.get_namespace(client.id) }
								)
								if #diag > 0 then
									vim.cmd("EslintFixAll")
								end
							end
						end,
					})
				end,
			},
		},
	},
	{
		"mfussenegger/nvim-dap",
		opts = {
			setup = {
				vscode_js_debug = function()
					local function get_js_debug()
						local install_path =
							require("mason-registry").get_package("js-debug-adapter"):get_install_path()
						return install_path .. "/js-debug/src/dapDebugServer.js"
					end

					for _, adapter in ipairs({
						"pwa-node",
						"pwa-chrome",
						"pwa-msedge",
						"node-terminal",
						"pwa-extensionHost",
					}) do
						require("dap").adapters[adapter] = {
							type = "server",
							host = "localhost",
							port = "${port}",
							executable = {
								command = "node",
								args = {
									get_js_debug(),
									"${port}",
								},
							},
						}
					end

					for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
						require("dap").configurations[language] = {
							{
								type = "pwa-msedge",
								name = "Attach - Remote Debugging",
								request = "attach",
								program = "${file}",
								cwd = vim.fn.getcwd(),
								sourceMaps = true,
								protocol = "inspector",
								port = 9222, -- Start Chrome google-chrome --remote-debugging-port=9222
								webRoot = "${workspaceFolder}",
							},
							{
								type = "pwa-msedge",
								name = "Launch Chrome",
								request = "launch",
								url = "http://localhost:5173", -- This is for Vite. Change it to the framework you use
								webRoot = "${workspaceFolder}",
								userDataDir = "${workspaceFolder}/.vscode/vscode-chrome-debug-userdatadir",
							},
						}
					end
				end,
			},
		},
	},
}
