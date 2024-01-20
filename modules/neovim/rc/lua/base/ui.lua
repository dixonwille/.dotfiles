local icons = require("config.icons")

return {
	{ "nvim-tree/nvim-web-devicons" },
	{ "MunifTanjim/nui.nvim" },
	{
		"sainnhe/gruvbox-material",
		lazy = false,
		priority = 1000,
		config = function()
			vim.opt.background = "dark"
			vim.cmd([[colorscheme gruvbox-material]])
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		event = "VeryLazy",
		dependencies = {
			"nvim-web-devicons",
		},
		opts = function()
			return {
				options = {
					theme = "auto",
					globalstatus = true,
					disabled_filetypes = {
						statusline = { "lazy" },
					},
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch" },
					lualine_c = {
						{
							"diagnostics",
							symbols = {
								error = icons.status.error,
								warn = icons.status.warn,
								info = icons.status.info,
								hint = icons.status.hint,
							},
						},
						{ "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
						{
							"filename",
							path = 1,
							symbols = { modified = icons.mods.unsaved, readonly = icons.mods.readonly, unnamed = "" },
						},
					},
					lualine_x = {
						{
							"diff",
							symbols = {
								added = icons.mods.added,
								modified = icons.mods.modified,
								removed = icons.mods.removed,
							},
						},
					},
					lualine_y = {
						{ "progress", separator = "", padding = { left = 1, right = 0 } },
						{ "location", padding = { left = 0, right = 1 } },
					},
					lualine_z = {
						function()
							return icons.misc.clock .. " " .. os.date("%R")
						end,
					},
				},
				extensions = { "neo-tree", "trouble" },
			}
		end,
	},
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		version = "*",
		dependencies = {
			"nvim-web-devicons",
		},
		opts = {
			options = {
				diagnostics = "nvim_lsp",
				always_show_bufferline = false,
				diagnostics_indicator = function(_, _, diag)
					local ret = (diag.error and icons.status.error .. " " .. diag.error .. " " or "")
						.. (diag.warning and icons.status.warn .. " " .. diag.warning or "")
					return vim.trim(ret)
				end,
				numbers = "ordinal",
				offsets = {
					{
						filetype = "neo-tree",
						text = "Neo-Tree",
						highlight = "Directory",
						text_align = "left",
					},
				},
			},
		},
	},
}
