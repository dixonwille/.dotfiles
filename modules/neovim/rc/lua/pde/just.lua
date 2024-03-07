if vim.fn.executable("just") == 0 then
	return {}
end

return {
	{
		"IndianBoy42/tree-sitter-just",
		dependencies = {
			"nvim-treesitter",
		},
		build = ":TSUpdate just",
		event = { "BufReadPost", "BufNewFile" },
		config = function()
			local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
			local justDir = vim.fn.stdpath("data") .. "/lazy/tree-sitter-just"
			parser_config.just = {
				install_info = {
					url = justDir,
					files = { "src/parser.c", "src/scanner.c" },
				},
				maintainers = { "@IndianBoy42" },
			}
		end,
	},
}
