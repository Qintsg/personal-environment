# Termux / Android 骞冲彴宸紓
#
# 鍏稿瀷鍦烘櫙锛?# - Termux 鍘熺敓 shell
# - Termux 涓殑 Debian / proot 瀹瑰櫒
# - 浠庝笂杩扮幆澧冨彂璧风殑 SSH 瀹㈡埛绔細璇?
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

