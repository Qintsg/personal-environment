local util = require 'modules.util'
local profiles = require 'modules.profiles'

local function trim(text)
  if text == nil then
    return ''
  end

  return tostring(text):gsub('^%s+', ''):gsub('%s+$', '')
end

local function basename(path)
  if not path or path == '' then
    return ''
  end

  local normalized = tostring(path):gsub('\\', '/')
  return normalized:match('([^/]+)$') or normalized
end

local function cwd_string(raw)
  if raw == nil then
    return nil
  end

  if type(raw) == 'table' then
    raw = raw.file_path or raw.path or raw.uri or tostring(raw)
  elseif type(raw) ~= 'string' then
    raw = tostring(raw)
  end

  if raw == '' then
    return nil
  end

  raw = raw:gsub('^file://[^/]*', '')
  raw = raw:gsub('%%(%x%x)', function(hex)
    return string.char(tonumber(hex, 16))
  end)
  if raw:match('^/[A-Za-z]:/') then
    raw = raw:sub(2)
  end

  raw = raw:gsub('\\', '/')
  raw = raw:gsub('/+$', '')
  return raw
end

local function preferred_wsl_label()
  local ok, loaded = pcall(profiles.get)
  if ok and loaded and loaded.profiles then
    for _, profile in ipairs(loaded.profiles) do
      if profile.type == 'wsl' and profile.distribution and profile.distribution ~= '' then
        return profile.distribution
      end
    end
  end

  return 'WSL'
end

local function ssh_target_from_pane(pane)
  local title = trim(pane.title or '')
  if title ~= '' then
    local host = title:match('([^%s]+@[^%s]+)')
    if host then
      return host:match('@(.+)$') or host
    end
  end

  local domain = pane.domain_name or ''
  if domain:match('^SSH:') then
    return domain:gsub('^SSH:', '')
  end

  return nil
end

-- 鏍囩椤佃鍒欎繚鎸佹瀬绠€锛?-- 1. 浜哄伐鏍囬浼樺厛
-- 2. 缁堢鍐呴儴涓诲姩淇敼杩囨爣棰樻椂浣跨敤璇ユ爣棰?-- 3. 鍚﹀垯鏄剧ず榛樿 shell 鍚嶇О
local function default_shell_name(pane)
  local exe = basename(pane.foreground_process_name or ''):lower()
  local title = trim(pane.title or ''):lower()
  local domain = pane.domain_name or ''
  local cwd = cwd_string(pane.current_working_dir) or ''

  if domain:match('^WSL:') then
    return domain:gsub('^WSL:', '')
  end

  if cwd:match('^/') then
    return preferred_wsl_label()
  end

  if exe == 'nu' or exe == 'nu.exe' or title:find('nushell', 1, true) then
    return 'NuShell'
  end

  if exe == 'pwsh' or exe == 'pwsh.exe' or exe == 'powershell' or exe == 'powershell.exe'
      or title:find('powershell', 1, true) or title:find('pwsh', 1, true) then
    return 'PowerShell'
  end

  if exe == 'cmd' or exe == 'cmd.exe' then
    return 'CMD'
  end

  if exe == 'ssh' or exe == 'ssh.exe' or domain:match('^SSH:') then
    return 'SSH'
  end

  if exe == 'bash' or exe == 'bash.exe' then
    local proc = (pane.foreground_process_name or ''):lower()
    if proc:find('git', 1, true) or title:find('git bash', 1, true) then
      return 'Git Bash'
    end
    if title:find('mingw64', 1, true) or title:find('msys', 1, true) then
      return 'mingw64'
    end
    return 'Bash'
  end

  if exe ~= '' then
    local name = exe:gsub('%.exe$', ''):gsub('%.cmd$', ''):gsub('%.bat$', '')
    if name ~= '' then
      return name
    end
  end

  return 'Terminal'
end

local function internal_title_candidate(pane, default_name)
  local title = trim(pane.title or '')
  if title == '' then
    return nil
  end

  local lower = title:lower()
  local exe = basename(pane.foreground_process_name or ''):lower()
  local exe_plain = exe:gsub('%.exe$', ''):gsub('%.cmd$', ''):gsub('%.bat$', '')
  local default_lower = (default_name or ''):lower()

  if lower == default_lower or lower == exe or lower == exe_plain then
    return nil
  end

  if lower == 'wezterm' or lower == 'terminal' then
    return nil
  end

  -- cmd銆乥ash銆乸wsh 甯稿父鎶婃爣棰樻敼鎴愯矾寰勶紝杩欑鎯呭喌浠嶇劧鍥為€€鍒伴粯璁ゅ悕绉般€?  if lower:match('^[a-z]:[\\/]') or lower:match('^/[a-z0-9._%-]+') or lower:match('^~[\\/]') then
    return nil
  end

  if lower:find(':/', 1, true) or lower:find(':\\', 1, true) then
    return nil
  end

  return title
end

local function title_for_tab(tab)
  local manual_title = util.get_manual_tab_title(tab)
  if manual_title and manual_title ~= '' then
    return manual_title
  end

  local pane = tab.active_pane
  if not pane then
    return 'Terminal'
  end

  local shell_name = default_shell_name(pane)
  local internal_title = internal_title_candidate(pane, shell_name)

  if shell_name == 'SSH' then
    local target = ssh_target_from_pane(pane)
    if target and target ~= '' then
      return string.format('SSH | %s', target)
    end
    if internal_title then
      return internal_title
    end
    return 'SSH'
  end

  if internal_title then
    return internal_title
  end

  return shell_name
end

return function(wezterm, config)
  config.tab_max_width = 36
  config.show_new_tab_button_in_tab_bar = true

  wezterm.on('format-tab-title', function(tab, _, _, _, hover, max_width)
    local ok, title_or_err = pcall(title_for_tab, tab)
    local title = ok and title_or_err or 'Tab Error'

    if not ok then
      wezterm.log_error('format-tab-title 鏍囬鐢熸垚澶辫触锛? .. tostring(title_or_err))
    end

    title = wezterm.truncate_right(title, math.max(8, max_width - 2))

    local bg = '#252525'
    local fg = '#B8B8B8'
    if tab.is_active then
      bg = '#2F2F2F'
      fg = '#FFFFFF'
    elseif hover then
      bg = '#303030'
      fg = '#F3F3F3'
    end

    return {
      { Background = { Color = bg } },
      { Foreground = { Color = fg } },
      { Text = string.format(' %s ', title) },
    }
  end)
end

