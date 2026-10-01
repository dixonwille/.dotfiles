vim.api.nvim_create_user_command("PackUpdate", function() vim.pack.update() end, { desc = "Update Packages" })
vim.api.nvim_create_user_command(
  "PackLock",
  function() vim.pack.update(nil, { target = "lockfile" }) end,
  { desc = "Update Packages based on lockfile" }
)

--- @alias kind "install"|"update"|"delete"

--- @type table<kind, table<string, fun()>>
local pack_handlers = {
  update = {},
  install = {},
  delete = {},
}

--- @param event kind | (kind)[]
--- @param pkg string
--- @param fn fun()
local add_pack_handler = function(event, pkg, fn)
  if type(event) == "string" then
    pack_handlers[event][pkg] = fn
  elseif type(event) == "table" then
    for _, ev in ipairs(event) do
      pack_handlers[ev][pkg] = fn
    end
  end
end

add_pack_handler("update", "nvim-treesitter", function() vim.cmd.TSUpdate() end)

local packupdateaug = vim.api.nvim_create_augroup("PackChanges", { clear = true })
vim.api.nvim_create_autocmd({ "PackChanged" }, {
  desc = "Run build like commands when packages are updated",
  group = packupdateaug,
  callback = function(opt)
    --- @type {kind: kind, spec: vim.pack.Spec, path: string}
    local data = opt.data
    local name = data.spec.name
    if not name then return end
    local kind_table = pack_handlers[data.kind]
    if not kind_table then return end
    local handler = kind_table[name]
    if handler then handler() end
  end,
})

-- stylua: ignore start
vim.pack.add({
  { src = "https://github.com/nvim-treesitter/nvim-treesitter",          version = "main" },                  -- Better Syntax Highlighting
  { src = "https://github.com/neovim/nvim-lspconfig" },                                                       -- Default configurations for LSPs
  { src = "https://github.com/stevearc/conform.nvim" },                                                       -- Use Formatters
  { src = "https://github.com/mfussenegger/nvim-lint" },                                                      -- Use Linters
  { src = "https://github.com/ibhagwan/fzf-lua" },                                                            -- Finding values in lists of things
  { src = "https://github.com/stevearc/oil.nvim" },                                                           -- File navigation using Buffers
  { src = "https://github.com/vague-theme/vague.nvim" },                                                      -- Color Scheme
  { src = "https://github.com/nvim-mini/mini.icons" },                                                        -- Support icons
  { src = "https://github.com/saghen/blink.cmp",                         version = vim.version.range("^1") }, -- Completion menu, docs and signature help (see completion.lua)
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" }                                    -- Better markdown previewer
})
-- stylua: ignore end
