# 项目 hooks
#
# 进入目录后自动：
# 1. 识别项目根目录
# 2. 识别语言栈
# 3. 尝试接入 direnv

def --env __project_env_refresh [] {
  let root = (project-root)
  if $root == null {
    hide-env PROJECT_ROOT --ignore-errors
    hide-env PROJECT_NAME --ignore-errors
    hide-env PROJECT_STACK --ignore-errors
    return
  }

  let stacks = (detect-project-stack)
  load-env {
    PROJECT_ROOT: $root
    PROJECT_NAME: ($root | path basename)
    PROJECT_STACK: ($stacks | str join ',')
  }
}

let current_hooks = ($env.config.hooks? | default {})
let current_env_change = ($current_hooks.env_change? | default {})
let current_pwd_hooks = ($current_env_change.PWD? | default [])

$env.config = (
  $env.config
  | merge {
      hooks: (
        $current_hooks
        | merge {
            env_change: (
              $current_env_change
              | merge {
                  PWD: (
                    $current_pwd_hooks
                    | append {||
                        __project_env_refresh
                        __apply_direnv
                        __prompt_venv_enter
                      }
                  )
                }
            )
          }
      )
    }
)

__project_env_refresh
__apply_direnv

