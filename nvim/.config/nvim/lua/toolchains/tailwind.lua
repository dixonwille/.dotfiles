-- Tailwind CSS (tailwind toolchain): the Tailwind language server, and, where
-- it's loaded, typescript's CSS server (cssls) learns Tailwind's at-rules
-- (tailwind-css-data.json), so @tailwind, @apply, @theme, ... get hover docs
-- instead of "Unknown at rule" warnings, while genuinely unknown at-rules still
-- warn.

local executable = "tailwindcss-language-server"

---@type table<string, LanguageServer>
local servers = { tailwindcss = { executable = executable } }

if vim.fn.executable(executable) == 1 then
  local data = vim.api.nvim_get_runtime_file("lua/toolchains/tailwind-css-data.json", false)[1]
  servers.cssls = {
    -- The server takes custom data by notification (VS Code sends it from the
    -- css.customData setting): one parameter, a list of file:// URIs. Array
    -- params are positional in JSON-RPC, so the list is wrapped. Not a standard
    -- LSP method, so it isn't in Neovim's list of method names.
    on_init = function(client)
      ---@diagnostic disable-next-line: param-type-mismatch
      client:notify("css/customDataChanged", { { vim.uri_from_fname(data) } })
    end,
  }
end

---@type Toolchain
return { servers = servers }
