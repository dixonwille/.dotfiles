-- Project tools from mise, for this Neovim. mise's shims directory is on PATH
-- (mise's default activate_shims; on work, .zshrc's shims mode beside direnv),
-- and it has a shim for every tool mise installed for any project, so "on PATH"
-- would mean "installed for some project": outside one that sets the tool, its
-- shim fails ("No version is set for shim"). So ask mise once which tools this
-- directory sets (mise bin-paths) and put their real directories where the
-- shims directory was, dropping it. Then a command on PATH is one this project
-- uses, at its real path, and lua/languages' rule (use what's executable) holds.
-- Like the shell's PATH, it's decided by the directory Neovim starts in.

local data = vim.env.MISE_DATA_DIR
  or vim.fs.joinpath(vim.env.XDG_DATA_HOME or vim.fs.joinpath(vim.env.HOME, ".local", "share"), "mise")
local shims = vim.fs.joinpath(data, "shims")

local entries = vim.split(vim.env.PATH or "", ":", { plain = true, trimempty = true })
local at
for i, entry in ipairs(entries) do
  if vim.fs.normalize(entry) == shims then
    at = i
    break
  end
end
if not at then return end

-- Without an answer (no mise, untrusted config), tools are missing rather than failing
local bins = {}
if vim.fn.executable("mise") == 1 then
  local result = vim.system({ "mise", "bin-paths" }, { text = true }):wait(2000)
  if result.code == 0 then bins = vim.split(vim.trim(result.stdout or ""), "\n", { trimempty = true }) end
end

local seen, path = {}, {}
for _, entry in ipairs(entries) do
  seen[entry] = true
end
for i, entry in ipairs(entries) do
  if i == at then
    for _, bin in ipairs(bins) do
      if not seen[bin] then
        seen[bin] = true
        table.insert(path, bin)
      end
    end
  else
    table.insert(path, entry)
  end
end
vim.env.PATH = table.concat(path, ":")
