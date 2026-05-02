# Local per-user/per-machine overlay

export-env {
  let home_dir = ($env.HOME? | default ($env.USERPROFILE? | default ''))
  let path_name = if ('Path' in $env) { 'Path' } else { 'PATH' }
  let current_path = ($env | get -o $path_name | default [])
  let flutter_bin = if ($home_dir | is-empty) { '' } else { ($home_dir | path join 'development' 'flutter' 'bin') }

  if ($flutter_bin | is-not-empty) and ($flutter_bin | path exists) and (not ($flutter_bin in $current_path)) {
    load-env {
      PUB_HOSTED_URL: 'https://pub.flutter-io.cn'
      FLUTTER_STORAGE_BASE_URL: 'https://storage.flutter-io.cn'
      $path_name: ($current_path | prepend $flutter_bin)
    }
  }

  # Example proxy values:
  # load-env {
  #   HTTP_PROXY: "http://127.0.0.1:7890"
  #   HTTPS_PROXY: "http://127.0.0.1:7890"
  # }
}

export def local-alias-help [] {
  print "Add machine-specific aliases and wrappers here."
  print "Recommended categories: proxy helpers, local dev tools, company-network commands."
}

# Example templates:
# export def proxy-on [] {
#   load-env {
#     HTTP_PROXY: "http://127.0.0.1:7890"
#     HTTPS_PROXY: "http://127.0.0.1:7890"
#   }
# }
#
# export def proxy-off [] {
#   hide-env HTTP_PROXY --ignore-errors
#   hide-env HTTPS_PROXY --ignore-errors
# }
#
# export def dev-api-log [] {
#   tail -f C:/path/to/dev-api.log
# }

