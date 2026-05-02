# Python / uv 虚拟环境工作流
#
# 提供：
# - venv-create / venv-enter / venv-exit / venv-python
# - uv-create / uv-enter / uv-exit / uv-python
# - 自动检测 .venv 并提示进入

const __venv_activate_overlay = path self venv-activate-shim.nu

def __venv_dir [root: string] {
  ($root | path join '.venv')
}

def __venv_scripts_dir [root: string] {
  if ($nu.os-info.family == 'windows') {
    ($root | path join '.venv' 'Scripts')
  } else {
    ($root | path join '.venv' 'bin')
  }
}

def __venv_activate_path [root: string] {
  ((__venv_scripts_dir $root) | path join 'activate.nu')
}

def __venv_python_path [root: string] {
  if ($nu.os-info.family == 'windows') {
    ($root | path join '.venv' 'Scripts' 'python.exe')
  } else {
    ($root | path join '.venv' 'bin' 'python')
  }
}

def __venv_exists [root?: string] {
  let base = ($root | default (pwd))
  ((__venv_dir $base) | path exists)
}

def --env __venv_activate [label: string] {
  let root = (pwd)
  if not (__venv_exists $root) {
    print "当前目录没有 .venv"
    return
  }

  let activate_path = (__venv_activate_path $root)
  if not ($activate_path | path exists) {
    print $".venv 中缺少 activate.nu：($activate_path)"
    return
  }

  let path_name = if ('Path' in $env) { 'Path' } else { 'PATH' }
  let old_path = ($env | get $path_name)
  let old_prompt_command = ($env.PROMPT_COMMAND? | default null)

  open --raw $activate_path | save --force $__venv_activate_overlay
  overlay use --reload $__venv_activate_overlay as activate
  load-env {
    __VENV_OLD_PATH_NAME: $path_name
    __VENV_OLD_PATH: $old_path
    __VENV_OLD_PROMPT_COMMAND: $old_prompt_command
    PYTHON_ENV_PROVIDER: $label
  }

  let venv_path = (__venv_dir $root)
  print $"已通过 activate.nu 进入虚拟环境：($label) -> ($venv_path)"
}

def --env __venv_deactivate [] {
  if ($env.VIRTUAL_ENV? | is-empty) {
    return
  }

  let path_name = ($env.__VENV_OLD_PATH_NAME? | default (if ('Path' in $env) { 'Path' } else { 'PATH' }))
  let old_path = ($env.__VENV_OLD_PATH? | default null)
  let old_prompt_command = ($env.__VENV_OLD_PROMPT_COMMAND? | default null)

  try {
    deactivate
  } catch {
    print "当前没有可退出的 activate overlay"
  }

  if $old_path != null {
    load-env {
      $path_name: $old_path
    }
  }

  if $old_prompt_command == null {
    hide-env PROMPT_COMMAND --ignore-errors
  } else {
    load-env {
      PROMPT_COMMAND: $old_prompt_command
    }
  }

  hide-env __VENV_OLD_PATH_NAME --ignore-errors
  hide-env __VENV_OLD_PATH --ignore-errors
  hide-env __VENV_OLD_PROMPT_COMMAND --ignore-errors
  hide-env VIRTUAL_ENV --ignore-errors
  hide-env VIRTUAL_ENV_PROMPT --ignore-errors
  hide-env VIRTUAL_PREFIX --ignore-errors
  hide-env PYTHON_ENV_PROVIDER --ignore-errors
  print "已退出虚拟环境"
}

export def venv-create [] {
  let root = (pwd)
  let python_bin = if ((which python | is-empty)) {
    if ((which python3 | is-empty)) { null } else { (which python3 | get 0.path) }
  } else {
    (which python | get 0.path)
  }

  if $python_bin == null {
    print "未找到 Python，可执行文件不存在。"
    return
  }

  run-external $python_bin '-m' 'venv' (__venv_dir $root)
  print "已创建 .venv"
}

def --env venv-enter [] {
  __venv_activate 'venv'
}

def --env venv-exit [] {
  __venv_deactivate
}

export def venv-python [...args: string] {
  let root = (pwd)
  if not (__venv_exists $root) {
    print "当前目录没有 .venv"
    return
  }

  let py = (__venv_python_path $root)
  run-external $py ...$args
}

export def uv-create [] {
  let root = (pwd)
  if ((which uv | is-empty)) {
    print "当前环境未安装 uv。"
    return
  }

  run-external uv 'venv' (__venv_dir $root)
  print "已通过 uv 创建 .venv"
}

def --env uv-enter [] {
  __venv_activate 'uv'
}

def --env uv-exit [] {
  __venv_deactivate
}

export def uv-python [...args: string] {
  let root = (pwd)
  if not (__venv_exists $root) {
    print "当前目录没有 .venv"
    return
  }

  let py = (__venv_python_path $root)
  run-external $py ...$args
}

def __prompt_venv_enter [] {
  if ($env.VIRTUAL_ENV? | is-not-empty) {
    return
  }

  let root = (pwd)
  if (__venv_exists $root) {
    if (((__venv_activate_path $root) | path exists)) {
      if ((which uv | is-empty)) {
        print "检测到当前目录存在 .venv，可执行 venv-enter 进入虚拟环境。"
      } else {
        print "检测到当前目录存在 .venv，可执行 venv-enter 或 uv-enter 进入虚拟环境。"
      }
    } else {
      print "检测到当前目录存在 .venv，但缺少 activate.nu。"
    }
  }
}

