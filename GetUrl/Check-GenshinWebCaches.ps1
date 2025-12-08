function Write-CH {
    param([string]$Text, [ConsoleColor]$Color = "White")
    Write-Host $Text -ForegroundColor $Color
}

function Get-LogPath {
    $basePath   = Join-Path $env:USERPROFILE 'AppData\LocalLow\miHoYo'
    $globalPath = Join-Path $basePath 'Genshin Impact\output_log.txt'
    $chinaPath  = Join-Path $basePath '原神\output_log.txt'

    if (Test-Path $globalPath) { return $globalPath }
    if (Test-Path $chinaPath)  { return $chinaPath }

    Write-CH "未找到原神日志文件：$basePath" Yellow
    return $null
}

function Get-GameDirFromLog {
    param([string]$LogPath)

    if (-not (Test-Path $LogPath)) {
        Write-CH "日志文件不存在：$LogPath" Yellow
        return $null
    }

    $content = Get-Content $LogPath -Raw -ErrorAction Stop
    $regex   = [regex]'([A-Z]:\\.+?\\(GenshinImpact_Data|YuanShen_Data))'
    $match   = $regex.Match($content)

    if ($match.Success) { return $match.Groups[1].Value }

    Write-CH "无法从日志文件解析游戏目录，请检查 output_log.txt" Yellow
    return $null
}

function Get-LatestWebCachesFolder {
    param([string]$GameDir)

    $webCaches = Join-Path $GameDir 'webCaches'
    Write-CH "webCaches 路径：$webCaches" Cyan

    if (-not (Test-Path $webCaches)) {
        Write-CH "未找到 webCaches 目录，请确认游戏是否启动过。" Yellow
        return $null
    }

    $subdirs = Get-ChildItem $webCaches -Directory -ErrorAction SilentlyContinue |
               Sort-Object LastWriteTime -Descending

    if (-not $subdirs) {
        Write-CH "webCaches 目录为空。" Yellow
        return $null
    }

    return $subdirs[0]
}

Write-CH "=== 原神路径诊断脚本 ===`n" Green

try {
    # 1. 日志路径
    $logPath = Get-LogPath
    if (-not $logPath) { return }
    Write-CH "日志路径：$logPath" Cyan

    # 2. 游戏目录
    $gameDir = Get-GameDirFromLog $logPath
    if (-not $gameDir) { return }
    Write-CH "解析出的游戏目录：$gameDir" Cyan

    # 3. 最新 webCaches 子目录
    $latest = Get-LatestWebCachesFolder $gameDir
    if (-not $latest) { return }
    Write-CH "最新 webCaches 版本目录：$($latest.FullName)" Cyan

    # 4. data_2 路径
    $dataPath = Join-Path $latest.FullName 'Cache\Cache_Data\data_2'
    Write-CH "data_2 路径：$dataPath" Cyan

    if (Test-Path $dataPath) {
        Write-CH "`ndata_2 找到，可用于祈愿记录解析。" Green
    } else {
        Write-CH "`ndata_2 文件不存在，请确保点开过祈愿记录界面。" Yellow
    }
}
catch {
    Write-CH "运行出错：$_" Red
}
