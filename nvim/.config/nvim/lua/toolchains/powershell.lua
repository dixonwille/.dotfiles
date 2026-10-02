-- PowerShell (powershell toolchain): nvim-lspconfig starts Editor Services from
-- a bundle, in a PowerShell. The toolchain provides both (PSES_BUNDLE_PATH,
-- PSES_PWSH), so the server runs in nixpkgs' PowerShell rather than the global
-- pwsh. Script analysis uses Editor Services' default rules unless a repo has a
-- PSScriptAnalyzerSettings.psd1.
---@type Toolchain
return {
  servers = {
    powershell_es = {
      executable = "powershell-editor-services",
      bundle_path = vim.env.PSES_BUNDLE_PATH,
      shell = vim.env.PSES_PWSH,
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
