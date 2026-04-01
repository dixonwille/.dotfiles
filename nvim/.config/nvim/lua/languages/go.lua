vim.lsp.enable({ "gopls" })

local M = {}

M.templates = function(files)
  vim.treesitter.query.add_directive("inject-go-tmpl!", function(_, _, bufnr, _, metadata)
    if type(bufnr) ~= "number" then return end
    local fname = vim.fs.basename(vim.api.nvim_buf_get_name(bufnr))
    local _, _, ext, _ = string.find(fname, ".*%.(%a+)(%.%a+)")
    if ext then
      metadata["injection.language"] = ext
    end
  end, {})
  if type(files) == "string" then
    files = { files }
  end
  local filename = {}
  for _, f in ipairs(files) do
    filename[f] = "gotmpl"
  end
  vim.filetype.add({ filename = filename })
end

return M
