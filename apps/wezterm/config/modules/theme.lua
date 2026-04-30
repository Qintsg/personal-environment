return function(wezterm, config)
  -- 涓婚鍚嶇О锛欶luent Terminal Dark
  -- 鍙傝€冩柟鍚戯細
  -- 1. Windows Terminal 鐨勬繁鑹蹭腑鎬ф潗璐ㄦ劅鍜屾洿瀹炵殑椤堕儴妗嗘灦
  -- 2. 鏂囩珷閲屾彁鍒扮殑 WezTerm 鑳屾櫙妯＄硦鎬濊矾锛屾湰璐ㄤ笂杩樻槸瀹樻柟鐨?win32_system_backdrop
  -- 3. 瀹樻柟鏂囨。寤鸿 Mica/Tabbed 鍦?Windows 涓婃惌閰?window_background_opacity = 0 浣跨敤

  -- 鏇存帴杩?Windows Terminal 鐨?Win11 椋庢牸銆?  -- 姣旇捣 Acrylic锛屽畠鏇寸ǔ锛屼篃鏇翠笉瀹规槗鍑虹幇鍋忕櫧闆炬劅銆?  config.win32_system_backdrop = 'Tabbed'

  -- 鎸夊畼鏂瑰缓璁妸绯荤粺鑳屾櫙灞備氦缁?Windows 鏈韩銆?  config.window_background_opacity = 0
  config.text_background_opacity = 0

  -- 涓嶇敤绾壊瀹炲績鑳屾櫙锛屾敼鎴愭繁鑹蹭腑鎬ц挋鐗?+ 鏋佽交寰喎鑹叉煋灞傘€?  -- 杩欐牱鑳戒繚鐣欐瘺鐜荤拑锛屽悓鏃朵笉鑷充簬鎶婂唴瀹瑰尯娲楃櫧銆?  config.background = {
    {
      source = {
        Color = '#080c12',
      },
      width = '100%',
      height = '100%',
      opacity = 0.42,
    },
    {
      source = {
        Gradient = {
          colors = { '#10161f', '#141b24', '#0d131b' },
          orientation = { Linear = { angle = -12.0 } },
        },
      },
      width = '100%',
      height = '100%',
      opacity = 0.36,
    },
    {
      source = {
        Gradient = {
          colors = { '#1a2430', '#0d1218' },
          orientation = {
            Radial = {
              cx = 0.72,
              cy = 0.16,
              radius = 1.00,
            },
          },
        },
      },
      width = '100%',
      height = '100%',
      opacity = 0.03,
    },
  }

  -- 棰滆壊鍙傝€?Windows Terminal 鐨勬繁鑹蹭腑鎬у簳锛?  -- 涓昏儗鏅帴杩戠偔鐏拌摑锛屽己璋冭壊淇濈暀鍐疯摑銆?  config.colors = {
    foreground = '#F3F3F3',
    background = '#0d1218',
    cursor_bg = '#4CC2FF',
    cursor_fg = '#101010',
    cursor_border = '#4CC2FF',

    selection_fg = '#FFFFFF',
    selection_bg = '#5A5A5A',

    scrollbar_thumb = '#3A3A3A',
    split = '#2D3440',
    compose_cursor = '#4CC2FF',

    ansi = {
      '#1E1E1E',
      '#E56B6F',
      '#6CCB5F',
      '#D7BA7D',
      '#61AFEF',
      '#C678DD',
      '#56B6C2',
      '#D4D4D4',
    },

    brights = {
      '#6B6B6B',
      '#F28B8D',
      '#8AD47E',
      '#EFD28A',
      '#7CC7FF',
      '#D9A7F0',
      '#7FDDE6',
      '#FFFFFF',
    },

    tab_bar = {
      background = 'rgba(13, 17, 23, 0.80)',
      active_tab = {
        bg_color = 'rgba(20, 27, 39, 0.85)',
        fg_color = '#FFFFFF',
        intensity = 'Bold',
      },
      inactive_tab = {
        bg_color = 'rgba(11, 15, 21, 0.72)',
        fg_color = '#AEB7C7',
      },
      inactive_tab_hover = {
        bg_color = 'rgba(23, 29, 41, 0.82)',
        fg_color = '#F3F3F3',
      },
      new_tab = {
        bg_color = 'rgba(11, 15, 21, 0.72)',
        fg_color = '#AEB7C7',
      },
      new_tab_hover = {
        bg_color = 'rgba(27, 34, 48, 0.82)',
        fg_color = '#FFFFFF',
      },
    },
  }

  -- 椤舵爮鍜屾爣绛炬爮鏇村疄涓€浜涳紝妯′豢 Windows Terminal 閭ｇ妗嗘灦涓庡唴瀹瑰垎灞傘€?  config.window_frame = {
    font = wezterm.font({ family = 'Segoe UI', weight = 'Bold' }),
    font_size = 11.5,
    active_titlebar_bg = 'rgba(12, 16, 22, 0.78)',
    inactive_titlebar_bg = 'rgba(9, 13, 19, 0.69)',
  }
end

