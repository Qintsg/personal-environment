# Global aliases and small cross-platform helpers

alias g = git
alias gs = git status --short --branch
alias gco = git checkout
alias gcb = git checkout -b
alias ga = git add
alias gaa = git add --all
alias gc = git commit
alias gcm = git commit -m
alias gd = git diff
alias gds = git diff --staged
alias gl = git pull
alias gp = git push
alias glog = git log --oneline --decorate --graph -20

alias rr = repo-root
alias ro = repo-open
alias pj = pj-info
alias pjr = pj-root
alias pjs = pj-stack

alias ll = ls -la
alias la = ls -a

alias fuck = thefuck
alias tk = taskkill /PID /F
alias tools = cd E:/Tools

alias q = exit
alias ubuntu = wsl.exe -d Ubuntu-26.04
alias ff = fastfetch

def __first-existing [candidates: list<string>] {
  let existing = ($candidates | where {|path| ($path | path exists) })
  if ($existing | is-empty) { null } else { $existing | first }
}

def --env project [] {
  let candidates = if (is-windows) {
    ['E:\Projects' ($env.USERPROFILE | path join 'projects')]
  } else if (is-wsl) {
    ['/mnt/e/Projects' '/mnt/c/Users/qinta/projects' ($env.HOME | path join 'projects')]
  } else {
    [($env.HOME | path join 'projects')]
  }
  let target = (__first-existing $candidates)

  if $target == null {
    print '未找到可用项目目录。'
  } else {
    cd $target
  }
}

def --env desktop [] {
  let candidates = if (is-windows) {
    [($env.USERPROFILE | path join 'Desktop')]
  } else if (is-wsl) {
    ['/mnt/c/Users/qinta/Desktop' ($env.HOME | path join 'Desktop')]
  } else {
    [($env.HOME | path join 'Desktop')]
  }
  let target = (__first-existing $candidates)

  if $target == null {
    print '未找到 Desktop 目录。'
  } else {
    cd $target
  }
}

def vi [...args: string] {
  let editor = if (has-cmd nvim) {
    'nvim'
  } else if (has-cmd vim) {
    'vim'
  } else if (has-cmd hx) {
    'hx'
  } else {
    $env.EDITOR
  }

  run-external $editor ...$args
}

def weather [] {
  ^curl -fsSL 'https://wttr.in/上海?lang=zh'
}

def wttr [] {
  ^curl -fsSL 'https://wttr.in/上海?lang=zh&0'
}

alias h = tldr

def --env up [] {
  cd ..
}

def --env up2 [] {
  cd ../..
}

def open-here [] {
  if (is-windows) {
    open-explorer
  } else if (is-wsl) {
    open-in-explorer
  } else if (is-macos) {
    open-finder
  } else {
    repo-open
  }
}

alias oh = open-here

