# Windows 鍘熺敓骞冲彴宸紓

if ((is-windows)) {
  $env.NU_PLATFORM = 'windows'

  export def open-explorer [target?: string] {
    let path = ($target | default (pwd))
    ^explorer.exe $path
  }

  export def open-browser [target: string] {
    ^cmd /c start "" $target
  }

  export def copy-text [text: string] {
    $text | clip
  }

  export def paste-text [] {
    ^powershell -NoLogo -NoProfile -NonInteractive -Command Get-Clipboard
  }

  export def win-to-wsl [path: string] {
    if (has-cmd wsl) {
      ^wsl wslpath -a ($path | str replace --all '\' '\\')
    } else {
      $path
    }
  }

  export def open-wsl-project [path?: string] {
    let target = ($path | default (pwd))
    if (has-cmd wsl) {
      ^wsl bash -lc $"cd \"(win-to-wsl $target)\" && exec \$SHELL -l"
    }
  }
}

alias pwsh = powershell

