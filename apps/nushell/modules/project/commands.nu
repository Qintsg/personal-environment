# 椤圭洰鍛戒护闆嗗悎

def repo-root [] {
  project-root
}

def repo-open [] {
  let root = (project-root)
  if $root != null {
    if ((is-windows)) {
      ^explorer.exe $root
    } else if ((is-wsl)) {
      open-in-explorer $root
    } else if ((is-macos)) {
      ^open $root
    } else if ((is-termux)) and (has-cmd termux-open) {
      ^termux-open $root
    } else {
      if (has-cmd xdg-open) {
        ^xdg-open $root
      } else if (has-cmd open) {
        ^open $root
      } else {
        print $"鏃犳硶鎵撳紑璺緞锛?$root)"
      }
    }
  }
}

def stack [] {
  detect-project-stack
}

