# Carapace 集成
#
# 目标：
# 1. 只在少数更适合子命令/选项补全的命令上使用 carapace
# 2. 其它未知外部命令位置默认回退到文件路径补全
# 3. 遇到明显是路径输入时，优先给出路径候选

def __carapace_enabled_commands [] {
  [
    ssh
    docker
    kubectl
    npm
    pnpm
    cargo
    adb
    apt
    ufw
  ]
}

def __looks_like_path_token [token: string] {
  if ($token | is-empty) {
    return false
  }

  if ($token | str starts-with '~') {
    return true
  }

  if ($token | str starts-with './') or ($token | str starts-with '../') {
    return true
  }

  if ($token | str starts-with '.\\') or ($token | str starts-with '..\\') {
    return true
  }

  if ($token | str starts-with '/') or ($token | str starts-with '\\') {
    return true
  }

  if ($token | str contains '/') or ($token | str contains '\\') {
    return true
  }

  if ($token | str contains ':\\') or ($token | str contains ':/') {
    return true
  }

  false
}

def __path_fallback_completions [raw_token: string] {
  let token = (($raw_token | str trim -c '"') | str trim -c "'")
  let use_backslash = ($raw_token | str contains '\\')
  let normalized = ($token | str replace -a '\\' '/')
  let has_sep = ($normalized | str contains '/')

  if ($raw_token | str starts-with '-') {
    return []
  }

  let parent = if $has_sep {
    let candidate = ($normalized | path dirname)
    if $candidate == '' { '.' } else { $candidate }
  } else {
    '.'
  }

  let prefix = if $has_sep {
    $normalized | path basename
  } else {
    $normalized
  }

  let entries = (try { ls -a $parent } catch { [] })
  let lowered_prefix = ($prefix | str downcase)

  $entries
  | where {|item|
      let name = ($item.name | path basename)
      if ($lowered_prefix | is-empty) {
        true
      } else {
        ($name | str downcase | str starts-with $lowered_prefix)
      }
    }
  | get name
  | each {|full_name|
      let base = ($full_name | path basename)
      let output = if $has_sep {
        if $parent == '.' {
          $base
        } else {
          $parent + '/' + $base
        }
      } else {
        $base
      }

      if $use_backslash {
        $output | str replace -a '/' '\\'
      } else {
        $output
      }
    }
}

if (has-cmd carapace) {
  let enabled_commands = (__carapace_enabled_commands)

  let external_completer = {|spans|
    let command = ($spans | first | default '')
    let current = ($spans | last | default '')

    if ($command | is-empty) {
      return (__path_fallback_completions $current)
    }

    if ($command in $enabled_commands) and (not (__looks_like_path_token $current)) {
      let result = (^carapace $command nushell ...$spans | complete)
      if $result.exit_code == 0 and ($result.stdout | str trim) != '' {
        let parsed = ($result.stdout | from json)
        if ($parsed | length) > 0 {
          return $parsed
        }
      }
    }

    __path_fallback_completions $current
  }

  $env.config = (
    $env.config
    | merge {
        completions: (($env.config.completions? | default {}) | merge {
          external: (($env.config.completions.external? | default {}) | merge {
            enable: true
            max_results: 200
            completer: $external_completer
          })
        })
      }
  )
}

