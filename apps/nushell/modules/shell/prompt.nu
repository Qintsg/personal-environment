# Prompt 说明
#
# Starship 现统一通过 Nushell 的 vendor autoload 接入：
# - 自动加载目录：$nu.vendor-autoload-dirs
# - 当前生效文件：vendor/autoload/starship.nu
#
# 因此这里不再手动设置 PROMPT_COMMAND / PROMPT_COMMAND_RIGHT，
# 避免与 vendor autoload 形成两套并行接入逻辑。

