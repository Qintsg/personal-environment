# 本机私有覆盖层示例
#
# 使用方式：
# 1. 复制本文件为 local.nu
# 2. 按需修改
# 3. 不要提交 local.nu

export-env {
  # 示例：代理
  # load-env {
  #   HTTP_PROXY: "http://127.0.0.1:7890"
  #   HTTPS_PROXY: "http://127.0.0.1:7890"
  # }
}

export def my-local-alias [] {
  print "这里放你自己的本机命令"
}

