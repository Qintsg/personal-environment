# Termux / Android 平台差异
#
# 典型场景：
# - Termux 原生 shell
# - Termux 中的 Debian / proot 容器
# - 从上述环境发起的 SSH 客户端会话

if ((is-termux)) {
  $env.NU_PLATFORM = 'termux'

  export def open-browser [target: string] {
    if (has-cmd termux-open-url) {
      ^termux-open-url $target
    } else if (has-cmd xdg-open) {
      ^xdg-open $target
    }
  }

  export def copy-text [text: string] {
    if (has-cmd termux-clipboard-set) {
      $text | ^termux-clipboard-set
    } else if (has-cmd wl-copy) {
      $text | ^wl-copy
    } else if (has-cmd xclip) {
      $text | ^xclip -selection clipboard
    } else {
      $text
    }
  }

  export def paste-text [] {
    if (has-cmd termux-clipboard-get) {
      ^termux-clipboard-get
    } else if (has-cmd wl-paste) {
      ^wl-paste --no-newline
    } else if (has-cmd xclip) {
      ^xclip -selection clipboard -o
    } else {
      ''
    }
  }
}

