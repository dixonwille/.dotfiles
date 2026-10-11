-- WezTerm on Windows at work, set up to match Ghostty at home
-- (ghostty/.config/ghostty/config.ghostty). %USERPROFILE%\.config\wezterm\wezterm.lua
-- loads this file from WSL (written by install/work), so edits here apply on reload.
local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- Fonts, the same on every machine: Maple Mono for text, CJK and Nerd Font
-- icons, then DejaVu Sans Mono for the symbols Maple lacks. WezTerm's own
-- fallbacks (Noto Color Emoji among them) come after, for emoji.
config.font = wezterm.font_with_fallback({ "Maple Mono NF CN", "DejaVu Sans Mono" })
config.font_size = 10
config.enable_kitty_graphics = true
-- Widths as tmux, Windows Terminal and Ghostty count them: VS16 (emoji
-- presentation) makes a character 2 cells wide. The default, 9, ignores it.
config.unicode_version = 14

-- Vague, as in Windows Terminal (and Ghostty's theme = Vague).
config.color_schemes = {
	Vague = {
		foreground = "#CDCDCD",
		background = "#141414",
		cursor_bg = "#CDCDCD",
		cursor_border = "#CDCDCD",
		selection_bg = "#252530",
		ansi = { "#252530", "#D8647E", "#7FA563", "#F3BE7C", "#6E94B2", "#BB9DBD", "#AEAED1", "#CDCDCD" },
		brights = { "#606079", "#E08398", "#99B782", "#F5CB96", "#8BA9C1", "#C9B1CA", "#BEBEDA", "#D7D7D7" },
	},
}
config.color_scheme = "Vague"

config.hide_mouse_cursor_when_typing = true -- mouse-hide-while-typing
config.inactive_pane_hsb = { saturation = 1.0, brightness = 0.85 } -- unfocused-split-opacity
config.unzoom_on_switch_pane = false -- split-preserve-zoom = navigation

-- Shells: WSL's Ubuntu by default, starting in its home. The launch menu and
-- the other WSL distros are in the launcher: right-click the + on the tab bar.
local wsl = wezterm.default_wsl_domains()
for _, domain in ipairs(wsl) do
	domain.default_cwd = "~"
end
config.wsl_domains = wsl
config.default_domain = "WSL:Ubuntu-24.04"

-- Leave SSH_AUTH_SOCK alone. WezTerm otherwise points it at its own agent
-- proxy socket, which never gets created here, so ssh.exe (git's sshCommand)
-- can't reach 1Password's agent on \\.\pipe\openssh-ssh-agent.
config.mux_enable_ssh_agent = false

config.launch_menu = {
	{ label = "PowerShell", args = { "pwsh.exe", "-NoLogo" }, domain = { DomainName = "local" } },
	{ label = "Command Prompt", args = { "cmd.exe" }, domain = { DomainName = "local" } },
	{
		label = "Developer PowerShell for VS 18",
		args = {
			"pwsh.exe",
			"-NoLogo",
			"-NoExit",
			"-Command",
			'&{Import-Module "C:\\Program Files\\Microsoft Visual Studio\\18\\Professional\\Common7\\Tools\\Microsoft.VisualStudio.DevShell.dll"; Enter-VsDevShell e1590412 -SkipAutomaticLocation -DevCmdArguments "-arch=x64 -host_arch=x64"}',
		},
		domain = { DomainName = "local" },
	},
}

-- tmux-style prefix, as in Ghostty (and tmux.conf): ctrl+a, then a key.
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },
	{ key = "%", mods = "LEADER|SHIFT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = '"', mods = "LEADER|SHIFT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	{ key = "z", mods = "LEADER", action = act.TogglePaneZoomState },
	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = true }) },
	{ key = "c", mods = "LEADER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "n", mods = "LEADER", action = act.ActivateTabRelative(1) },
	{ key = "p", mods = "LEADER", action = act.ActivateTabRelative(-1) },
	{
		key = ",",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Tab title",
			action = wezterm.action_callback(function(window, _, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},
	{ key = "/", mods = "LEADER", action = act.Search("CurrentSelectionOrEmptyString") },
	{ key = "[", mods = "LEADER", action = act.ScrollToPrompt(-1) },
	{ key = "]", mods = "LEADER", action = act.ScrollToPrompt(1) },
	{ key = "r", mods = "LEADER", action = act.ReloadConfiguration },
	{ key = "a", mods = "LEADER|CTRL", action = act.SendKey({ key = "a", mods = "CTRL" }) },
	{ key = "R", mods = "LEADER|SHIFT", action = act.ActivateKeyTable({ name = "resize", one_shot = false }) },
}

-- Resize mode: ctrl+a R, then hjkl repeatedly, escape to leave.
config.key_tables = {
	resize = {
		{ key = "h", action = act.AdjustPaneSize({ "Left", 2 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 2 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 2 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 2 }) },
		{ key = "Escape", action = "PopKeyTable" },
	},
}

return config
