param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot)
)

$ErrorActionPreference = 'SilentlyContinue'

$userProfile = [Environment]::GetFolderPath('UserProfile')
$appData = [Environment]::GetFolderPath('ApplicationData')
$localAppData = [Environment]::GetFolderPath('LocalApplicationData')
$exported = New-Object System.Collections.Generic.List[string]
$skipped = New-Object System.Collections.Generic.List[string]

function ConvertTo-SafeContent {
    param([string]$Content)

    if ($null -eq $Content) { return '' }

    $safe = $Content -replace "`0", ''
    if ($userProfile) {
        $safe = $safe -replace [regex]::Escape($userProfile), '%USERPROFILE%'
        $safe = $safe -replace [regex]::Escape($userProfile.Replace('\', '/')), '%USERPROFILE%'
    }

    $safe = $safe -replace '(?i)[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}', '<email>'
    $safe = $safe -replace '(?i)(https?://)([^\s/@:]+):([^\s/@]+)@', '$1<redacted>@'
    $safe = $safe -replace '(?i)(Bearer\s+)[A-Za-z0-9._~+\-/]+=*', '$1<redacted>'
    $safe = $safe -replace '(?i)(authorization:\s*)(.+)', '$1<redacted>'

    $secretKeys = 'token|secret|password|passwd|api[_-]?key|apikey|credential|cookie|private[_-]?key|client[_-]?secret|access[_-]?key|refresh[_-]?token|auth[_-]?token|session[_-]?(id|token|key)'
    $safe = $safe -replace ("(?im)^([^\r\n#;]*(" + $secretKeys + ")[^\r\n:=]*\s*[:=]\s*).+$"), '$1<redacted>'
    $safe = $safe -replace ("(?im)(`"[^`"\r\n]*(" + $secretKeys + ")[^`"\r\n]*`"\s*:\s*)`"[^`"\r\n]*`""), '$1"<redacted>"'
    $safe = $safe -replace ("(?im)(`"[^`"\r\n]*(" + $secretKeys + ")[^`"\r\n]*`"\s*:\s*)[^,}\r\n]+"), '$1"<redacted>"'

    return $safe.TrimEnd() + "`n"
}

function Ensure-Directory {
    param([string]$Path)

    $dir = Split-Path -Parent $Path
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

function Write-SafeFile {
    param(
        [string]$Destination,
        [string]$Content,
        [string]$Label
    )

    $target = Join-Path $RepoRoot $Destination
    Ensure-Directory $target
    ConvertTo-SafeContent $Content | Set-Content -LiteralPath $target -Encoding UTF8
    $exported.Add($Label) | Out-Null
}

function Export-TextFile {
    param(
        [string]$Source,
        [string]$Destination,
        [string]$Label
    )

    if (-not (Test-Path -LiteralPath $Source)) { return }
    $content = Get-Content -LiteralPath $Source -Raw
    Write-SafeFile -Destination $Destination -Content $content -Label $Label
}

function Export-CommandOutput {
    param(
        [string]$Command,
        [string[]]$Arguments,
        [string]$Destination,
        [string]$Label
    )

    $cmd = Get-Command $Command -ErrorAction SilentlyContinue
    if (-not $cmd) { return }

    $output = & $Command @Arguments 2>&1 | Out-String
    if ([string]::IsNullOrWhiteSpace($output)) { return }
    Write-SafeFile -Destination $Destination -Content $output -Label $Label
}

function Export-TreeTextFiles {
    param(
        [string]$SourceRoot,
        [string]$DestinationRoot,
        [string[]]$Extensions,
        [string[]]$ExcludePathParts,
        [string]$LabelPrefix
    )

    if (-not (Test-Path -LiteralPath $SourceRoot)) { return }

    $resolvedRoot = (Resolve-Path -LiteralPath $SourceRoot).Path.TrimEnd('\', '/')

    Get-ChildItem -LiteralPath $SourceRoot -Recurse -File | ForEach-Object {
        $source = $_.FullName
        foreach ($part in $ExcludePathParts) {
            if ($source -like "*$part*") { return }
        }

        if ($Extensions -notcontains $_.Extension.ToLowerInvariant() -and $Extensions -notcontains $_.Name.ToLowerInvariant()) { return }

        $relative = $source.Substring($resolvedRoot.Length).TrimStart('\', '/')
        if ([string]::IsNullOrWhiteSpace($relative)) { return }

        $dest = Join-Path $DestinationRoot $relative
        Export-TextFile -Source $source -Destination $dest -Label "$LabelPrefix/$relative"
    }
}

# Direct file exports.
Export-TextFile -Source (Join-Path $userProfile '.gitconfig') -Destination 'apps/git/config.gitconfig' -Label 'git config'
Export-TextFile -Source (Join-Path $appData 'Code\User\settings.json') -Destination 'apps/visual-studio-code/settings.json' -Label 'vscode settings'
Export-TextFile -Source (Join-Path $appData 'Code\User\keybindings.json') -Destination 'apps/visual-studio-code/keybindings.json' -Label 'vscode keybindings'
Export-TextFile -Source (Join-Path $appData 'Code - Insiders\User\settings.json') -Destination 'apps/visual-studio-code-insiders/settings.json' -Label 'vscode insiders settings'
Export-TextFile -Source (Join-Path $appData 'Code - Insiders\User\keybindings.json') -Destination 'apps/visual-studio-code-insiders/keybindings.json' -Label 'vscode insiders keybindings'
Export-TextFile -Source (Join-Path $appData 'Cursor\User\settings.json') -Destination 'apps/cursor/settings.json' -Label 'cursor settings'
Export-TextFile -Source (Join-Path $appData 'Cursor\User\keybindings.json') -Destination 'apps/cursor/keybindings.json' -Label 'cursor keybindings'
Export-TextFile -Source (Join-Path $localAppData 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json') -Destination 'apps/windows-terminal/settings.json' -Label 'windows terminal settings'
Export-TextFile -Source (Join-Path $localAppData 'Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json') -Destination 'apps/windows-terminal-preview/settings.json' -Label 'windows terminal preview settings'
Export-TextFile -Source (Join-Path $userProfile '.config\starship.toml') -Destination 'apps/starship/starship.toml' -Label 'starship config'
Export-TextFile -Source (Join-Path $appData 'nushell\config.nu') -Destination 'apps/nushell/config.nu' -Label 'nushell config'
Export-TextFile -Source (Join-Path $appData 'nushell\env.nu') -Destination 'apps/nushell/env.nu' -Label 'nushell env'
Export-TextFile -Source (Join-Path $appData 'nushell\modules\shell\config.nu') -Destination 'apps/nushell/modules-shell-config.nu' -Label 'nushell module config'
Export-TextFile -Source (Join-Path $appData 'GitHub CLI\config.yml') -Destination 'apps/github-cli/config.yml' -Label 'github cli config'

# Profile exports.
$profilePaths = @(
    $PROFILE.CurrentUserAllHosts,
    $PROFILE.CurrentUserCurrentHost
) | Where-Object { $_ } | Select-Object -Unique

foreach ($profilePath in $profilePaths) {
    if (Test-Path -LiteralPath $profilePath) {
        $name = [System.IO.Path]::GetFileName($profilePath)
        Export-TextFile -Source $profilePath -Destination "apps/powershell/$name" -Label "powershell profile $name"
    }
}

# Directory exports for text-only configs.
Export-TreeTextFiles -SourceRoot (Join-Path $userProfile '.config\wezterm') -DestinationRoot 'apps/wezterm/config' -Extensions @('.lua', '.toml') -ExcludePathParts @('\fonts\') -LabelPrefix 'wezterm'
Export-TreeTextFiles -SourceRoot (Join-Path $localAppData 'nvim') -DestinationRoot 'apps/neovim/config' -Extensions @('.lua', '.json', '.toml', '.md', '.gitignore') -ExcludePathParts @('\.git\', '\bin\', '\screenshots\') -LabelPrefix 'neovim'

# Command exports.
Export-CommandOutput -Command 'code' -Arguments @('--list-extensions', '--show-versions') -Destination 'apps/visual-studio-code/extensions.md' -Label 'vscode extensions'
Export-CommandOutput -Command 'code-insiders' -Arguments @('--list-extensions', '--show-versions') -Destination 'apps/visual-studio-code-insiders/extensions.md' -Label 'vscode insiders extensions'
Export-CommandOutput -Command 'cursor' -Arguments @('--list-extensions', '--show-versions') -Destination 'apps/cursor/extensions.md' -Label 'cursor extensions'
Export-CommandOutput -Command 'scoop' -Arguments @('config') -Destination 'apps/scoop/config.md' -Label 'scoop config'
Export-CommandOutput -Command 'scoop' -Arguments @('bucket', 'list') -Destination 'apps/scoop/buckets.md' -Label 'scoop buckets'
Export-CommandOutput -Command 'choco' -Arguments @('config', 'list', '--limit-output') -Destination 'apps/chocolatey/config.md' -Label 'chocolatey config'
Export-CommandOutput -Command 'npm' -Arguments @('config', 'list', '--json') -Destination 'apps/npm/config.json' -Label 'npm config'
Export-CommandOutput -Command 'pnpm' -Arguments @('config', 'list', '--json') -Destination 'apps/pnpm/config.json' -Label 'pnpm config'
Export-CommandOutput -Command 'yarn' -Arguments @('config', 'list', '--json') -Destination 'apps/yarn/config.json' -Label 'yarn config'
Export-CommandOutput -Command 'python' -Arguments @('-m', 'pip', 'config', 'list') -Destination 'apps/python/pip-config.md' -Label 'pip config'
Export-CommandOutput -Command 'go' -Arguments @('env', '-json') -Destination 'apps/go/go-env.json' -Label 'go env'
Export-CommandOutput -Command 'rustup' -Arguments @('show') -Destination 'apps/rust/rustup-show.md' -Label 'rustup show'
Export-CommandOutput -Command 'cargo' -Arguments @('install', '--list') -Destination 'apps/rust/cargo-install-list.md' -Label 'cargo install list'
Export-CommandOutput -Command 'dotnet' -Arguments @('tool', 'list', '--global') -Destination 'apps/dotnet-sdk/global-tools.md' -Label 'dotnet global tools'
Export-CommandOutput -Command 'uv' -Arguments @('tool', 'list') -Destination 'apps/uv/tools.md' -Label 'uv tools'

# Docker Desktop exports. Registry credentials are intentionally skipped.
Export-TextFile -Source (Join-Path $appData 'Docker\settings-store.json') -Destination 'apps/docker-desktop/settings-store.json' -Label 'docker settings store'
Export-TextFile -Source (Join-Path $appData 'Docker\settings.json') -Destination 'apps/docker-desktop/settings.json' -Label 'docker settings'
Write-SafeFile -Destination 'apps/docker-desktop/credentials-skipped.md' -Content "# Docker credentials skipped`n`nSkipped `%USERPROFILE%\.docker\config.json` because it may contain registry credentials.`n" -Label 'docker credentials skipped note'

Write-SafeFile -Destination 'apps/github-cli/credentials-skipped.md' -Content "# GitHub CLI credentials skipped`n`nSkipped GitHub CLI `hosts.yml` because it may contain GitHub tokens.`n" -Label 'github cli credentials skipped note'

Write-SafeFile -Destination 'apps/azure-cli/credentials-skipped.md' -Content "# Azure CLI credentials skipped`n`nSkipped `%USERPROFILE%\.azure` because it may contain login state, subscription data, tokens, or tenant details.`n" -Label 'azure cli credentials skipped note'

Write-SafeFile -Destination 'apps/termius/credentials-skipped.md' -Content "# Termius credentials skipped`n`nSkipped Termius application data because it may contain SSH hosts, private keys, session logs, cookies, or sync state.`n" -Label 'termius credentials skipped note'

Write-SafeFile -Destination 'apps/ztools/config-skipped.md' -Content "# ZTools config skipped`n`nSkipped ZTools application data because it contains browser storage, cookies, cache files, clipboard images, local databases, and plugin runtime state. npm-installed ZTools packages are tracked separately.`n" -Label 'ztools config skipped note'

$summary = @()
$summary += '# Config Export Summary'
$summary += ''
$summary += "Exported at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$summary += ''
$summary += '## Exported'
$summary += ''
foreach ($item in $exported) { $summary += "- $item" }
$summary += ''
$summary += '## Safety Handling'
$summary += ''
$summary += '- User profile paths were replaced with `%USERPROFILE%`.'
$summary += '- Email addresses were replaced with `<email>`.'
$summary += '- Common token, password, secret, api key, cookie, and session fields were redacted.'
$summary += '- Known high-risk credential files were skipped.'

Write-SafeFile -Destination 'apps/config-export-summary.md' -Content ($summary -join "`n") -Label 'export summary'

Write-Host "Exported $($exported.Count) config item(s)."
