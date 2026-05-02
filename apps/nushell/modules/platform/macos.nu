# macOS 平台差异

if ((is-macos)) {
  $env.NU_PLATFORM = 'macos'

  export def open-finder [target?: string] {
    let path = ($target | default (pwd))
    ^open $path
  }

  export def open-browser [target: string] {
    ^open $target
  }

  export def copy-text [text: string] {
    $text | ^pbcopy
  }

  export def paste-text [] {
    ^pbpaste
  }
}

