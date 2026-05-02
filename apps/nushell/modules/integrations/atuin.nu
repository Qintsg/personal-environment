# Atuin 闆嗘垚
#
# 鍏堟彁渚涙樉寮忓懡浠ゅ叆鍙ｏ紝鍚庣画濡傞渶鏇存繁缁戝畾鍙互鍐嶆墿灞曘€?
if ((has-cmd atuin)) {
  def ah [] {
    ^atuin search --interactive
  }

  def hs [] {
    ^atuin history list
  }
}

