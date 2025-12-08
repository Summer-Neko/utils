[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ErrorActionPreference = "Stop"

Write-Host "=== 原神祈愿链接环境自检脚本 ===`n"

function Get-LogPath {
    $basePath = Join-Path $env:USERPROFILE "AppData\LocalLow\miHoYo"
    $globalLog = Join-Path $basePath "Genshin Impact\output_log.txt"
    $cnLog     = Join-Path $basePath "原神\output_log.txt"

    Write-Host "尝试查找日志文件..."
    Write-Host "Global 日志路径预期为: $globalLog"
    Write-Host "国服日志路径预期为:   $cnLog`n"

    if (Test-Path $globalLog) {
        Write-Host "✅ 找到 Global 版本日志文件:"
        Write-Host "    $globalLog`n"
        return $globalLog
    }
    elseif (Test-Path $cnLog) {
        Write-Host "✅ 找到 国服 版本日志文件:"
        Write-Host "    $cnLog`n"
        return $cnLog
    }
    else {
        Write-Host "❌ 未在默认位置找到原神日志文件。"
        Write-Host "   请确认游戏至少启动过一次。`n"
        return $null
    }
}

function Get-GameDirFromLog([string]$logPath) {
    Write-Host "正在从日志中解析游戏目录 (gameDir)..."
    try {
        $content = Get-Content -Path $logPath -Raw -ErrorAction Stop
    }
    catch {
        Write-Host "❌ 读取日志文件失败: $($_.Exception.Message)`n"
        return $null
    }

    # 与你的 Node 代码保持一致的正则
    $pattern = '([A-Z]:\\.+?\\(GenshinImpact_Data|YuanShen_Data))'
    $match = [regex]::Match($content, $pattern)

    if (-not $match.Success) {
        Write-Host "❌ 无法从日志中解析出游戏目录。"
        Write-Host "   建议：重新启动游戏几分钟后再运行本脚本。`n"
        return $null
    }

    $gameDir = $match.Groups[1].Value
    Write-Host "✅ 解析到的游戏目录 (gameDir):"
    Write-Host "    $gameDir`n"
    return $gameDir
}

function Test-WebCaches([string]$gameDir) {
    $webCachesPath = Join-Path $gameDir "webCaches"
    Write-Host "预期 webCaches 路径为:"
    Write-Host "    $webCachesPath"

    if (-not (Test-Path $webCachesPath)) {
        Write-Host "❌ 未找到 webCaches 目录。"
        Write-Host "   可能原因："
        Write-Host "   1) 游戏重装或移动路径后，旧日志仍指向旧目录；"
        Write-Host "   2) 曾用清理工具/手动删除过 webCaches；"
        Write-Host "   3) 当前账号/用户目录与实际玩游戏的账号不一致。`n"

        $parent = Split-Path $gameDir -Parent
        Write-Host "当前 gameDir 的上级目录内容如下（方便你截图给开发者）："
        Write-Host "    $parent`n"
        Get-ChildItem -Path $parent | Select-Object Name, FullName, LastWriteTime
        Write-Host ""
        return $null
    }

    Write-Host "✅ 找到 webCaches 目录。`n"

    Write-Host "列出 webCaches 下的子目录（按时间倒序）："
    $subdirs = Get-ChildItem -Path $webCachesPath -Directory | Sort-Object LastWriteTime -Descending

    if ($subdirs.Count -eq 0) {
        Write-Host "⚠ webCaches 目录中没有任何子文件夹。"
        Write-Host "   说明可能游戏尚未生成缓存，请打开游戏并进入祈愿记录页面后再试。`n"
        return $null
    }

    $index = 0
    foreach ($dir in $subdirs) {
        Write-Host ("[{0}] {1}  (LastWriteTime: {2})" -f $index, $dir.Name, $dir.LastWriteTime)
        $index++
        if ($index -ge 5) { break } # 只展示前几个，避免太长
    }
    Write-Host ""

    $latest = $subdirs[0]
    Write-Host "最新的缓存文件夹推断为:"
    Write-Host "    $($latest.FullName)`n"

    # 按你的 Electron 代码的路径规则推断 data_2
    $cacheFile = Join-Path $latest.FullName "Cache\Cache_Data\data_2"
    Write-Host "预计缓存文件 data_2 路径为:"
    Write-Host "    $cacheFile"

    if (Test-Path $cacheFile) {
        Write-Host "✅ 找到缓存文件 data_2，可以正常读取祈愿链接（从缓存角度看正常）。`n"
    }
    else {
        Write-Host "❌ 未找到缓存文件 data_2。"
        Write-Host "   请确认："
        Write-Host "   1) 进入游戏后，打开【祈愿记录】页面一次；"
        Write-Host "   2) 然后关闭游戏，再重新运行本脚本；"
        Write-Host "   3) 如果仍报错，请截图本窗口发给开发者排查。`n"
    }
}

# 主流程
$logPath = Get-LogPath
if (-not $logPath) {
    Write-Host "=== 自检结束（未找到日志）==="
    exit
}

$gameDir = Get-GameDirFromLog -logPath $logPath
if (-not $gameDir) {
    Write-Host "=== 自检结束（无法解析游戏目录）==="
    exit
}

Test-WebCaches -gameDir $gameDir

Write-Host "=== 自检完成，如有问题请将整个窗口截图发送给开发者。==="
Read-Host "按回车键退出..."
