local profiles = require 'modules.profiles'

return function(wezterm, config)
  local act = wezterm.action
  local loaded = profiles.apply(config)

  -- 鍙抽敭鏍囩鏍忕殑鍔犲彿鏃讹紝鍙樉绀虹敤鎴疯嚜瀹氫箟缁堢鍒楄〃锛屼笉浣跨敤 WezTerm 榛樿 Launcher銆?  wezterm.on('new-tab-button-click', function(window, pane, button)
    if button ~= 'Right' then
      return
    end

    local choices = {}
    for _, profile in ipairs(loaded.profiles or {}) do
      table.insert(choices, {
        id = profile.id,
        label = profile.menu_label,
      })
    end

    window:perform_action(
      act.InputSelector({
        title = '閫夋嫨瑕佹墦寮€鐨勭粓绔?,
        choices = choices,
        action = wezterm.action_callback(function(inner_window, inner_pane, id)
          if not id then
            return
          end

          for _, profile in ipairs((profiles.get().profiles or {})) do
            if profile.id == id then
              inner_window:perform_action(
                act.SpawnCommandInNewTab(profile.spawn),
                inner_pane
              )
              break
            end
          end
        end),
      }),
      pane
    )

    return false
  end)
end

