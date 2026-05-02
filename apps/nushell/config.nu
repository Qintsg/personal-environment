# Nushell 涓婚厤缃叆鍙?#
# 璁捐鍘熷垯锛?# 1. 鍏变韩鏍稿績閫昏緫
# 2. 骞冲彴宸紓鎷嗗埌鐙珛妯″潡
# 3. 鏈満绉佹湁淇℃伅鏀惧埌 local 瑕嗙洊灞?# 4. 椤圭洰鑳藉姏閫氳繃 hooks 鍜?overlay 鎺ュ叆

source modules/core/helpers.nu
source modules/shell/config.nu
source modules/shell/aliases.nu
# Starship 缁熶竴璧?vendor autoload 鎺ュ叆锛岄伩鍏嶄笌鎵嬪姩 PROMPT_* 璁剧疆閲嶅
source modules/platform/windows.nu
source modules/platform/unix.nu
source modules/platform/termux.nu
source modules/platform/wsl.nu
source modules/platform/macos.nu
source modules/integrations/carapace.nu
source modules/integrations/zoxide.nu
source modules/integrations/direnv.nu
source modules/integrations/atuin.nu
source modules/integrations/plugins.nu
overlay use modules/project/overlay.nu
source modules/project/commands.nu
source modules/project/venv.nu
source modules/project/hooks.nu

if ('modules/local/local.nu' | path exists) {
  overlay use modules/local/local.nu
}

