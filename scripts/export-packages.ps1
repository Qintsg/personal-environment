param(
    [string]$RepoRoot = (Split-Path -Parent $PSScriptRoot),
    [switch]$AddNewWingetDocs
)

$ErrorActionPreference = 'Continue'

$userProfile = [Environment]::GetFolderPath('UserProfile')
$appRoot = Join-Path $RepoRoot 'apps'
$inventoryRoot = 'apps/_inventory'
$exported = New-Object System.Collections.Generic.List[string]
$updatedDocs = New-Object System.Collections.Generic.List[string]
$skipped = New-Object System.Collections.Generic.List[string]

function ConvertTo-SafeContent {
    param([string]$Content)

    if ($null -eq $Content) { return '' }

    $safe = $Content -replace "`0", ''
    if ($userProfile) {
        $safe = $safe -replace [regex]::Escape($userProfile), '%USERPROFILE%'
        $safe = $safe -replace [regex]::Escape($userProfile.Replace('\', '/')), '%USERPROFILE%'
    }
    $safe = $safe -replace '(?i)C:\\\\Users\\\\[^\\/"\r\n]+', '%USERPROFILE%'
    $safe = $safe -replace '(?i)C:\\Users\\[^\\/"\r\n]+', '%USERPROFILE%'
    $safe = $safe -replace '(?i)C:/Users/[^/\\":\r\n]+', '%USERPROFILE%'

    $safe = $safe -replace '(?i)[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}', '<email>'
    $secretKeys = 'secret|password|passwd|api[_-]?key|apikey|authorization|credential|cookie|private[_-]?key|client[_-]?secret|access[_-]?key|access[_-]?token|refresh[_-]?token|auth[_-]?token|session[_-]?(id|token|key)|(^|[_\.-])token([_\.-]|$)'
    $safe = $safe -replace ("(?im)^(\s*[A-Za-z0-9_.-]*(" + $secretKeys + ")[A-Za-z0-9_.-]*\s*[:=]\s*).+$"), '$1<redacted>'
    $safe = $safe -replace ("(?im)(^|[,{]\s*)(`"[^`"\r\n:,{]*(" + $secretKeys + ")[^`"\r\n:,{]*`"\s*:\s*)`"[^`"\r\n]*`""), '$1$2"<redacted>"'
    $safe = $safe -replace ("(?im)(^|[,{]\s*)(`"[^`"\r\n:,{]*(" + $secretKeys + ")[^`"\r\n:,{]*`"\s*:\s*)[^,}\r\n]+"), '$1$2"<redacted>"'

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
    $safe = ConvertTo-SafeContent $Content

    $old = $null
    if (Test-Path -LiteralPath $target) {
        $old = Get-Content -LiteralPath $target -Raw
    }

    if ($old -ne $safe) {
        Set-Content -LiteralPath $target -Value $safe -Encoding UTF8
    }
    $exported.Add($Label) | Out-Null
}

function Invoke-ToolText {
    param(
        [string]$Command,
        [string[]]$Arguments
    )

    $cmd = Get-Command $Command -ErrorAction SilentlyContinue
    if (-not $cmd) {
        $skipped.Add("$Command not found") | Out-Null
        return $null
    }

    try {
        return (& $Command @Arguments 2>&1 | Out-String)
    } catch {
        $skipped.Add("$Command failed: $($_.Exception.Message)") | Out-Null
        return $null
    }
}

function ConvertTo-Slug {
    param(
        [string]$Name,
        [string]$Prefix = ''
    )

    $raw = ''
    if ($null -ne $Name) { $raw = $Name }
    $text = $raw.ToLowerInvariant()
    $text = $text -replace '^@', ''
    $text = $text -replace '[/\\@+_.\s]+', '-'
    $text = $text -replace '[^a-z0-9-]', ''
    $text = $text -replace '-+', '-'
    $text = $text.Trim('-')
    if ([string]::IsNullOrWhiteSpace($text)) { $text = 'unknown-package' }
    if ($Prefix -and -not $text.StartsWith("$Prefix-")) { $text = "$Prefix-$text" }
    return $text
}

function ConvertTo-Key {
    param([string]$Value)
    $raw = ''
    if ($null -ne $Value) { $raw = $Value }
    return ($raw.ToLowerInvariant() -replace '[^a-z0-9\u4e00-\u9fff]+', '')
}

function Get-AppIndex {
    $index = @{
        ByPackage = @{}
        ByTitle = @{}
        BySlug = @{}
        Titles = @{}
    }

    if (-not (Test-Path -LiteralPath $appRoot)) { return $index }

    Get-ChildItem -LiteralPath $appRoot -Directory | Where-Object { -not $_.Name.StartsWith('_') } | ForEach-Object {
        $slug = $_.Name
        $install = Join-Path $_.FullName 'install.md'
        $index.BySlug[$slug.ToLowerInvariant()] = $slug
        if (-not (Test-Path -LiteralPath $install)) { return }

        $content = Get-Content -LiteralPath $install -Raw
        $title = $slug
        if ($content -match '(?m)^#\s+(.+?)\s*$') {
            $title = $Matches[1].Trim()
        }
        $index.Titles[$slug] = $title
        $titleKey = ConvertTo-Key $title
        if ($titleKey) { $index.ByTitle[$titleKey] = $slug }

        if ($content -match '(?m)^-\s*包 ID：\s*`?([^`\r\n]+?)`?\s*$') {
            $pkg = $Matches[1].Trim()
            if ($pkg -and $pkg -ne '待补充') {
                $index.ByPackage[$pkg.ToLowerInvariant()] = $slug
            }
        }
    }

    return $index
}

function Resolve-AppSlug {
    param(
        [hashtable]$Index,
        [string]$PackageId,
        [string]$Title,
        [string]$Prefix,
        [bool]$AllowCreate
    )

    if ($PackageId) {
        $pkgKey = $PackageId.ToLowerInvariant()
        if ($Index.ByPackage.ContainsKey($pkgKey)) { return $Index.ByPackage[$pkgKey] }
    }

    if ($Title) {
        $titleKey = ConvertTo-Key $Title
        if ($Index.ByTitle.ContainsKey($titleKey)) { return $Index.ByTitle[$titleKey] }
    }

    $slugSource = $Title
    if ($PackageId) { $slugSource = $PackageId }
    $slug = ConvertTo-Slug -Name $slugSource -Prefix $Prefix
    if ($Index.BySlug.ContainsKey($slug.ToLowerInvariant())) { return $Index.BySlug[$slug.ToLowerInvariant()] }
    if (-not $AllowCreate) { return $null }
    return $slug
}

function Format-PackageIdLine {
    param([string]$PackageId)
    if ([string]::IsNullOrWhiteSpace($PackageId)) { return '- 包 ID：待补充' }
    return "- 包 ID：``$PackageId``"
}

function Set-InstallDoc {
    param(
        [string]$Slug,
        [string]$Title,
        [string]$Source,
        [string]$Version,
        [string]$PackageId,
        [string]$InstallCommand,
        [string]$Note
    )

    if ([string]::IsNullOrWhiteSpace($Slug)) { return }
    $destination = "apps/$Slug/install.md"
    $target = Join-Path $RepoRoot $destination
    Ensure-Directory $target

    if ([string]::IsNullOrWhiteSpace($Version)) { $Version = '待补充' }
    if ([string]::IsNullOrWhiteSpace($Source)) { $Source = '本机命令扫描' }
    if ([string]::IsNullOrWhiteSpace($InstallCommand)) { $InstallCommand = '# 需要手动安装；后续可补充确认过的安装来源。' }
    if ([string]::IsNullOrWhiteSpace($Note)) { $Note = '当前记录来自本机同步脚本。' }

    $recordBlock = (@(
        '## 当前记录'
        ''
        "- 来源：$Source"
        "- 当前版本：$Version"
        (Format-PackageIdLine $PackageId)
    ) -join "`n") + "`n`n"

    $installBlock = (@(
        '## 安装方式'
        ''
        '```powershell'
        $InstallCommand
        '```'
    ) -join "`n") + "`n`n"

    if (Test-Path -LiteralPath $target) {
        $content = Get-Content -LiteralPath $target -Raw
        if ($content -match '(?m)^#\s+(.+?)\s*$') {
            $Title = $Matches[1].Trim()
        }
        if ($content -match '(?ms)^## 当前记录.*?(?=^## |\z)') {
            $content = $content -replace '(?ms)^## 当前记录.*?(?=^## |\z)', $recordBlock
        } else {
            $content = $content.TrimEnd() + "`n`n$recordBlock"
        }
        if ($content -match '(?ms)^## 安装方式.*?(?=^## |\z)') {
            $content = $content -replace '(?ms)^## 安装方式.*?(?=^## |\z)', $installBlock
        } else {
            $content = $content.TrimEnd() + "`n`n$installBlock"
        }
    } else {
        $content = "# $Title`n`n"
        $content += "## 默认平台`n`n"
        $content += "默认安装平台为 Windows；本文件中的安装命令默认在 Windows PowerShell 中执行。`n`n"
        $content += $recordBlock
        $content += $installBlock
        $content += "## 备注`n`n"
        $content += "- $Note`n"
    }

    $safe = ConvertTo-SafeContent $content
    $old = $null
    if (Test-Path -LiteralPath $target) {
        $old = Get-Content -LiteralPath $target -Raw
    }
    if ($old -ne $safe) {
        Set-Content -LiteralPath $target -Value $safe -Encoding UTF8
    }
    $updatedDocs.Add($destination) | Out-Null
}

function Export-RegistryInventory {
    $paths = @(
        'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
        'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*'
    )

    $items = foreach ($path in $paths) {
        Get-ItemProperty -Path $path -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName } | ForEach-Object {
            [pscustomobject]@{
                Name = $_.DisplayName
                Version = $_.DisplayVersion
                Publisher = $_.Publisher
                InstallLocation = $_.InstallLocation
                RegistryKey = $_.PSChildName
                Scope = if ($path -like 'HKCU:*') { 'CurrentUser' } else { 'LocalMachine' }
                SystemComponent = $_.SystemComponent
            }
        }
    }

    $json = $items | Sort-Object Name, Version -Unique | ConvertTo-Json -Depth 5
    Write-SafeFile -Destination "$inventoryRoot/registry-installed-programs.json" -Content $json -Label 'registry installed programs'
}

function Export-AppxInventory {
    $cmd = Get-Command Get-AppxPackage -ErrorAction SilentlyContinue
    if (-not $cmd) {
        $skipped.Add('Get-AppxPackage not found') | Out-Null
        return
    }

    $items = Get-AppxPackage | Select-Object Name, PackageFullName, Version, Publisher, Architecture, IsFramework, NonRemovable, InstallLocation
    $json = $items | Sort-Object Name, Version -Unique | ConvertTo-Json -Depth 5
    Write-SafeFile -Destination "$inventoryRoot/appx-packages.json" -Content $json -Label 'appx packages'
}

function Update-AppsReadmeCount {
    param([int]$AppCount)

    $path = Join-Path $RepoRoot 'apps/README.md'
    if (-not (Test-Path -LiteralPath $path)) { return }

    $content = Get-Content -LiteralPath $path -Raw
    $updated = $content -replace '当前已根据本机扫描结果生成 \d+ 个软件目录', "当前已根据本机扫描结果生成 $AppCount 个软件目录"
    if ($updated -ne $content) {
        Set-Content -LiteralPath $path -Value $updated -Encoding UTF8
    }
}

$index = Get-AppIndex

# winget: keep a complete importable manifest, but only update existing app docs by default.
$wingetTemp = Join-Path ([System.IO.Path]::GetTempPath()) ("winget-export-" + [guid]::NewGuid().ToString() + ".json")
$wingetText = Invoke-ToolText -Command 'winget' -Arguments @('export', '--output', $wingetTemp, '--include-versions', '--accept-source-agreements', '--disable-interactivity')
if (Test-Path -LiteralPath $wingetTemp) {
    $wingetJson = Get-Content -LiteralPath $wingetTemp -Raw
    Remove-Item -LiteralPath $wingetTemp -Force
    Write-SafeFile -Destination "$inventoryRoot/winget-export.json" -Content $wingetJson -Label 'winget export'

    $winget = $wingetJson | ConvertFrom-Json
    foreach ($source in @($winget.Sources)) {
        foreach ($pkg in @($source.Packages)) {
            $id = [string]$pkg.PackageIdentifier
            $slug = Resolve-AppSlug -Index $index -PackageId $id -Title $id -Prefix '' -AllowCreate ([bool]$AddNewWingetDocs)
            if (-not $slug) { continue }
            Set-InstallDoc -Slug $slug -Title $id -Source 'winget' -Version ([string]$pkg.Version) -PackageId $id -InstallCommand "winget install --id $id --exact --accept-package-agreements --accept-source-agreements --disable-interactivity" -Note '当前记录来自 winget export。'
        }
    }
}
if ($wingetText) {
    Write-SafeFile -Destination "$inventoryRoot/winget-export.log" -Content $wingetText -Label 'winget export log'
}

# scoop has structured JSON through `scoop export`.
$scoopText = Invoke-ToolText -Command 'scoop' -Arguments @('export')
if ($scoopText) {
    Write-SafeFile -Destination "$inventoryRoot/scoop-export.json" -Content $scoopText -Label 'scoop export'
    $scoop = $scoopText | ConvertFrom-Json
    foreach ($app in @($scoop.apps)) {
        $name = [string]$app.Name
        $source = [string]$app.Source
        $command = if ($source -and $source -ne 'main') { "scoop bucket add $source`nscoop install $name" } else { "scoop install $name" }
        $slug = Resolve-AppSlug -Index $index -PackageId $name -Title $name -Prefix '' -AllowCreate $true
        Set-InstallDoc -Slug $slug -Title $name -Source "scoop $source".Trim() -Version ([string]$app.Version) -PackageId $name -InstallCommand $command -Note '当前记录来自 Scoop 清单。'
    }
}

$chocoText = Invoke-ToolText -Command 'choco' -Arguments @('list', '--local-only', '--limit-output')
if ($chocoText) {
    Write-SafeFile -Destination "$inventoryRoot/choco-list.txt" -Content $chocoText -Label 'chocolatey packages'
    foreach ($line in ($chocoText -split "`r?`n")) {
        if ($line -notmatch '^([^|]+)\|(.+)$') { continue }
        $id = $Matches[1].Trim()
        $slug = Resolve-AppSlug -Index $index -PackageId $id -Title $id -Prefix '' -AllowCreate $false
        if (-not $slug) { continue }
        Set-InstallDoc -Slug $slug -Title $id -Source 'choco' -Version ($Matches[2].Trim()) -PackageId $id -InstallCommand "choco install $id -y" -Note '当前记录来自 Chocolatey 清单。'
    }
}

$npmText = Invoke-ToolText -Command 'npm' -Arguments @('list', '-g', '--depth=0', '--json')
if ($npmText) {
    Write-SafeFile -Destination "$inventoryRoot/npm-global.json" -Content $npmText -Label 'npm global packages'
    $npm = $npmText | ConvertFrom-Json
    foreach ($prop in $npm.dependencies.PSObject.Properties) {
        $name = [string]$prop.Name
        $version = [string]$prop.Value.version
        $slug = Resolve-AppSlug -Index $index -PackageId $name -Title $name -Prefix 'npm' -AllowCreate $true
        Set-InstallDoc -Slug $slug -Title $name -Source 'npm 全局包' -Version $version -PackageId $name -InstallCommand "npm install -g $name" -Note '当前记录来自 npm 全局包清单。'
    }
}

$pnpmText = Invoke-ToolText -Command 'pnpm' -Arguments @('list', '-g', '--depth=0', '--json')
if ($pnpmText) { Write-SafeFile -Destination "$inventoryRoot/pnpm-global.json" -Content $pnpmText -Label 'pnpm global packages' }

$yarnText = Invoke-ToolText -Command 'yarn' -Arguments @('global', 'list', '--depth=0')
if ($yarnText) { Write-SafeFile -Destination "$inventoryRoot/yarn-global.txt" -Content $yarnText -Label 'yarn global packages' }

$cargoText = Invoke-ToolText -Command 'cargo' -Arguments @('install', '--list')
if ($cargoText) {
    Write-SafeFile -Destination "$inventoryRoot/cargo-install-list.txt" -Content $cargoText -Label 'cargo install list'
    foreach ($line in ($cargoText -split "`r?`n")) {
        if ($line -notmatch '^([^\s]+)\s+v?([^:]+):') { continue }
        $id = $Matches[1].Trim()
        $slug = Resolve-AppSlug -Index $index -PackageId $id -Title $id -Prefix '' -AllowCreate $true
        Set-InstallDoc -Slug $slug -Title $id -Source 'cargo install' -Version ($Matches[2].Trim()) -PackageId $id -InstallCommand "cargo install $id" -Note '当前记录来自 cargo install --list。'
    }
}

$dotnetText = Invoke-ToolText -Command 'dotnet' -Arguments @('tool', 'list', '--global')
if ($dotnetText) {
    Write-SafeFile -Destination "$inventoryRoot/dotnet-global-tools.txt" -Content $dotnetText -Label 'dotnet global tools'
    foreach ($line in ($dotnetText -split "`r?`n")) {
        if ($line -match '^\s*$' -or $line -match '^-+$' -or $line -match '包 ID|Package Id') { continue }
        $parts = $line -split '\s+'
        if ($parts.Count -lt 2) { continue }
        $id = $parts[0].Trim()
        $version = $parts[1].Trim()
        $slug = Resolve-AppSlug -Index $index -PackageId $id -Title $id -Prefix '' -AllowCreate $true
        Set-InstallDoc -Slug $slug -Title $id -Source 'dotnet tool' -Version $version -PackageId $id -InstallCommand "dotnet tool install --global $id" -Note '当前记录来自 dotnet tool list --global。'
    }
}

$uvText = Invoke-ToolText -Command 'uv' -Arguments @('tool', 'list')
if ($uvText) { Write-SafeFile -Destination "$inventoryRoot/uv-tools.txt" -Content $uvText -Label 'uv tools' }

$pipText = Invoke-ToolText -Command 'python' -Arguments @('-m', 'pip', 'list', '--format=json')
if ($pipText) { Write-SafeFile -Destination "$inventoryRoot/pip-list.json" -Content $pipText -Label 'python pip packages' }

$goPathText = Invoke-ToolText -Command 'go' -Arguments @('env', 'GOPATH')
if ($goPathText) {
    $goBin = Join-Path $goPathText.Trim() 'bin'
    if (Test-Path -LiteralPath $goBin) {
        $goBins = Get-ChildItem -LiteralPath $goBin -File | Select-Object Name, Length, LastWriteTime | ConvertTo-Json -Depth 3
        Write-SafeFile -Destination "$inventoryRoot/go-bin.json" -Content $goBins -Label 'go bin tools'
    }
}

$installedModuleCmd = Get-Command Get-InstalledModule -ErrorAction SilentlyContinue
if ($installedModuleCmd) {
    $modules = Get-InstalledModule -ErrorAction SilentlyContinue | Select-Object Name, Version, Repository, InstalledLocation
    if ($modules) {
        Write-SafeFile -Destination "$inventoryRoot/powershell-installed-modules.json" -Content ($modules | ConvertTo-Json -Depth 5) -Label 'powershell installed modules'
    }
}

Export-RegistryInventory
Export-AppxInventory

$appCount = (Get-ChildItem -LiteralPath $appRoot -Directory | Where-Object { -not $_.Name.StartsWith('_') } | Measure-Object).Count
Update-AppsReadmeCount -AppCount $appCount
$summary = @()
$summary += '# Package Export Summary'
$summary += ''
$summary += "Exported at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$summary += ''
$summary += "Tracked app directories: $appCount"
$summary += ''
$summary += '## Exported Inventories'
$summary += ''
foreach ($item in $exported) { $summary += "- $item" }
$summary += ''
$summary += '## Updated Install Docs'
$summary += ''
foreach ($item in ($updatedDocs | Sort-Object -Unique)) { $summary += "- $item" }
$summary += ''
$summary += '## Skipped'
$summary += ''
if ($skipped.Count -eq 0) {
    $summary += '- None.'
} else {
    foreach ($item in $skipped) { $summary += "- $item" }
}
$summary += ''
$summary += '## Notes'
$summary += ''
$summary += '- `winget export` is saved as an importable manifest. New winget app directories are only created when `-AddNewWingetDocs` is passed, to avoid adding runtime frameworks and Store components by default.'
$summary += '- Registry, AppX, pip, pnpm, yarn, Go binary, and PowerShell module outputs are inventory snapshots; they are not converted one-by-one into app directories.'
$summary += '- User profile paths and common secret-like fields are redacted before files are written.'

Write-SafeFile -Destination 'apps/package-export-summary.md' -Content ($summary -join "`n") -Label 'package export summary'

Write-Host "Exported $($exported.Count) inventory item(s); updated $($updatedDocs | Sort-Object -Unique | Measure-Object | Select-Object -ExpandProperty Count) install doc(s)."
