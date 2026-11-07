-- PowerShell: nvim-lspconfig starts Editor Services from its bundle (a set of
-- PowerShell modules, not a command) in the pwsh on PATH: on work the team's,
-- so Az cmdlets complete too. mise installs the bundle
-- (github:PowerShell/PowerShellEditorServices in the project's mise.toml) and
-- says where it is; without it, or without pwsh, the server stays off. Script
-- analysis uses Editor Services' default rules unless a repo has a
-- PSScriptAnalyzerSettings.psd1.

---The Editor Services bundle mise installed for this directory, if any
---@return string?
local function bundle_path()
  if vim.fn.executable("mise") == 0 or vim.fn.executable("pwsh") == 0 then return nil end
  local where = { "mise", "where", "github:PowerShell/PowerShellEditorServices" }
  local result = vim.system(where, { text = true }):wait(2000)
  local path = result.code == 0 and vim.trim(result.stdout or "") or ""
  if path ~= "" and vim.uv.fs_stat(vim.fs.joinpath(path, "PowerShellEditorServices")) then return path end
end

local bundle = bundle_path()

---@type Language
return {
  servers = {
    powershell_es = {
      -- nvim-lspconfig's cmd is a function, so name what it needs: pwsh, and
      -- only when there's a bundle
      executable = bundle and "pwsh" or nil,
      bundle_path = bundle,
      settings = {
        powershell = {
          -- Copied from the VS Code PowerShell extension's defaults, so
          -- formatting matches what VS Code users get (the server's own
          -- defaults differ, e.g. braces on their own line). Source: the
          -- powershell.codeFormatting.* settings in package.json of
          -- github.com/PowerShell/vscode-powershell, release v2025.4.0. Left out:
          -- whitespaceAroundPipe, deprecated there in favor of
          -- addWhitespaceAroundPipe.
          codeFormatting = {
            preset = "Custom",
            autoCorrectAliases = false,
            avoidSemicolonsAsLineTerminators = false,
            openBraceOnSameLine = true,
            newLineAfterOpenBrace = true,
            newLineAfterCloseBrace = true,
            pipelineIndentationStyle = "NoIndentation",
            whitespaceBeforeOpenBrace = true,
            whitespaceBeforeOpenParen = true,
            whitespaceAroundOperator = true,
            whitespaceAfterSeparator = true,
            whitespaceInsideBrace = true,
            whitespaceBetweenParameters = false,
            addWhitespaceAroundPipe = true,
            trimWhitespaceAroundPipe = false,
            ignoreOneLineBlock = true,
            alignPropertyValuePairs = true,
            useConstantStrings = false,
            useCorrectCasing = false,
          },
        },
      },
    },
  },
}
