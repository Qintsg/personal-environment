# Python / uv 铏氭嫙鐜宸ヤ綔娴?#
# 鎻愪緵锛?# - venv-create / venv-enter / venv-exit / venv-python
# - uv-create / uv-enter / uv-exit / uv-python
# - 鑷姩妫€娴?.venv 骞舵彁绀鸿繘鍏?
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
    print "褰撳墠鐩綍娌℃湁 .venv"
    return
  }

  let activate_path = (__venv_activate_path $root)
  if not ($activate_path | path exists) {
    print $".venv 涓己灏?activate.nu锛?$activate_path)"
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
  print $"宸查€氳繃 activate.nu 杩涘叆铏氭嫙鐜锛?$label) -> ($venv_path)"
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
    print "褰撳墠娌℃湁鍙€€鍑虹殑 activate overlay"
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
  print "宸查€€鍑鸿櫄鎷熺幆澧?
}

export def venv-create [] {
  let root = (pwd)
  let python_bin = if ((which python | is-empty)) {
    if ((which python3 | is-empty)) { null } else { (which python3 | get 0.path) }
  } else {
    (which python | get 0.path)
  }

  if $python_bin == null {
    print "鏈壘鍒?Python锛屽彲鎵ц鏂囦欢涓嶅瓨鍦ㄣ€?
    return
  }

  run-external $python_bin '-m' 'venv' (__venv_dir $root)
  print "宸插垱寤?.venv"
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
    print "褰撳墠鐩綍娌℃湁 .venv"
    return
  }

  let py = (__venv_python_path $root)
  run-external $py ...$args
}

export def uv-create [] {
  let root = (pwd)
  if ((which uv | is-empty)) {
    print "褰撳墠鐜鏈畨瑁?uv銆?
    return
  }

  run-external uv 'venv' (__venv_dir $root)
  print "宸查€氳繃 uv 鍒涘缓 .venv"
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
    print "褰撳墠鐩綍娌℃湁 .venv"
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
        print "妫€娴嬪埌褰撳墠鐩綍瀛樺湪 .venv锛屽彲鎵ц venv-enter 杩涘叆铏氭嫙鐜銆?
      } else {
        print "妫€娴嬪埌褰撳墠鐩綍瀛樺湪 .venv锛屽彲鎵ц venv-enter 鎴?uv-enter 杩涘叆铏氭嫙鐜銆?
      }
    } else {
      print "妫€娴嬪埌褰撳墠鐩綍瀛樺湪 .venv锛屼絾缂哄皯 activate.nu銆?
    }
  }
}

