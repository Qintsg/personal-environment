# 项目 overlay
#
# 这里放所有项目级通用命令。

export def pj-root [] {
  project-root
}

export def pj-stack [] {
  detect-project-stack
}

export def pj-info [] {
  {
    root: (project-root)
    stack: (detect-project-stack)
    name: ($env.PROJECT_NAME? | default null)
    path: ($env.PROJECT_ROOT? | default null)
  }
}

