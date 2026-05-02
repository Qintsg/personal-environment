# Atuin 集成
#
# 先提供显式命令入口，后续如需更深绑定可以再扩展。

if ((has-cmd atuin)) {
  def ah [] {
    ^atuin search --interactive
  }

  def hs [] {
    ^atuin history list
  }
}

