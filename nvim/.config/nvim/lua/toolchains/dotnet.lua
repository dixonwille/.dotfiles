-- .NET (dotnet toolchain): the Roslyn (C#) language server, which solution a
-- file opens, and the file watching Roslyn needs on Linux.
--
-- A file opens a solution in its repository that lists the file's project:
--   1. the solution of the file last worked in (remembered across sessions)
--   2. a solution already running
--   3. the only one, or else the nearest one above the file
--   4. one picked from a list
-- A project in no solution is opened on its own. :RoslynSolution picks another
-- solution for the current file. Files outside a git repository fall back to
-- nvim-lspconfig's nearest-solution behavior.

-- nvim-lspconfig's roslyn_ls, which the root_dir and on_init below fall back to
local defaults = assert(vim.lsp.config.roslyn_ls, "nvim-lspconfig's roslyn_ls config is missing")
local default_root_dir = defaults.root_dir --[[@as fun(bufnr: integer, on_dir: fun(root_dir?: string))]]
local default_on_init = defaults.on_init or {}
if type(default_on_init) == "function" then default_on_init = { default_on_init } end
local state_file = vim.fs.joinpath(vim.fn.stdpath("state"), "roslyn-solutions.json")

---Solution or project each server opens, by root directory (the target's
---directory). Two solutions in one directory would share a server.
---@type table<string, string>
local targets = {}

---Last used solution per repository root
---@return table<string, string>
local function read_state()
  local ok, state = pcall(function() return vim.json.decode(table.concat(vim.fn.readfile(state_file), "\n")) end)
  return ok and type(state) == "table" and state or {}
end

---@param repo string
---@param sln string
local function remember(repo, sln)
  local state = read_state()
  if state[repo] == sln then return end
  state[repo] = sln
  vim.fn.mkdir(vim.fs.dirname(state_file), "p")
  vim.fn.writefile({ vim.json.encode(state) }, state_file)
end

---@param bufnr integer
---@return string?
local function find_project(bufnr)
  local file = vim.api.nvim_buf_get_name(bufnr)
  return vim.fs.find(function(name) return vim.endswith(name, ".csproj") end, {
    path = vim.fs.dirname(file),
    upward = true,
  })[1]
end

---Whether a .sln or .slnx lists the project
---@param sln string
---@param project string
---@return boolean
local function lists_project(sln, project)
  local ok, lines = pcall(vim.fn.readfile, sln)
  if not ok then return false end
  local pattern = vim.endswith(sln, ".slnx") and '<Project%s[^>]-Path="([^"]+)"'
    or '^Project%b()%s*=%s*"[^"]*"%s*,%s*"([^"]+)"'
  local dir = vim.fs.dirname(sln)
  for _, line in ipairs(lines) do
    local path = line:match(pattern)
    if path and vim.fs.normalize(vim.fn.simplify(vim.fs.joinpath(dir, (path:gsub("\\", "/"))))) == project then
      return true
    end
  end
  return false
end

---Solutions in the repository that list the project
---@param repo string
---@param project string
---@return string[]
local function solutions_for(repo, project)
  local ls = { "git", "-C", repo, "ls-files", "--cached", "--others", "--exclude-standard", "*.sln", "*.slnx" }
  local result = vim.system(ls, { text = true }):wait()
  if result.code ~= 0 then return {} end
  local slns = {}
  for _, path in ipairs(vim.split(result.stdout, "\n", { trimempty = true })) do
    local sln = vim.fs.joinpath(repo, path)
    if lists_project(sln, project) then table.insert(slns, sln) end
  end
  return slns
end

---@param repo string
---@param slns string[]
---@param on_choice fun(sln?: string)
local function pick(repo, slns, on_choice)
  vim.ui.select(slns, {
    prompt = "Solution",
    format_item = function(sln) return vim.fs.relpath(repo, sln) or sln end,
  }, on_choice)
end

---Choose among the solutions that list a file's project, in the order at the top
---@param file string
---@param repo string
---@param slns string[]
---@param on_choice fun(sln?: string)
local function choose(file, repo, slns, on_choice)
  local last = read_state()[repo]
  if vim.list_contains(slns, last) then return on_choice(last) end

  for _, client in ipairs(vim.lsp.get_clients({ name = "roslyn_ls" })) do
    local target = targets[client.root_dir]
    if not client:is_stopped() and vim.list_contains(slns, target) then return on_choice(target) end
  end

  if #slns == 1 then return on_choice(slns[1]) end

  local nearest, nearest_dir
  for _, sln in ipairs(slns) do
    local dir = vim.fs.dirname(sln)
    if vim.fs.relpath(dir, file) and (not nearest_dir or #dir > #nearest_dir) then
      nearest, nearest_dir = sln, dir
    end
  end
  if nearest then return on_choice(nearest) end

  pick(repo, slns, function(sln)
    if sln then remember(repo, sln) end
    on_choice(sln)
  end)
end

local server = {
  root_dir = function(bufnr, on_dir)
    local repo = vim.fs.root(bufnr, ".git")
    local project = find_project(bufnr)
    if not (repo and project) then return default_root_dir(bufnr, on_dir) end

    ---@param target string
    local function open(target)
      local root = vim.fs.dirname(target)
      targets[root] = target
      on_dir(root)
    end

    local slns = solutions_for(repo, project)
    if #slns == 0 then return open(project) end
    -- Picker cancelled: open the project on its own
    choose(vim.api.nvim_buf_get_name(bufnr), repo, slns, function(sln) open(sln or project) end)
  end,
  on_init = function(client, result)
    local target = targets[client.root_dir]
    if not target then
      for _, fn in ipairs(default_on_init) do
        fn(client, result)
      end
    elseif vim.endswith(target, ".csproj") then
      client:notify("project/open", { projects = { vim.uri_from_fname(target) } })
    else
      client:notify("solution/open", { solution = vim.uri_from_fname(target) })
    end
  end,
  -- Neovim doesn't offer file watching to servers on Linux (see
  -- make_client_capabilities in vim/lsp/protocol.lua), so Roslyn falls back to
  -- its own watcher and project load takes minutes. Offer it again. Neovim
  -- watches with inotifywait (inotify-tools, in the global nix profile), falling
  -- back to a watcher per directory without it.
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
      },
    },
  },
  handlers = {
    -- Roslyn asks to watch the usual Linux .NET install locations
    -- (/usr/lib/dotnet/packs, /usr/share/dotnet/packs) next to $DOTNET_ROOT/packs,
    -- whether they exist or not, and inotifywait reports each missing one as an
    -- error. Drop watches of directories that don't exist: no backend can watch
    -- them anyway.
    ["client/registerCapability"] = function(err, params, ctx)
      for _, reg in ipairs(params.registrations or {}) do
        local watchers = reg.method == "workspace/didChangeWatchedFiles" and reg.registerOptions.watchers
        if watchers then
          reg.registerOptions.watchers = vim.tbl_filter(function(watcher)
            local base = type(watcher.globPattern) == "table" and watcher.globPattern.baseUri
            if type(base) == "table" then base = base.uri end -- a WorkspaceFolder
            return not base or vim.uv.fs_stat(vim.uri_to_fname(base)) ~= nil
          end, watchers)
        end
      end
      return vim.lsp.handlers["client/registerCapability"](err, params, ctx)
    end,
  },
}

---Pick another solution for the current file (:RoslynSolution)
local function pick_solution()
  local bufnr = vim.api.nvim_get_current_buf()
  local repo = vim.fs.root(bufnr, ".git")
  local project = repo and find_project(bufnr)
  if not (repo and project) then
    vim.notify("Not in a C# project in a git repository", vim.log.levels.WARN)
    return
  end
  local slns = solutions_for(repo, project)
  if #slns == 0 then
    vim.notify("No solution lists " .. vim.fs.basename(project), vim.log.levels.WARN)
    return
  end

  pick(repo, slns, function(sln)
    if not sln then return end
    remember(repo, sln)
    -- Detach this file, and every open file the solution also lists, from its
    -- server; attaching again now opens the remembered solution. The autocmd
    -- vim.lsp.enable() attaches buffers with does the attaching.
    local moving = { [bufnr] = true }
    for _, client in ipairs(vim.lsp.get_clients({ name = "roslyn_ls", bufnr = bufnr })) do
      if targets[client.root_dir] ~= sln then
        for _, buf in ipairs(vim.tbl_keys(client.attached_buffers)) do
          local buf_project = find_project(buf)
          if buf == bufnr or (buf_project and lists_project(sln, buf_project)) then
            moving[buf] = true
            vim.lsp.buf_detach_client(buf, client.id)
          end
        end
        if vim.tbl_isempty(client.attached_buffers) then client:stop() end
      end
    end
    for buf in pairs(moving) do
      vim.api.nvim_exec_autocmds("FileType", { group = "nvim.lsp.enable", buffer = buf })
    end
  end)
end

---@type Toolchain
return {
  servers = { roslyn_ls = server },
  setup = function()
    local group = vim.api.nvim_create_augroup("Roslyn", { clear = true })

    vim.api.nvim_create_autocmd("LspAttach", {
      desc = "Add :RoslynSolution to buffers Roslyn attaches to",
      group = group,
      callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client or client.name ~= "roslyn_ls" then return end
        vim.api.nvim_buf_create_user_command(ev.buf, "RoslynSolution", pick_solution, {
          desc = "Pick the solution roslyn_ls opens for the current file",
        })
      end,
    })

    -- Remember the solution of the file being worked in. Only the current buffer
    -- counts, so files attached in the background don't change it.
    vim.api.nvim_create_autocmd({ "BufEnter", "LspAttach" }, {
      desc = "Remember the Roslyn solution of the current file",
      group = group,
      callback = function(ev)
        if ev.buf ~= vim.api.nvim_get_current_buf() then return end
        local client = vim.lsp.get_clients({ name = "roslyn_ls", bufnr = ev.buf })[1]
        local target = client and targets[client.root_dir]
        local repo = vim.fs.root(ev.buf, ".git")
        if repo and target and not vim.endswith(target, ".csproj") then remember(repo, target) end
      end,
    })
  end,
}
