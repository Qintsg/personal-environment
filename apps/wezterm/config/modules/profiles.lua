local wezterm = require 'wezterm'
local util = require 'modules.util'

local M = {}

local cache = nil

local function trim(text)
  if text == nil then
    return ''
  end

  local trimmed = tostring(text):gsub('^%s+', ''):gsub('%s+$', '')
  return trimmed
end

local function file_exists(path)
  local handle = io.open(path, 'rb')
  if handle then
    handle:close()
    return true
  end
  return false
end

local function read_file(path)
  local handle, err = io.open(path, 'rb')
  if not handle then
    error(string.format('无法读取 %s：%s', path, err or '未知错误'))
  end

  local content = handle:read('*a')
  handle:close()
  return content
end

local function strip_comment(line)
  local in_quote = false
  local quote_char = nil
  local escaped = false
  local result = {}

  for i = 1, #line do
    local ch = line:sub(i, i)

    if escaped then
      table.insert(result, ch)
      escaped = false
    elseif ch == '\\' then
      table.insert(result, ch)
      escaped = true
    elseif in_quote then
      table.insert(result, ch)
      if ch == quote_char then
        in_quote = false
        quote_char = nil
      end
    elseif ch == '"' or ch == "'" then
      table.insert(result, ch)
      in_quote = true
      quote_char = ch
    elseif ch == '#' then
      break
    else
      table.insert(result, ch)
    end
  end

  return table.concat(result)
end

local function split_csv(text)
  local values = {}
  local current = {}
  local in_quote = false
  local quote_char = nil
  local escaped = false

  for i = 1, #text do
    local ch = text:sub(i, i)

    if escaped then
      table.insert(current, ch)
      escaped = false
    elseif ch == '\\' then
      table.insert(current, ch)
      escaped = true
    elseif in_quote then
      table.insert(current, ch)
      if ch == quote_char then
        in_quote = false
        quote_char = nil
      end
    elseif ch == '"' or ch == "'" then
      table.insert(current, ch)
      in_quote = true
      quote_char = ch
    elseif ch == ',' then
      table.insert(values, trim(table.concat(current)))
      current = {}
    else
      table.insert(current, ch)
    end
  end

  local tail = trim(table.concat(current))
  if tail ~= '' then
    table.insert(values, tail)
  end

  return values
end

local function parse_string(value)
  local quote = value:sub(1, 1)
  value = value:sub(2, -2)

  if quote == '"' then
    value = value
      :gsub('\\"', '"')
      :gsub('\\\\', '\\')
      :gsub('\\n', '\n')
      :gsub('\\t', '\t')
      :gsub('\\r', '\r')
  end

  return value
end

local function parse_value(raw)
  raw = trim(raw)
  if raw == '' then
    return ''
  end

  if raw == 'true' then
    return true
  end

  if raw == 'false' then
    return false
  end

  if tonumber(raw) then
    return tonumber(raw)
  end

  local first = raw:sub(1, 1)
  local last = raw:sub(-1)
  if (first == '"' and last == '"') or (first == "'" and last == "'") then
    return parse_string(raw)
  end

  if first == '[' and last == ']' then
    local inner = trim(raw:sub(2, -2))
    if inner == '' then
      return {}
    end

    local items = {}
    for _, item in ipairs(split_csv(inner)) do
      table.insert(items, parse_value(item))
    end
    return items
  end

  return raw
end

local function expand_env(value)
  if type(value) ~= 'string' or value == '' then
    return value
  end

  local home = wezterm.home_dir:gsub('\\', '/')
  value = value:gsub('^~/', home .. '/')
  value = value:gsub('^~$', home)
  value = value:gsub('%${([%w_]+)}', function(name)
    return os.getenv(name) or ''
  end)
  value = value:gsub('%%([%w_]+)%%', function(name)
    return os.getenv(name) or ''
  end)

  return value
end

local function first_existing(candidates)
  local command_fallback = nil
  local absolute_fallback = nil

  for _, candidate in ipairs(candidates) do
    local expanded = expand_env(candidate)
    if expanded ~= '' then
      if expanded:match('^[A-Za-z]:/') or expanded:match('^/') then
        absolute_fallback = absolute_fallback or expanded
        if file_exists(expanded) then
          return expanded
        end
      else
        command_fallback = command_fallback or expanded
      end
    end
  end

  return command_fallback or absolute_fallback
end

local function parse_profiles_toml(path)
  local text = read_file(path)
  local data = {
    default_profile = nil,
    profiles = {},
  }

  local current = data
  local pending_key = nil
  local pending_value = nil

  for line in text:gmatch('[^\r\n]+') do
    local cleaned = trim(strip_comment(line))
    if cleaned ~= '' then
      if pending_key then
        pending_value = pending_value .. ' ' .. cleaned
        if cleaned:sub(-1) == ']' then
          current[pending_key] = parse_value(pending_value)
          pending_key = nil
          pending_value = nil
        end
      elseif cleaned == '[[profiles]]' then
        current = {}
        table.insert(data.profiles, current)
      else
        local key, value = cleaned:match('^([%w_%-%.]+)%s*=%s*(.+)$')
        if key and value then
          if value:sub(1, 1) == '[' and value:sub(-1) ~= ']' then
            pending_key = key
            pending_value = value
          else
            current[key] = parse_value(value)
          end
        end
      end
    end
  end

  return data
end

local function build_spawn_command(profile)
  local kind = profile.type or 'command'
  local startup_cwd = expand_env(profile.cwd or wezterm.home_dir)
  local spawn = {
    cwd = startup_cwd,
  }

  if kind == 'ssh' then
    local program = first_existing(profile.program_candidates or { profile.program or 'ssh.exe' })
    local args = { program }

    if profile.use_ssh_config ~= false and profile.host and not profile.host_name then
      table.insert(args, profile.host)
    else
      if profile.port then
        table.insert(args, '-p')
        table.insert(args, tostring(profile.port))
      end
      if profile.user and profile.user ~= '' then
        table.insert(args, '-l')
        table.insert(args, profile.user)
      end
      if profile.identity_file and profile.identity_file ~= '' then
        table.insert(args, '-i')
        table.insert(args, expand_env(profile.identity_file))
      end
      if type(profile.extra_args) == 'table' then
        for _, arg in ipairs(profile.extra_args) do
          table.insert(args, tostring(arg))
        end
      end
      table.insert(args, profile.host_name or profile.host)
    end

    spawn.args = args
    return spawn
  end

  if kind == 'wsl' then
    spawn.args = {
      first_existing(profile.program_candidates or { profile.program or 'wsl.exe' }),
      '-d',
      profile.distribution,
    }
    if profile.starting_directory and profile.starting_directory ~= '' then
      table.insert(spawn.args, '--cd')
      table.insert(spawn.args, profile.starting_directory)
    end
    return spawn
  end

  local program = first_existing(profile.program_candidates or { profile.program })
  if not program or program == '' then
    return nil
  end

  -- 命令提示符单独处理，避免额外命令串导致标题或路径异常。
  if profile.id == 'cmd' or profile.icon == 'cmd' then
    local comspec = os.getenv('ComSpec') or program
    spawn.args = { comspec }
    spawn.cwd = startup_cwd
    return spawn
  end

  spawn.args = { program }
  if type(profile.args) == 'table' then
    for _, arg in ipairs(profile.args) do
      table.insert(spawn.args, tostring(arg))
    end
  end

  return spawn
end

local function profile_menu_label(profile)
  local icon_key = profile.icon or profile.type or profile.label or profile.id or 'terminal'
  local icon = util.icon_for_label(icon_key)
  local label = profile.label or profile.id or 'profile'
  return string.format('%s  %s', icon, label)
end

function M.load(path)
  if cache and cache.path == path then
    return cache.data
  end

  local parsed = parse_profiles_toml(path)
  local profiles = {}
  local default_profile = nil

  for _, profile in ipairs(parsed.profiles) do
    if profile.enabled ~= false then
      local spawn = build_spawn_command(profile)
      if spawn then
        profile.spawn = spawn
        profile.menu_label = profile_menu_label(profile)
        table.insert(profiles, profile)

        if profile.default == true then
          default_profile = profile
        end
      else
        wezterm.log_warn('忽略无法启动的终端配置：' .. (profile.id or profile.label or '<unknown>'))
      end
    end
  end

  if not default_profile and parsed.default_profile then
    for _, profile in ipairs(profiles) do
      if profile.id == parsed.default_profile then
        default_profile = profile
        break
      end
    end
  end

  default_profile = default_profile or profiles[1]

  local data = {
    default_profile = default_profile,
    profiles = profiles,
  }

  cache = {
    path = path,
    data = data,
  }

  return data
end

-- 应用启动配置，并同步生成 WezTerm 原生 launch_menu。
function M.apply(config)
  local path = wezterm.config_dir .. '/terminal-profiles.toml'
  local loaded = M.load(path)

  config.default_cwd = wezterm.home_dir
  if loaded.default_profile and loaded.default_profile.spawn and loaded.default_profile.spawn.args then
    config.default_prog = loaded.default_profile.spawn.args
  end

  config.launch_menu = {}
  for _, profile in ipairs(loaded.profiles) do
    table.insert(config.launch_menu, {
      label = profile.menu_label,
      args = profile.spawn.args,
      cwd = profile.spawn.cwd,
    })
  end

  return loaded
end

function M.get()
  local path = wezterm.config_dir .. '/terminal-profiles.toml'
  return M.load(path)
end

return M

