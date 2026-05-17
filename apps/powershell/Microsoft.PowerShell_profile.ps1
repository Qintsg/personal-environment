# PowerShell Profile
#
# 浣跨敤鍗曠嫭鐨?Starship 閰嶇疆锛岄伩鍏嶅拰 Nushell / Bash / CMD 鐨勮兘鍔涜竟鐣屼簰鐩稿奖鍝嶃€?
$env:STARSHIP_CONFIG = "$HOME/.config/starship.toml"
Invoke-Expression (&starship init powershell)

# Import the Chocolatey Profile that contains the necessary code to enable
# tab-completions to function for `choco`.
# Be aware that if you are missing these lines from your profile, tab completion
# for `choco` will not function.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}

Set-Alias -Name sl -Value "C:\Program Files\sl\bin\sl.exe" -Option AllScope -Force
