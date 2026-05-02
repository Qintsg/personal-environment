# WSL 骞冲彴宸紓

if ((is-wsl)) {
  $env.NU_PLATFORM = 'wsl'

  export def win-home [] {
    '/mnt/c/Users'
  }

  export def open-windows-browser [target: string] {
    ^cmd.exe /c start "" $target
  }

  export def wsl-to-win [path?: string] {
    let target = ($path | default (pwd))
    ^wslpath -w $target
  }

  export def open-in-explorer [path?: string] {
    let target = (wsl-to-win $path)
    ^explorer.exe $target
  }

  export def copy-text [text: string] {
    if (has-cmd clip.exe) {
      $text | ^clip.exe
    } else {
      $text
    }
  }
}

