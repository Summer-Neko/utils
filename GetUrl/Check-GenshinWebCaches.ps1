try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
} catch {}

function Get-LogPath {
    $basePath   = Join-Path $env:USERPROFILE 'AppData\LocalLow\miHoYo'
    $globalPath = Join-Path $basePath 'Genshin Impact\output_log.txt'
    $chinaPath  = Join-Path $basePath '原神\output_log.txt'

    if (Test-Path $globalPath) {
        return $globalPath
    }
    elseif (Test-Path $chinaPath) {
        return $chinaPath
    }
    else {
        Write-Host "未找到原神日志文件：$basePath" -ForegroundColor Yellow
        return $null
    }
}

function Get-GameDirFromLog {
    param(
        [string]$LogPath
    )

    if (-not (Test-Path $LogPath)) {
        Write-Host "日志文件不存在：$LogPath" -ForegroundColor Yellow
        return $null
    }

    $content = Get-Content -Path $LogPath -Raw -ErrorAction Stop
    $regex   = [regex]'([A-Z]:\\.+?\\(GenshinImpact_Data|YuanShen_Data))'
    $match   = $regex.Match($content)

    if ($match.Success) {
        return $match.Groups[1].Value
    }
    else {
        Write-Host "无法从日志中解析游戏目录，请检查 output_log.txt 内容" -ForegroundColor Yellow
        return $null
    }
}

function Get-LatestWebCachesFolder {
    param(
        [string]$GameDir
    )

    $webCachesPath = Join-Path $GameDir 'webCaches'
    Write-Host "webCaches 路径：$webCachesPath" -ForegroundColor Cyan

    if (-not (Test-Path $webCachesPath)) {
        Write-Host "未找到 webCaches 目录，请确认游戏是否启动过。" -ForegroundColor Yellow
        return $null
    }

    $subdirs = Get-ChildItem -Path $webCachesPath -Directory -ErrorAction SilentlyContinue |
               Sort-Object LastWriteTime -Descending

    if (-not $subdirs -or $subdirs.Count -eq 0) {
        Write-Host "webCaches 目录中未找到任何子文件夹。" -ForegroundColor Yellow
        return $null
    }

    return $subdirs[0]
}

Write-Host "=== 原神路径诊断脚本 ===`n" -ForegroundColor Green

try {
    # 1. 日志路径
    $logPath = Get-LogPath
    if (-not $logPath) {
        return
    }
    Write-Host "日志文件路径：$logPath" -ForegroundColor Cyan

    # 2. 从日志解析游戏目录（*_Data）
    $gameDir = Get-GameDirFromLog -LogPath $logPath
    if (-not $gameDir) {
        return
    }
    Write-Host "解析出的游戏目录（包含 *_Data）：$gameDir" -ForegroundColor Cyan

    # 3. webCaches 目录 & 最新版本文件夹
    $latestFolder = Get-LatestWebCachesFolder -GameDir $gameDir
    if (-not $latestFolder) {
        return
    }
    Write-Host "最新 webCaches 版本目录：$($latestFolder.FullName)" -ForegroundColor Cyan

    # 4. data_2 缓存文件路径
    $cacheFilePath = Join-Path $latestFolder.FullName 'Cache\Cache_Data\data_2'
    Write-Host "data_2 缓存文件路径：$cacheFilePath" -ForegroundColor Cyan

    if (Test-Path $cacheFilePath) {
        Write-Host "`ndata_2 文件存在，可对照此路径检查 Electron/Node 代码。" -ForegroundColor Green
    }
    else {
        Write-Host "`n未找到 data_2 文件，请确认游戏已打开过祈愿记录页面。" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "脚本运行出错：$_" -ForegroundColor Red
}
