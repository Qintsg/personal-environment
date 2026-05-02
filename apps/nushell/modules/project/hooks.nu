# 椤圭洰 hooks
#
# 杩涘叆鐩綍鍚庤嚜鍔細
# 1. 璇嗗埆椤圭洰鏍圭洰褰?# 2. 璇嗗埆璇█鏍?# 3. 灏濊瘯鎺ュ叆 direnv

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

