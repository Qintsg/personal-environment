# 閫氱敤甯姪鍑芥暟

export def has-cmd [name: string] {
  (which $name | is-not-empty)
}

export def command-path [name: string] {
  let hits = (which $name)
  if ($hits | is-empty) {
    null
  } else {
    $hits | get 0.path
  }
}

export def is-windows [] {
  $nu.os-info.family == 'windows'
}

export def is-macos [] {
  $nu.os-info.name == 'macos'
}

export def is-linux [] {
  $nu.os-info.name == 'linux'
}

export def is-wsl [] {
  if not ((is-linux)) {
    false
  } else {
    ((open /proc/version | str downcase) | str contains 'microsoft')
  }
}

export def is-ssh [] {
  (($env.SSH_CONNECTION? | default '') != '')
  or (($env.SSH_TTY? | default '') != '')
  or (($env.SSH_CLIENT? | default '') != '')
}

export def is-termux [] {
  if not ((is-linux)) {
    false
  } else {
    let prefix = ($env.PREFIX? | default '')
    let home = ($env.HOME? | default '')
    let termux_version = ($env.TERMUX_VERSION? | default '')
    let android_root = ($env.ANDROID_ROOT? | default '')

    (
      ($termux_version != '')
      or ($prefix | str starts-with '/data/data/com.termux/files/usr')
      or ($home | str starts-with '/data/data/com.termux/files/home')
      or (($android_root != '') and ($prefix | str contains 'com.termux'))
    )
  }
}

export def home-dir [] {
  if ($env.HOME? | is-not-empty) {
    $env.HOME
  } else {
    $env.USERPROFILE
  }
}

export def config-root [] {
  $nu.default-config-dir
}

export def docs-root [] {
  ($nu.default-config-dir | path join 'docs')
}

export def local-root [] {
  ($nu.default-config-dir | path join 'modules' 'local')
}

export def path-exists [value: string] {
  ($value | path exists)
}

export def project-root [] {
  if ((has-cmd git)) {
    let output = (^git rev-parse --show-toplevel | complete)
    if $output.exit_code == 0 {
      let root = ($output.stdout | str trim)
      if $root != '' {
        return $root
      }
    }
  }

  let pwd = (pwd)
  if (($pwd | path join '.git') | path exists) {
    return $pwd
  }

  null
}

export def detect-project-stack [] {
  let root = (project-root)
  if $root == null {
    return []
  }

  let markers = [
    { file: 'package.json', name: 'node' }
    { file: 'pnpm-lock.yaml', name: 'pnpm' }
    { file: 'pyproject.toml', name: 'python' }
    { file: 'requirements.txt', name: 'python' }
    { file: 'Cargo.toml', name: 'rust' }
    { file: 'go.mod', name: 'go' }
    { file: 'pom.xml', name: 'java' }
    { file: 'build.gradle', name: 'java' }
    { file: 'pubspec.yaml', name: 'dart' }
  ]

  $markers
  | where {|it| (($root | path join $it.file) | path exists) }
  | get name
  | uniq
}

