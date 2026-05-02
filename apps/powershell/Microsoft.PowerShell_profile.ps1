# PowerShell 7 Profile
#
# 使用单独的 Starship 配置，避免和 Nushell / Bash / CMD 的能力边界互相影响。

$env:STARSHIP_CONFIG = "$HOME/.config/starship.toml"
Invoke-Expression (&starship init powershell)

