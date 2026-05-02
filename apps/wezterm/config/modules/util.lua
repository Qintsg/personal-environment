local wezterm = require 'wezterm'
local nf = wezterm.nerdfonts

local M = {}

local manual_tab_titles = {}
local shell_cache = {}

local shell_exes = {
  ['nu'] = true,
  ['nu.exe'] = true,
  ['pwsh'] = true,
  ['pwsh.exe'] = true,
  ['powershell'] = true,
  ['powershell.exe'] = true,
  ['cmd'] = true,
  ['cmd.exe'] = true,
  ['bash'] = true,
  ['bash.exe'] = true,
  ['zsh'] = true,
  ['zsh.exe'] = true,
  ['fish'] = true,
  ['fish.exe'] = true,
  ['wsl'] = true,
  ['wsl.exe'] = true,
  ['ssh'] = true,
  ['ssh.exe'] = true,
}

local known_activities = {
  ['python'] = 'Python',
  ['python.exe'] = 'Python',
  ['python3'] = 'Python',
  ['python3.exe'] = 'Python',
  ['py'] = 'Python',
  ['py.exe'] = 'Python',
  ['node'] = 'Node.js',
  ['node.exe'] = 'Node.js',
  ['npm'] = 'Node.js',
  ['npm.cmd'] = 'Node.js',
  ['npx'] = 'Node.js',
  ['npx.cmd'] = 'Node.js',
  ['pnpm'] = 'Node.js',
  ['pnpm.cmd'] = 'Node.js',
  ['yarn'] = 'Node.js',
  ['yarn.cmd'] = 'Node.js',
  ['bun'] = 'Node.js',
  ['bun.exe'] = 'Node.js',
  ['deno'] = 'Node.js',
  ['deno.exe'] = 'Node.js',
  ['cargo'] = 'Rust',
  ['cargo.exe'] = 'Rust',
  ['rustc'] = 'Rust',
  ['rustc.exe'] = 'Rust',
  ['go'] = 'Go',
  ['go.exe'] = 'Go',
  ['java'] = 'Java',
  ['java.exe'] = 'Java',
  ['javac'] = 'Java',
  ['javac.exe'] = 'Java',
  ['gradle'] = 'Java',
  ['gradle.bat'] = 'Java',
  ['mvn'] = 'Java',
  ['mvn.cmd'] = 'Java',
  ['dart'] = 'Dart',
  ['dart.exe'] = 'Dart',
  ['flutter'] = 'Flutter',
  ['flutter.bat'] = 'Flutter',
  ['git'] = 'Git',
  ['git.exe'] = 'Git',
  ['lazygit'] = 'LazyGit',
  ['lazygit.exe'] = 'LazyGit',
  ['nvim'] = 'Neovim',
  ['nvim.exe'] = 'Neovim',
  ['vim'] = 'Vim',
  ['vim.exe'] = 'Vim',
  ['hx'] = 'Helix',
  ['hx.exe'] = 'Helix',
}

local function trim(text)
  if text == nil then
    return ''
  end

  return tostring(text):gsub('^%s+', ''):gsub('%s+$', '')
end

local function read_value(target, method_name, field_name)
  if target == nil then
    return nil
  end

  local fn = target[method_name]
  if type(fn) == 'function' then
    local ok, value = pcall(fn, target)
    if ok then
      return value
    end
  end

  return target[field_name]
end

local function cache_shell(target, label)
  local key = M.pane_key(target)
  if key and label and label ~= '' then
    shell_cache[key] = label
  end
  return label
end

local function cached_shell(target)
  local key = M.pane_key(target)
  if key then
    return shell_cache[key]
  end
  return nil
end

function M.basename(path)
  if not path or path == '' then
    return ''
  end

  local normalized = tostring(path):gsub('\\', '/')
  return normalized:match('([^/]+)$') or normalized
end

function M.clean_title(title)
  title = trim(title)
  if title == '' then
    return ''
  end

  title = title:gsub('^Administrator:?%s*', '')
  title = title:gsub('%s+[%-|:]%s+WezTerm$', '')
  return trim(title)
end

function M.pick_icon(candidates, fallback)
  for _, name in ipairs(candidates) do
    local icon = nf[name]
    if icon and icon ~= '' then
      return icon
    end
  end

  return fallback or ''
end

function M.process_name(target)
  return read_value(target, 'get_foreground_process_name', 'foreground_process_name') or ''
end

function M.process_exe(target)
  return M.basename(M.process_name(target)):lower()
end

function M.title(target)
  return M.clean_title(read_value(target, 'get_title', 'title') or '')
end

function M.domain_name(target)
  return read_value(target, 'get_domain_name', 'domain_name') or ''
end

function M.pane_key(target)
  return read_value(target, 'pane_id', 'pane_id')
end

function M.tab_key(target)
  return read_value(target, 'tab_id', 'tab_id')
end

-- 淇濆瓨浜哄伐璁剧疆鐨勬爣绛鹃〉鏍囬銆?function M.set_manual_tab_title(target, title)
  local key = M.tab_key(target)
  if not key then
    return
  end

  title = trim(title)
  if title == '' then
    manual_tab_titles[key] = nil
  else
    manual_tab_titles[key] = title
  end
end

function M.get_manual_tab_title(target)
  local key = M.tab_key(target)
  if key then
    return manual_tab_titles[key]
  end
  return nil
end

function M.current_working_dir(target)
  local value = read_value(target, 'get_current_working_dir', 'current_working_dir')
  if not value then
    return nil
  end

  if type(value) == 'table' then
    value = value.file_path or value.path or value.uri or tostring(value)
  elseif type(value) ~= 'string' then
    value = tostring(value)
  end

  if not value or value == '' then
    return nil
  end

  value = value:gsub('^file://[^/]*', '')
  value = value:gsub('%%(%x%x)', function(hex)
    return string.char(tonumber(hex, 16))
  end)
  if value:match('^/[A-Za-z]:/') then
    value = value:sub(2)
  end
  value = value:gsub('[\\/]+$', '')

  return value
end

-- 鍙繚鐣欐渶鍚庝竴绾х洰褰曞悕锛岀敤浜庨渶瑕佸睍绀哄伐浣滅洰褰曟椂鐨勭畝鐭舰寮忋€?function M.working_dir_name(target)
  local cwd = M.current_working_dir(target)
  if not cwd or cwd == '' then
    return nil
  end

  cwd = cwd:gsub('\\', '/')
  cwd = cwd:gsub('/+$', '')

  local home = wezterm.home_dir:gsub('\\', '/')
  if cwd == home then
    return '~'
  end

  if cwd:find(home .. '/', 1, true) == 1 then
    cwd = '~/' .. cwd:sub(#home + 2)
  end

  local last = nil
  for segment in cwd:gmatch('[^/]+') do
    if segment ~= '' then
      last = segment
    end
  end

  return last or cwd
end

function M.is_shell_exe(exe)
  return shell_exes[exe] == true
end

-- 鍒ゆ柇褰撳墠 pane 瀵瑰簲鐨?shell 绫诲瀷銆?function M.current_terminal_label(target)
  local exe = M.process_exe(target)
  local title = M.title(target):lower()
  local domain = M.domain_name(target)
  local proc = M.process_name(target):lower()

  if exe == 'nu' or exe == 'nu.exe' then
    return cache_shell(target, 'NuShell')
  end

  if exe == 'pwsh' or exe == 'pwsh.exe' or exe == 'powershell' or exe == 'powershell.exe' then
    return cache_shell(target, 'PowerShell')
  end

  if exe == 'cmd' or exe == 'cmd.exe' then
    return cache_shell(target, 'CMD')
  end

  if exe == 'ssh' or exe == 'ssh.exe' then
    return cache_shell(target, 'SSH')
  end

  if exe == 'bash' or exe == 'bash.exe' then
    if proc:find('git', 1, true) then
      return cache_shell(target, 'Git Bash')
    end
    if title:find('mingw64', 1, true) or title:find('msys', 1, true) then
      return cache_shell(target, 'mingw64')
    end
    return cache_shell(target, 'Bash')
  end

  if domain:match('^WSL:') then
    return cache_shell(target, domain:gsub('^WSL:', ''))
  end

  if domain:match('^SSH:') then
    return cache_shell(target, 'SSH')
  end

  if title:find('nushell', 1, true) then
    return cache_shell(target, 'NuShell')
  end

  if title:find('powershell', 1, true) or title:find('pwsh', 1, true) then
    return cache_shell(target, 'PowerShell')
  end

  if title:find('git bash', 1, true) then
    return cache_shell(target, 'Git Bash')
  end

  if title:find('mingw64', 1, true) or title:find('msys', 1, true) then
    return cache_shell(target, 'mingw64')
  end

  local previous_shell = cached_shell(target)
  if previous_shell then
    return previous_shell
  end

  if domain == 'local' then
    return 'Windows'
  end

  return 'Terminal'
end

function M.current_activity_label(target)
  local exe = M.process_exe(target)
  if exe == '' or M.is_shell_exe(exe) then
    return nil
  end

  return known_activities[exe]
end

function M.ssh_target(target)
  local title = M.title(target)
  if title ~= '' then
    local host = title:match('([^%s]+@[^%s]+)')
    if host then
      return host
    end
  end

  local domain = M.domain_name(target)
  if domain:match('^SSH:') then
    return domain:gsub('^SSH:', '')
  end

  return nil
end

-- 涓虹姸鎬佹爮銆佸惎鍔ㄨ彍鍗曠瓑浣嶇疆鎻愪緵缁熶竴鍥炬爣銆?function M.icon_for_label(label)
  local lower = (label or ''):lower()

  if lower == 'nushell' or lower == 'nu' then
    return M.pick_icon({ 'cod_terminal', 'dev_terminal' }, 'Nu')
  end

  if lower == 'powershell' or lower == 'pwsh' then
    return M.pick_icon({ 'cod_terminal_powershell', 'md_powershell', 'cod_terminal' }, 'PS')
  end

  if lower == 'cmd' or lower == 'command prompt' then
    return M.pick_icon({ 'cod_terminal_cmd', 'cod_terminal' }, 'C>')
  end

  if lower == 'git bash' or lower == 'git-bash' or lower == 'git' or lower == 'lazygit' then
    return M.pick_icon({ 'dev_git', 'cod_source_control', 'cod_git_branch' }, 'Git')
  end

  if lower == 'mingw64' or lower == 'msys' then
    return M.pick_icon({ 'md_microsoft_windows', 'cod_tools', 'dev_windows' }, 'Win')
  end

  if lower == 'bash' then
    return M.pick_icon({ 'cod_terminal_bash', 'cod_terminal' }, '$')
  end

  if lower == 'ssh' then
    return M.pick_icon({ 'cod_remote', 'cod_vm_connect', 'md_console_network' }, 'SSH')
  end

  if lower == 'linux' or lower:find('ubuntu', 1, true) or lower:find('wsl', 1, true) or lower:find('linux', 1, true) then
    return M.pick_icon({ 'cod_terminal_linux', 'linux_linux', 'cod_vm' }, 'WSL')
  end

  if lower == 'python' then
    return M.pick_icon({ 'dev_python', 'seti_python' }, 'Py')
  end

  if lower == 'node.js' then
    return M.pick_icon({ 'dev_nodejs', 'seti_nodejs' }, 'JS')
  end

  if lower == 'rust' then
    return M.pick_icon({ 'dev_rust', 'cod_settings_gear' }, 'Rs')
  end

  if lower == 'go' then
    return M.pick_icon({ 'seti_go', 'dev_go' }, 'Go')
  end

  if lower == 'java' then
    return M.pick_icon({ 'seti_java', 'dev_java' }, 'Jv')
  end

  if lower == 'dart' then
    return M.pick_icon({ 'seti_dart', 'dev_dart' }, 'Dt')
  end

  if lower == 'flutter' then
    return M.pick_icon({ 'seti_flutter', 'cod_rocket' }, 'Fl')
  end

  if lower == 'neovim' or lower == 'vim' or lower == 'helix' then
    return M.pick_icon({ 'custom_vim', 'dev_vim', 'cod_edit' }, 'Ed')
  end

  if lower == 'docker' then
    return M.pick_icon({ 'dev_docker', 'linux_docker' }, 'Dk')
  end

  return M.pick_icon({ 'cod_terminal', 'dev_terminal' }, 'Term')
end

return M

