# Linux 骞冲彴鍏叡閫昏緫
#
# WSL銆乀ermux銆乵acOS 鏈夊悇鑷鐩栵紝閬垮厤鍚屽悕鍛戒护閲嶅瀹氫箟銆?
if ((is-linux) and (not (is-wsl)) and (not (is-termux))) {
  $env.NU_PLATFORM = 'linux'

  export def open-browser [target: string] {
    if (has-cmd xdg-open) {
      ^xdg-open $target
    } else if (has-cmd open) {
      ^open $target
    }
  }

  export def copy-text [text: string] {
    if (has-cmd wl-copy) {
      $text | ^wl-copy
    } else if (has-cmd xclip) {
      $text | ^xclip -selection clipboard
    } else if (has-cmd pbcopy) {
      $text | ^pbcopy
    } else {
      $text
    }
  }

  export def paste-text [] {
    if (has-cmd wl-paste) {
      ^wl-paste --no-newline
    } else if (has-cmd xclip) {
      ^xclip -selection clipboard -o
    } else if (has-cmd pbpaste) {
      ^pbpaste
    } else {
      ''
    }
  }
}

