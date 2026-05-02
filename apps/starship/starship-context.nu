def __root [] {
  (pwd | str replace --all '\' '/')
}

def __has-current [root: string, markers: list<string>] {
  $markers | any {|marker| (($root | path join $marker) | path exists) }
}

def __has-nested [root: string, markers: list<string>] {
  $markers | any {|marker| ((glob $"($root)/*/($marker)") | is-not-empty) }
}

def __has-git-root [root: string] {
  (($root | path join '.git') | path exists)
}

def __is-termux [] {
  let prefix = ($env.PREFIX? | default '')
  let home = ($env.HOME? | default '')
  let termux_version = ($env.TERMUX_VERSION? | default '')

  (
    ($termux_version != '')
    or ($prefix | str starts-with '/data/data/com.termux/files/usr')
    or ($home | str starts-with '/data/data/com.termux/files/home')
  )
}

def __contexts [] {
  {
    python: {
      icon: '蟀尃'
      markers: ['pyproject.toml', 'requirements.txt', '.python-version', '.venv', 'venv', 'uv.lock', 'poetry.lock']
    }
    node: {
      icon: '蟀帣'
      markers: ['package.json', '.nvmrc', 'node_modules', 'pnpm-lock.yaml', 'yarn.lock', 'package-lock.json', 'npm-shrinkwrap.json', 'bun.lock', 'bun.lockb']
    }
    rust: {
      icon: '顬?
      markers: ['Cargo.toml', 'Cargo.lock']
    }
    java: {
      icon: '顗?
      markers: ['pom.xml', 'build.gradle', 'build.gradle.kts', 'settings.gradle', 'settings.gradle.kts', 'gradlew']
    }
    go: {
      icon: '顦?
      markers: ['go.mod', 'go.work']
    }
  }
}

def __context [kind: string] {
  (__contexts | get $kind)
}

def __context-active [kind: string] {
  let root = (__root)
  let ctx = (__context $kind)
  let current = (__has-current $root $ctx.markers)
  let nested = (__has-nested $root $ctx.markers)
  let has_git = (__has-git-root $root)

  $current or ($has_git and $nested)
}

def __context-icon [kind: string] {
  ((__context $kind).icon)
}

def __termux-label [] {
  if ('/etc/debian_version' | path exists) {
    'termux-debian'
  } else {
    'termux'
  }
}

def main [kind: string, action: string] {
  if $kind == 'termux' {
    if $action == 'check' {
      if (__is-termux) { exit 0 } else { exit 1 }
    }

    if not (__is-termux) {
      exit 1
    }

    if $action == 'label' {
      print (__termux-label)
      exit 0
    }

    exit 1
  }

  let ctx = (try { __context $kind } catch { null })
  if $ctx == null {
    exit 1
  }

  if $action == 'check' {
    if (__context-active $kind) { exit 0 } else { exit 1 }
  }

  if $action == 'icon' {
    if (__context-active $kind) {
      print (__context-icon $kind)
      exit 0
    } else {
      exit 1
    }
  }

  exit 1
}

