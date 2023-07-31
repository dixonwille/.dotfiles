local icons = require("config.icons")

return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			"plenary.nvim",
		},
		cmd = "Telescope",
		keys = {
			{ "<leader>sf", "<cmd>Telescope find_files<cr>", desc = "[S]earch [F]iles" },
			{ "<leader>sb", "<cmd>Telescope buffers<cr>", desc = "[S]earch [B]uffers" },
			{ "<leader>sa", "<cmd>Telescope autocommands<cr>", desc = "[S]earch [A]utocommands" },
			{ "<leader>sg", "<cmd>Telescope live_grep<cr>", desc = "[S]earch with [G]rep" },
			{ "<leader>sh", "<cmd>Telescope help_tags<cr>", desc = "[S]earch [H]elp" },
			{ "<leader>sk", "<cmd>Telescope keymaps<cr>", desc = "[S]earch [K]eymaps" },
			{ "<leader>st", "<cmd>TodoTelescope<cr>", desc = "[S]earch [T]odos" },
		},
		opts = {
			defaults = {
				initial_mode = "normal",
			},
		},
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"plenary.nvim",
			"nvim-web-devicons",
			"nui.nvim",
		},
		cmd = "Neotree",
		keys = {
			{ "<leader>b", "<cmd>Neotree toggle<cr>", desc = "Open File Tree" },
		},
		opts = {
			close_if_last_window = true,
			filesystem = {
				follow_current_file = {
					enabled = true,
				},
			},
			default_component_configs = {
				modified = {
					symbol = icons.mods.unsaved,
				},
				git_status = {
					symbols = {
						deleted = icons.mods.removed,
						renamed = icons.mods.renamed,
						untracked = icons.git.untracked,
						ignored = icons.git.ignored,
						unstaged = icons.git.unstaged,
						staged = icons.git.staged,
						conflict = icons.git.conflict,
					},
				},
			},
		},
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			setup = {
				key_labels = { ["<leader>"] = "SPC" },
			},
			defaults = {
				mode = { "n", "v" },
				["<leader>c"] = { name = "+Check" },
				["<leader>s"] = { name = "+Search" },
			},
		},
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts.setup)
			wk.register(opts.defaults)
		end,
	},
}
