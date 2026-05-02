# Nushell 主配置入口
#
# 设计原则：
# 1. 共享核心逻辑
# 2. 平台差异拆到独立模块
# 3. 本机私有信息放到 local 覆盖层
# 4. 项目能力通过 hooks 和 overlay 接入

source modules/core/helpers.nu
source modules/shell/config.nu
source modules/shell/aliases.nu
# Starship 统一走 vendor autoload 接入，避免与手动 PROMPT_* 设置重复
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

