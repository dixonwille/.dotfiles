-- TypeScript and JavaScript (typescript toolchain): vtsls, plus the servers that
-- toolchain also brings: ESLint (the project's own eslint), HTML, CSS/SCSS/Less
-- and JSON. Formatting is prettierd running the project's own prettier;
-- projects without one fall back to LSP formatting.

local formatters_by_ft = {}
-- stylua: ignore start
for _, ft in ipairs({
  "javascript", "javascriptreact", "typescript", "typescriptreact", "vue",
  "html", "htmlangular", "css", "scss", "less", "json", "jsonc",
}) do
  formatters_by_ft[ft] = { "prettierd" }
end
-- stylua: ignore end

---@type Toolchain
return {
  servers = {
    vtsls = {},
    eslint = { executable = "vscode-eslint-language-server" },
    html = { executable = "vscode-html-language-server" },
    cssls = { executable = "vscode-css-language-server" },
    jsonls = { executable = "vscode-json-language-server" },
  },
  formatters_by_ft = formatters_by_ft,
  formatters = {
    -- Only for projects with their own prettier; others use LSP formatting
    prettierd = {
      condition = function(_, ctx)
        return vim.fs.find("node_modules/.bin/prettier", { path = ctx.dirname, upward = true })[1] ~= nil
      end,
    },
  },
}
