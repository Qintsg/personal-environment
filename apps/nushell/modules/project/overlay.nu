# 椤圭洰 overlay
#
# 杩欓噷鏀炬墍鏈夐」鐩骇閫氱敤鍛戒护銆?
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

