vim.api.nvim_create_user_command("PackUpdate", function() vim.pack.update() end, { desc = "Update Packages" })

-- TODO (WD): Make this more generic
local packupdateaug = vim.api.nvim_create_augroup("PackChanges", { clear = true })
vim.api.nvim_create_autocmd({ "PackChanged" }, {
  desc = "Run build like commands when packages are updated",
  pattern = "*",
  group = packupdateaug,
  callback = function(opt)
    --- @type {kind: "install"|"update"|"delete", spec: vim.pack.Spec, path: string}
    local data = opt.data
    if data.kind == 'update' and data.spec.name == 'nvim-treesitter' then
      vim.notify("Updating Treesitter Parsers", vim.log.levels.INFO, {})
      vim.cmd.TSUpdate()
    end
    if (data.kind == 'install' or data.kind == 'update') and data.spec.name == 'LuaSnip' then
      local luasnipPath = vim.fs.joinpath(vim.fn.stdpath("data"), "site", "pack", "core", "opt", "LuaSnip")
      if not vim.fn.isdirectory(luasnipPath) then
        vim.notify("LuaSnip Directory doesn't exist", vim.log.levels.ERROR, {})
      end
      vim.notify("Updataing jsregexp", vim.log.levels.INFO, {})
      vim.fn.jobstart({ "make", "install_jsregexp" }, {
        cwd = luasnipPath,
        on_exit = function(_, code, _)
          if code ~= 0 then
            vim.notify("Failed to install jsregexp", vim.log.levels.ERROR, {});
          else
            vim.notify("Successfully to install jsregexp", vim.log.levels.INFO, {});
          end
        end
      })
    end
  end
})

vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim" },                                              -- Package with util funtions for other packages (CodeCompanion)
  { src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },                  -- Better Syntax Highlighting
  { src = "https://github.com/neovim/nvim-lspconfig" },                                              -- Default configurations for LSPs
  { src = "https://github.com/mason-org/mason.nvim" },                                               -- Ability to install lsps, formatters, and linters
  { src = "https://github.com/stevearc/conform.nvim" },                                              -- Use Formatters
  { src = "https://github.com/mfussenegger/nvim-lint" },                                             -- Use Linters
  { src = "https://github.com/echasnovski/mini.pick" },                                              -- vim.ui.select and other functionality (finding files)
  { src = "https://github.com/stevearc/oil.nvim" },                                                  -- File navigation using Buffers
  { src = "https://github.com/folke/tokyonight.nvim" },                                              -- Color Scheme
  { src = "https://github.com/echasnovski/mini.statusline" },                                        -- Pretty Status Line
  { src = "https://github.com/echasnovski/mini.tabline" },                                           -- Pretty Tab Line
  { src = "https://github.com/echasnovski/mini.notify" },                                            -- Pretty LSP Progress notifications
  { src = "https://github.com/saghen/blink.cmp",                version = vim.version.range('^1') }, -- Better Auto Completion TODO (WD): see if there is a better option later 8/6/2025
  { src = "https://github.com/zbirenbaum/copilot.lua" },                                             -- Use Copilot for authenticating purposes
  { src = "https://github.com/olimorris/codecompanion.nvim" },                                       -- Agentic AI Chat
  { src = "https://github.com/L3MON4D3/LuaSnip",                version = vim.version.range('^2') }, -- Get snippets included in completions
  { src = "https://github.com/rafamadriz/friendly-snippets" }                                        -- Bunch of snippets for different languages
})
