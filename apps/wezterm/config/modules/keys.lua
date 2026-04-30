local util = require 'modules.util'

return function(wezterm, config)
  local act = wezterm.action

  config.keys = {
    -- 甯哥敤澶嶅埗绮樿创銆?    { key = 'c', mods = 'CTRL|SHIFT', action = act.CopyTo('Clipboard') },
    { key = 'v', mods = 'CTRL|SHIFT', action = act.PasteFrom('Clipboard') },

    -- Ctrl+C锛氭湁閫夊尯鏃跺鍒讹紝鍚﹀垯閫忎紶缁欏墠鍙扮▼搴忋€?    {
      key = 'c',
      mods = 'CTRL',
      action = wezterm.action_callback(function(window, pane)
        local has_selection = window:get_selection_text_for_pane(pane) ~= ''
        if has_selection then
          window:perform_action(act.CopyTo('Clipboard'), pane)
          window:perform_action(act.ClearSelection, pane)
        else
          window:perform_action(act.SendKey({ key = 'c', mods = 'CTRL' }), pane)
        end
      end),
    },
    { key = 'v', mods = 'CTRL',        action = act.PasteFrom('Clipboard') },

    -- 鏂板缓鏍囩椤垫椂鍥炲埌鐢ㄦ埛涓荤洰褰曘€?    {
      key = 't',
      mods = 'CTRL',
      action = act.SpawnCommandInNewTab({
        cwd = wezterm.home_dir,
      }),
    },

    -- 鍏抽棴鏍囩椤垫椂涓嶅啀浜屾纭銆?    { key = 'w', mods = 'CTRL',        action = act.CloseCurrentTab({ confirm = false }) },
    { key = 'W', mods = 'CTRL',        action = act.CloseCurrentTab({ confirm = false }) },
    { key = 'w', mods = 'CTRL|SHIFT',  action = act.CloseCurrentTab({ confirm = false }) },
    { key = 'W', mods = 'CTRL|SHIFT',  action = act.CloseCurrentTab({ confirm = false }) },
    { key = 'w', mods = 'SUPER',       action = act.CloseCurrentTab({ confirm = false }) },
    { key = 'W', mods = 'SUPER',       action = act.CloseCurrentTab({ confirm = false }) },
    { key = 'w', mods = 'SUPER|SHIFT', action = act.CloseCurrentTab({ confirm = false }) },
    { key = 'W', mods = 'SUPER|SHIFT', action = act.CloseCurrentTab({ confirm = false }) },

    -- 鎼滅储褰撳墠閫変腑鍐呭锛涙湭閫変腑鏃舵墦寮€绌烘悳绱€?    { key = 'f', mods = 'CTRL',        action = act.Search('CurrentSelectionOrEmptyString') },

    -- 鎵嬪姩璁剧疆褰撳墠鏍囩椤垫爣棰橈紝浼樺厛绾ч珮浜庤嚜鍔ㄦ爣棰樸€?    {
      key = 'e',
      mods = 'CTRL|SHIFT',
      action = act.PromptInputLine({
        description = '璇疯緭鍏ュ綋鍓嶆爣绛鹃〉鏍囬锛岀暀绌鸿〃绀烘竻闄ゆ墜鍔ㄦ爣棰?,
        action = wezterm.action_callback(function(window, _, line)
          if line ~= nil then
            local tab = window:active_tab()
            util.set_manual_tab_title(tab, line)
            tab:set_title(line)
          end
        end),
      }),
    },
    {
      key = 'Backspace',
      mods = 'CTRL|SHIFT',
      action = wezterm.action_callback(function(window, _)
        local tab = window:active_tab()
        util.set_manual_tab_title(tab, '')
        tab:set_title('')
      end),
    },

    -- 鏍囩椤靛垏鎹€?    { key = 'Tab',        mods = 'CTRL',       action = act.ActivateTabRelative(1) },
    { key = 'Tab',        mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
    { key = 'LeftArrow',  mods = 'ALT',        action = act.ActivateTabRelative(-1) },
    { key = 'RightArrow', mods = 'ALT',        action = act.ActivateTabRelative(1) },
  }
end

