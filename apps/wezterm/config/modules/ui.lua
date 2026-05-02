return function(wezterm, config)
  local act = wezterm.action
  local fonts = require 'modules.fonts'

  -- 字体优先级：
  -- 1. JetBrainsMono Nerd Font
  -- 2. JetBrains Mono
  -- 3. Cascadia Mono
  -- 4. Maple Mono NF CN
  -- 5. Symbols Nerd Font Mono
  config.font_dirs = { wezterm.config_dir .. '/fonts' }
  config.font = wezterm.font_with_fallback(fonts.available_families())
  config.font_size = 14.0
  config.line_height = 1.0
  config.adjust_window_size_when_changing_font_size = false

  config.use_ime = true
  config.treat_left_ctrlalt_as_altgr = false

  -- 使用系统风格的集成标题栏按钮，减少边框占用。
  config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
  config.integrated_title_button_style = 'Windows'
  config.integrated_title_button_alignment = 'Right'
  config.integrated_title_buttons = { 'Hide', 'Maximize', 'Close' }

  -- 保持单行标签栏，右侧保留新建标签页按钮。
  config.enable_tab_bar = true
  config.hide_tab_bar_if_only_one_tab = false
  config.use_fancy_tab_bar = true
  config.show_tab_index_in_tab_bar = false
  config.show_new_tab_button_in_tab_bar = true

  -- 适度留白，保持更接近 Windows Terminal 的容器感。
  config.window_padding = {
    left = 12,
    right = 12,
    top = 8,
    bottom = 8,
  }

  -- 鼠标选择时只保留选择，不自动复制。
  -- Ctrl + 左键用于打开鼠标下方的超链接。
  config.mouse_bindings = {
    {
      event = { Down = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = act.Nop,
    },
    {
      event = { Down = { streak = 1, button = { WheelUp = 1 } } },
      mods = 'CTRL',
      action = act.IncreaseFontSize,
    },
    {
      event = { Down = { streak = 1, button = { WheelDown = 1 } } },
      mods = 'CTRL',
      action = act.DecreaseFontSize,
    },
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'CTRL',
      action = act.OpenLinkAtMouseCursor,
    },
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'NONE',
      action = act.Nop,
    },
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'SHIFT',
      action = act.Nop,
    },
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'ALT',
      action = act.Nop,
    },
    {
      event = { Up = { streak = 1, button = 'Left' } },
      mods = 'SHIFT|ALT',
      action = act.Nop,
    },
    {
      event = { Up = { streak = 2, button = 'Left' } },
      mods = 'NONE',
      action = act.Nop,
    },
    {
      event = { Up = { streak = 3, button = 'Left' } },
      mods = 'NONE',
      action = act.Nop,
    },
  }

  -- 关闭标签页或窗口时不再弹确认框。
  config.window_close_confirmation = 'NeverPrompt'
  config.skip_close_confirmation_for_processes_named = {
    'nu',
    'nu.exe',
    'pwsh',
    'pwsh.exe',
    'powershell',
    'powershell.exe',
    'cmd',
    'cmd.exe',
    'bash',
    'bash.exe',
    'wsl',
    'wsl.exe',
    'ssh',
    'ssh.exe',
  }

  -- 状态栏刷新频率保持适中，避免频繁采样影响交互。
  config.status_update_interval = 3000
  config.initial_cols = 120
  config.initial_rows = 32
end

