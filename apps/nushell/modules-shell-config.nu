# Shell 涓婚厤缃?
$env.config = (
  $env.config
  | merge {
      show_banner: false
      buffer_editor: ($env.EDITOR? | default 'vi')
      edit_mode: emacs
      render_right_prompt_on_last_line: true
      shell_integration: (($env.config.shell_integration? | default {}) | merge {
        osc133: false
        osc633: false
      })
      history: (($env.config.history? | default {}) | merge {
        max_size: 200000
        sync_on_enter: true
        file_format: plaintext
        isolation: false
      })
      completions: (($env.config.completions? | default {}) | merge {
        case_sensitive: false
        quick: true
        partial: true
        algorithm: fuzzy
        external: (($env.config.completions.external? | default {}) | merge {
          enable: true
          max_results: 200
        })
      })
    }
)

