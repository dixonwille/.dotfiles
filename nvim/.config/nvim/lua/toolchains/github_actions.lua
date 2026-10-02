-- GitHub Actions (github-actions toolchain): workflow files
-- (.github/workflows/*.yml, *.yaml) get the yaml.github-actions filetype, which
-- the language server and actionlint use. The yaml part keeps treesitter and
-- other YAML tooling working.
--
-- nvim-lspconfig's gh_actions_ls runs lttb's
-- gh-actions-language-server, a wrapper that only existed because GitHub's
-- @actions/languageserver had no executable. It has one now
-- (actions-languageserver), so run that instead; the protocol is the same, so
-- gh_actions_ls's workflow-only root_dir and actions/readFile handler still apply.
--
-- With a GitHub token and the repository's metadata, the server also validates
-- and completes `uses: ... with:` inputs and the repository's secrets and
-- variables. Both come from the gh CLI (`gh auth token`, `gh api`), when it's
-- installed and logged in. See "Providing advanced functionality" in
-- github.com/actions/languageservices/tree/main/languageserver, and
-- nvim-lspconfig's draft PR #4214, which does the same but blocks the editor
-- while gh runs. Here gh runs in the background before the server starts, once
-- per repository; without gh, the server starts without them. If gh fails (not
-- logged in, offline), it runs again the next time a server starts there.

-- nvim-lspconfig's gh_actions_ls root_dir: only .github/workflows directories
local default_root_dir = vim.lsp.config.gh_actions_ls.root_dir --[[@as fun(bufnr: integer, on_dir: fun(root_dir: string))]]

---Initialization options per root directory (a .github/workflows directory),
---from the latest fetch
---@type table<string, table>
local init_options = {}

---Root directories whose fetch fully succeeded, so it needn't run again
---@type table<string, true>
local fetched = {}

---@param root string
---@param on_done fun(options: table, complete: boolean)
local function fetch_init_options(root, on_done)
  local repo_root = vim.fs.root(root, ".git") or vim.fs.dirname(vim.fs.dirname(root))
  local options, pending = {}, 2
  local function finish()
    pending = pending - 1
    if pending == 0 then
      vim.schedule(function() on_done(options, options.sessionToken ~= nil and options.repos ~= nil) end)
    end
  end
  vim.system({ "gh", "auth", "token", "-h", "github.com" }, { text = true }, function(result)
    if result.code == 0 and result.stdout ~= "" then options.sessionToken = vim.trim(result.stdout) end
    finish()
  end)
  -- gh fills in {owner}/{repo} from the repository's GitHub remote
  local jq = '{id, name, owner: .owner.login, organizationOwned: (.owner.type == "Organization")}'
  vim.system({ "gh", "api", "repos/{owner}/{repo}", "--jq", jq }, { cwd = repo_root, text = true }, function(result)
    local ok, repo = pcall(vim.json.decode, result.code == 0 and result.stdout or "")
    if ok and type(repo) == "table" then
      repo.workspaceUri = vim.uri_from_fname(repo_root)
      options.repos = { repo }
    end
    finish()
  end)
end

---@type Toolchain
return {
  filetype = {
    pattern = {
      -- Above the azure-pipelines rules, so a workflow named azure*.yml is a workflow
      [".*/%.github/workflows/[^/]+%.ya?ml"] = { "yaml.github-actions", { priority = 1001 } },
    },
  },
  servers = {
    gh_actions_ls = {
      cmd = { "actions-languageserver", "--stdio" },
      filetypes = { "yaml.github-actions" },
      root_dir = function(bufnr, on_dir)
        default_root_dir(bufnr, function(root)
          -- A running server already has its options; fetching again can't change them
          local running = vim.lsp.get_clients({ name = "gh_actions_ls" })
          running = vim.tbl_contains(running, function(c) return c.root_dir == root end, { predicate = true })
          if fetched[root] or running or vim.fn.executable("gh") == 0 then return on_dir(root) end
          fetch_init_options(root, function(options, complete)
            init_options[root], fetched[root] = options, complete or nil
            on_dir(root)
          end)
        end)
      end,
      before_init = function(params, config)
        local options = params.initializationOptions --[[@as table?]]
        params.initializationOptions = vim.tbl_extend("force", options or {}, init_options[config.root_dir] or {})
      end,
    },
  },
  linters_by_ft = { ["yaml.github-actions"] = { "actionlint" } },
  lint_roots = { actionlint = { ".github" } },
}
