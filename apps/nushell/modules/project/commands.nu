# 项目命令集合

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
        print $"无法打开路径：($root)"
      }
    }
  }
}

def stack [] {
  detect-project-stack
}

