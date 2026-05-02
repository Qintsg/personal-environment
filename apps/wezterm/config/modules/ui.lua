return function(wezterm, config)
  local act = wezterm.action
  local fonts = require 'modules.fonts'

  -- 瀛椾綋浼樺厛绾э細
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

  -- 浣跨敤绯荤粺椋庢牸鐨勯泦鎴愭爣棰樻爮鎸夐挳锛屽噺灏戣竟妗嗗崰鐢ㄣ€?  config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
  config.integrated_title_button_style = 'Windows'
  config.integrated_title_button_alignment = 'Right'
  config.integrated_title_buttons = { 'Hide', 'Maximize', 'Close' }

  -- 淇濇寔鍗曡鏍囩鏍忥紝鍙充晶淇濈暀鏂板缓鏍囩椤垫寜閽€?  config.enable_tab_bar = true
  config.hide_tab_bar_if_only_one_tab = false
  config.use_fancy_tab_bar = true
  config.show_tab_index_in_tab_bar = false
  config.show_new_tab_button_in_tab_bar = true

  -- 閫傚害鐣欑櫧锛屼繚鎸佹洿鎺ヨ繎 Windows Terminal 鐨勫鍣ㄦ劅銆?  config.window_padding = {
    left = 12,
    right = 12,
    top = 8,
    bottom = 8,
  }

  -- 榧犳爣閫夋嫨鏃跺彧淇濈暀閫夋嫨锛屼笉鑷姩澶嶅埗銆?  -- Ctrl + 宸﹂敭鐢ㄤ簬鎵撳紑榧犳爣涓嬫柟鐨勮秴閾炬帴銆?  config.mouse_bindings = {
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

  -- 鍏抽棴鏍囩椤垫垨绐楀彛鏃朵笉鍐嶅脊纭妗嗐€?  config.window_close_confirmation = 'NeverPrompt'
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

  -- 鐘舵€佹爮鍒锋柊棰戠巼淇濇寔閫備腑锛岄伩鍏嶉绻侀噰鏍峰奖鍝嶄氦浜掋€?  config.status_update_interval = 3000
  config.initial_cols = 120
  config.initial_rows = 32
end

