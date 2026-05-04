local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

local direction_keys = {
	h = "Left",
	j = "Down",
	k = "Up",
	l = "Right",
}

local function basename(path)
	return string.gsub(path or "", "(.*[/\\])(.*)", "%2")
end

local function foreground_process(pane)
	return basename(pane:get_foreground_process_name())
end

local function is_nvim(pane)
	return pane:get_user_vars().IS_NVIM == "true"
		or foreground_process(pane) == "nvim"
		or foreground_process(pane) == "vim"
end

local function is_tmux(pane)
	return foreground_process(pane) == "tmux"
end

local function split_nav(key)
	return {
		key = key,
		mods = "CTRL",
		action = wezterm.action_callback(function(window, pane)
			if is_nvim(pane) or is_tmux(pane) then
				window:perform_action(act.SendKey({ key = key, mods = "CTRL" }), pane)
			else
				window:perform_action(act.ActivatePaneDirection(direction_keys[key]), pane)
			end
		end),
	}
end

-- ---- basics ----
config.font = wezterm.font("JetBrainsMono Nerd Font")
config.font_size = 14
config.line_height = 1.08

config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = false

-- ---- tmux-style prefix: Ctrl-Space ----
config.leader = {
	key = "Space",
	mods = "CTRL",
	timeout_milliseconds = 1000,
}

config.keys = {
	-- Send literal Ctrl-Space with prefix + Ctrl-Space
	{
		key = "Space",
		mods = "LEADER|CTRL",
		action = act.SendKey({ key = "Space", mods = "CTRL" }),
	},

	-- ---- panes: tmux-style ----
	-- tmux % = left/right split
	{
		key = "%",
		mods = "LEADER|SHIFT",
		action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},

	-- tmux " = top/bottom split
	{
		key = '"',
		mods = "LEADER|SHIFT",
		action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
	},

	-- close pane
	{
		key = "x",
		mods = "LEADER",
		action = act.CloseCurrentPane({ confirm = true }),
	},

	-- zoom pane
	{
		key = "z",
		mods = "LEADER",
		action = act.TogglePaneZoomState,
	},

	-- move between panes
	{ key = "h", mods = "LEADER", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "LEADER", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "LEADER", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "LEADER", action = act.ActivatePaneDirection("Right") },

	-- smart-splits.nvim-aware pane navigation
	split_nav("h"),
	split_nav("j"),
	split_nav("k"),
	split_nav("l"),

	-- rotate panes
	{
		key = "Space",
		mods = "LEADER",
		action = act.RotatePanes("Clockwise"),
	},

	-- ---- tabs as tmux windows ----
	{
		key = "c",
		mods = "LEADER",
		action = act.SpawnTab("CurrentPaneDomain"),
	},
	{
		key = "&",
		mods = "LEADER|SHIFT",
		action = act.CloseCurrentTab({ confirm = true }),
	},
	{
		key = "n",
		mods = "LEADER",
		action = act.ActivateTabRelative(1),
	},
	{
		key = "p",
		mods = "LEADER",
		action = act.ActivateTabRelative(-1),
	},

	-- jump to tabs like tmux prefix + number
	{ key = "1", mods = "LEADER", action = act.ActivateTab(0) },
	{ key = "2", mods = "LEADER", action = act.ActivateTab(1) },
	{ key = "3", mods = "LEADER", action = act.ActivateTab(2) },
	{ key = "4", mods = "LEADER", action = act.ActivateTab(3) },
	{ key = "5", mods = "LEADER", action = act.ActivateTab(4) },
	{ key = "6", mods = "LEADER", action = act.ActivateTab(5) },
	{ key = "7", mods = "LEADER", action = act.ActivateTab(6) },
	{ key = "8", mods = "LEADER", action = act.ActivateTab(7) },
	{ key = "9", mods = "LEADER", action = act.ActivateTab(8) },

	-- rename tab
	{
		key = ",",
		mods = "LEADER",
		action = act.PromptInputLine({
			description = "Rename tab",
			action = wezterm.action_callback(function(window, pane, line)
				if line then
					window:active_tab():set_title(line)
				end
			end),
		}),
	},

	-- ---- copy/search ----
	{
		key = "[",
		mods = "LEADER",
		action = act.ActivateCopyMode,
	},
	{
		key = "/",
		mods = "LEADER",
		action = act.Search("CurrentSelectionOrEmptyString"),
	},

	-- ---- resize mode ----
	{
		key = "r",
		mods = "LEADER",
		action = act.ActivateKeyTable({
			name = "resize_pane",
			one_shot = false,
		}),
	},
}

config.key_tables = {
	resize_pane = {
		{ key = "h",          action = act.AdjustPaneSize({ "Left", 5 }) },
		{ key = "j",          action = act.AdjustPaneSize({ "Down", 5 }) },
		{ key = "k",          action = act.AdjustPaneSize({ "Up", 5 }) },
		{ key = "l",          action = act.AdjustPaneSize({ "Right", 5 }) },

		{ key = "LeftArrow",  action = act.AdjustPaneSize({ "Left", 5 }) },
		{ key = "DownArrow",  action = act.AdjustPaneSize({ "Down", 5 }) },
		{ key = "UpArrow",    action = act.AdjustPaneSize({ "Up", 5 }) },
		{ key = "RightArrow", action = act.AdjustPaneSize({ "Right", 5 }) },

		{ key = "Escape",     action = "PopKeyTable" },
		{ key = "q",          action = "PopKeyTable" },
		{ key = "Enter",      action = "PopKeyTable" },
	},
}

return config
