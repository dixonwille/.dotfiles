return {
	"github/copilot.vim",
	event = "InsertEnter",
	cmd = {
		"Copilot",
	},
	keys = { { "<C-a>", 'copilot#Accept("\\<CR>")', mode = "i", expr = true, replace_keycodes = false } },
}
