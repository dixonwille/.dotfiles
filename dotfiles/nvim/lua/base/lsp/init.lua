return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    opts = {
      servers = {},
      setup = {},
    },
    config = function(plugin, opts)
      require("base.lsp.servers").setup(plugin, opts)
    end,
  },
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate",
    cmd = "Mason",
    keys = {
      {"<leader>cm", "<cmd>Mason<cr>", desc = "[C]heck [M]ason" }
    },
    opts = {
      ensure_installed = {},
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require "mason-registry"
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    event = "BufReadPre",
    dependencies = { "mason.nvim" },
    opts = {
      sources = {}
    }
  },
}
