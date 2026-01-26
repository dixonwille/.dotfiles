-- TODO (wd): include treesitter
-- TODO (wd): include mason
-- TODO (wd): should I handle Razor?

---@class RoslynCodeAction
---@field title string
---@field code_action table

---@return RoslynCodeAction[]
local function get_code_actions(nested_code_actions)
  return vim.iter(nested_code_actions)
      :map(function(it)
        local code_action_path = it.data.CodeActionPath
        local fix_all_flavors = it.data.FixAllFlavors

        if #code_action_path == 1 then
          return {
            title = code_action_path[1],
            code_action = it,
          }
        end

        local title = table.concat(code_action_path, " -> ", 2)
        return {
          title = fix_all_flavors and string.format("Fix All: %s", title) or title,
          code_action = it,
        }
      end)
      :totable()
end

local function handle_fix_all_code_action(client, data)
  local flavors = data.arguments[1].FixAllFlavors
  vim.ui.select(flavors, { prompt = "Pick a fix all scope:" }, function(flavor)
    client:request("codeAction/resolveFixAll", {
      title = data.title,
      data = data.arguments[1],
      scope = flavor,
    }, function(err, response)
      if err then
        vim.notify(err.message, vim.log.levels.ERROR, { title = "roslyn_ls" })
      end
      if response and response.edit then
        vim.lsp.util.apply_workspace_edit(response.edit, client.offset_encoding)
      end
    end)
  end)
end

vim.lsp.config("roslyn_ls", {
  cmd = {
    "roslyn",
    "--logLevel",
    "Information",
    "--extensionLogDirectory",
    vim.fs.joinpath(vim.uv.os_tmpdir(), "roslyn_ls/logs"),
    "--stdio"
  },
  commands = {
    ["roslyn.client.fixAllCodeAction"] = function(data, ctx)
      local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
      handle_fix_all_code_action(client, data)
    end,
    ["roslyn.client.nestedCodeAction"] = function(data, ctx)
      local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
      local args = data.arguments[1]
      local code_actions = get_code_actions(args.NestedCodeActions)
      local titles = vim.iter(code_actions)
          :map(function(it)
            return it.title
          end)
          :totable()

      vim.ui.select(titles, { prompt = args.UniqueIdentifier }, function(selected)
        local action = vim.iter(code_actions):find(function(it)
          return it.title == selected
        end) --[[@as RoslynCodeAction]]

        if action.code_action.data.FixAllFlavors then
          handle_fix_all_code_action(client, action.code_action.command)
        else
          client:request("codeAction/resolve", {
            title = action.code_action.title,
            data = action.code_action.data,
            ---@diagnostic disable-next-line: param-type-mismatch
          }, function(err, response)
            if err then
              vim.notify(err.message, vim.log.levels.ERROR, { title = "roslyn.nvim" })
            end
            if response and response.edit then
              vim.lsp.util.apply_workspace_edit(response.edit, client.offset_encoding)
            end
          end)
        end
      end)
    end,
  },
})

vim.lsp.enable({ "roslyn_ls" })
