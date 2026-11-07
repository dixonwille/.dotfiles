-- Spell checking everywhere it makes sense: treesitter limits it to @spell
-- regions (comments in code, prose in markdown, commit messages), and buffers
-- without any (logs, data files) aren't checked at all (noplainbuffer).
-- camelCase words are checked by their parts.
vim.o.spell = true
vim.o.spelllang = "en_us"
vim.opt.spelloptions = { "camel", "noplainbuffer" }

-- Word lists: zg adds to the first, this config's (shared by every machine);
-- 2zg to the second, a machine's own list named by DOTFILES_SPELLFILE (e.g. work
-- names, kept in the private personal/ submodule).
local spellfiles = { vim.fs.joinpath(vim.fn.stdpath("config"), "spell", "en.utf-8.add") }
if vim.env.DOTFILES_SPELLFILE then table.insert(spellfiles, vim.fs.normalize(vim.env.DOTFILES_SPELLFILE)) end
vim.opt.spellfile = spellfiles

-- The compiled .spl next to each list isn't committed, and Neovim doesn't notice
-- when a list changes outside it (e.g. words pulled from another machine), so
-- rebuild it when the list is newer
for _, add in ipairs(spellfiles) do
  local list, compiled = vim.uv.fs_stat(add), vim.uv.fs_stat(add .. ".spl")
  if list and (not compiled or compiled.mtime.sec < list.mtime.sec) then
    vim.cmd("silent mkspell! " .. vim.fn.fnameescape(add))
  end
end

-- z= picks a suggestion with fzf-lua; with a count (1z=) it still takes that
-- suggestion directly, as built in
vim.keymap.set({ "n" }, "z=", function()
  if vim.v.count > 0 then return vim.cmd("normal! " .. vim.v.count .. "z=") end
  require("fzf-lua").spell_suggest()
end, { desc = "Spelling suggestions" })
