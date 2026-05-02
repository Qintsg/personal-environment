# direnv 闆嗘垚
#
# 杩涘叆鐩綍鏃惰嚜鍔ㄥ姞杞介」鐩幆澧冨彉閲忋€?
def __direnv_winget_package_exe [] {
  if not (is-windows) {
    return null
  }

  let local_app_data = ($env.LOCALAPPDATA? | default '')
  if ($local_app_data | is-empty) {
    return null
  }

  let packages_root = ($local_app_data | path join 'Microsoft' 'WinGet' 'Packages')
  if not ($packages_root | path exists) {
    return null
  }

  let matches = (
    try {
      ls $packages_root
      | where type == dir
      | where {|it| (($it.name | path basename) | str starts-with 'direnv.direnv_') }
      | each {|it| $it.name | path join 'direnv.exe' }
      | where {|candidate| $candidate | path exists }
    } catch {
      []
    }
  )
  if ($matches | is-empty) {
    null
  } else {
    $matches | first
  }
}

def __direnv_command [] {
  let command = (command-path direnv)
  if $command == null {
    return null
  }

  let lower = ($command | str downcase)
  if (is-windows) and ($lower | str contains 'microsoft') and ($lower | str contains 'winget') and ($lower | str contains 'links') {
    let package_exe = (__direnv_winget_package_exe)
    if $package_exe != null {
      return $package_exe
    }

    if (is-ssh) {
      return null
    }
  }

  $command
}

def --env __apply_direnv [] {
  let direnv = (__direnv_command)
  if $direnv == null {
    return
  }

  let result = (run-external $direnv 'export' 'json' | complete)
  if $result.exit_code == 0 and ($result.stdout | str trim) != '' {
    let payload = ($result.stdout | from json)
    if ($payload | describe) == 'record' {
      load-env $payload
    }
  }
}

