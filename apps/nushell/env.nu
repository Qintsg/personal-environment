# Nushell 环境入口
#
# 这里只放最薄的一层环境变量定义。
# 大多数行为配置都应放在 config.nu 和 modules 目录中。

$env.NU_CONFIG_ROOT = $nu.default-config-dir
$env.NU_MODULE_ROOT = ($nu.default-config-dir | path join 'modules')
$env.NU_DOC_ROOT = ($nu.default-config-dir | path join 'docs')
$env.NU_LOCAL_ROOT = ($nu.default-config-dir | path join 'modules' 'local')

let home_dir = if ($env.HOME? | is-not-empty) {
  $env.HOME
} else {
  $env.USERPROFILE
}
let is_windows = ($nu.os-info.family == 'windows')
let current_lang = ($env.LANG? | default '')
let nu_bin = (which nu | get -o 0.path)
let path_name = if ('Path' in $env) { 'Path' } else { 'PATH' }
let preferred_editor = if ((which nvim) | is-not-empty) {
  'nvim'
} else if ((which hx) | is-not-empty) {
  'hx'
} else if ((which vim) | is-not-empty) {
  'vim'
} else if ((which nano) | is-not-empty) {
  'nano'
} else if ((which code) | is-not-empty) {
  'code'
} else if $is_windows {
  'notepad'
} else {
  'vi'
}
$env.STARSHIP_CONFIG = ($home_dir | path join '.config' 'starship.toml')
$env.STARSHIP_CONTEXT_SCRIPT = ($home_dir | path join '.config' 'starship-context.nu')
$env.STARSHIP_CACHE = if $is_windows {
  ($env.LOCALAPPDATA? | default ($home_dir | path join 'AppData' 'Local') | path join 'starship')
} else {
  ($home_dir | path join '.cache' 'starship')
}
$env.EDITOR = $preferred_editor
$env.VISUAL = $preferred_editor
$env.GIT_EDITOR = $preferred_editor
if ($nu_bin | is-not-empty) {
  $env.SHELL = $nu_bin
}

let local_bin = ($home_dir | path join '.local' 'bin')
let current_path = ($env | get -o $path_name | default [])
if (not $is_windows) and ($local_bin | path exists) and (not ($local_bin in $current_path)) {
  load-env {
    $path_name: ($current_path | prepend $local_bin)
  }
}

$env.NU_SSH = (
  (($env.SSH_CONNECTION? | default '') != '')
  or (($env.SSH_TTY? | default '') != '')
  or (($env.SSH_CLIENT? | default '') != '')
)
$env.NU_TERMUX = (
  (($env.TERMUX_VERSION? | default '') != '')
  or ((($env.PREFIX? | default '') | str starts-with '/data/data/com.termux/files/usr'))
  or ((($env.HOME? | default '') | str starts-with '/data/data/com.termux/files/home'))
)

if ($current_lang == '') {
  $env.LANG = (if $is_windows { 'zh-CN' } else { 'zh_CN.UTF-8' })
} else if ((not $is_windows) and ($current_lang == 'zh-CN.UTF-8')) {
  $env.LANG = 'zh_CN.UTF-8'
}

