require("oil").setup()
vim.keymap.set({ "n" }, "-", "<cmd>Oil<cr>", { desc = "Open Oil" })

local picker = require("fzf-lua")
picker.setup()
picker.register_ui_select()

---Keywords the comment parser highlights (TODO, FIXME, ...), read from its
---highlights query so search and highlighting share one list
---@return string[]
local function todo_keywords()
  local ok, query = pcall(vim.treesitter.query.get, "comment", "highlights")
  if not ok or not query then return {} end
  local seen, keywords = {}, {} ---@type table<string, boolean>, string[]
  for _, predicates in pairs(query.info.patterns) do
    for _, predicate in ipairs(predicates) do
      local id = predicate[2] --[[@as integer]]
      local capture = query.captures[id]
      if predicate[1] == "any-of?" and capture and capture:match("^comment%.") then
        for i = 3, #predicate do
          local keyword = predicate[i] --[[@as string]]
          if not seen[keyword] then
            seen[keyword] = true
            table.insert(keywords, keyword)
          end
        end
      end
    end
  end
  return keywords
end

local find_todos = function()
  local keywords = todo_keywords()
  if #keywords == 0 then
    vim.notify("No TODO keywords found; is the comment parser installed?", vim.log.levels.WARN)
    return
  end
  -- Same shape as the comment grammar's tag: KEYWORD, optional (user), then ":"
  local reg_ex = [[\b(?:]] .. table.concat(keywords, "|") .. [[)(?:\s?\(\w+\))?:]]
  picker.fzf_exec(
    "rg --column --line-number --no-heading --color=always --smart-case --max-columns=4096 --hidden -g '!.git' -e '"
      .. reg_ex
      .. "'",
    {
      ---@diagnostic disable-next-line: assign-type-mismatch
      actions = picker.defaults.actions.files,
      previewer = "builtin",
      winopts = { title = "TODOs" },
    }
  )
end

vim.keymap.set({ "n" }, "<leader>ff", function() picker.files() end, { desc = "Find Files" })
vim.keymap.set({ "n" }, "<leader>fg", function() picker.live_grep() end, { desc = "Live Grep" })
vim.keymap.set({ "n" }, "<leader>fb", function() picker.buffers() end, { desc = "Find Buffers" })
vim.keymap.set({ "n" }, "<leader>fh", function() picker.helptags() end, { desc = "Find Help" })
vim.keymap.set({ "n" }, "<leader>ft", find_todos, { desc = "Find Todos" })
