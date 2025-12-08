function Get-LogPath {
    $base = Join-Path $env:USERPROFILE "AppData\LocalLow\miHoYo"

    $globalPath = Join-Path $base "Genshin Impact\output_log.txt"
    $chinaFolder = "$([char]0x539f)$([char]0x795e)"
    $chinaPath   = Join-Path $base "$chinaFolder\output_log.txt"

    # "[检查路径] 基础路径:"
    $msgCheckBase = "$([char]0x5b)$([char]0x68c0)$([char]0x67e5)$([char]0x8def)$([char]0x5f84)$([char]0x5d) $([char]0x57fa)$([char]0x7840)$([char]0x8def)$([char]0x5f84):"
    Write-Host "$msgCheckBase $base"

    if (Test-Path $globalPath) {
        # "[找到日志] 国际服日志:"
        $msg = "$([char]0x5b)$([char]0x627e)$([char]0x5230)$([char]0x65e5)$([char]0x5fd7)$([char]0x5d) $([char]0x56fd)$([char]0x9645)$([char]0x670d)$([char]0x65e5)$([char]0x5fd7):"
        Write-Host "$msg $globalPath"
        return $globalPath
    }
    elseif (Test-Path $chinaPath) {
        # "[找到日志] 国服日志:"
        $msg = "$([char]0x5b)$([char]0x627e)$([char]0x5230)$([char]0x65e5)$([char]0x5fd7)$([char]0x5d) $([char]0x56fd)$([char]0x670d)$([char]0x65e5)$([char]0x5fd7):"
        Write-Host "$msg $chinaPath"
        return $chinaPath
    }
    else {
        # "[错误] 未找到日志文件"
        $msg = "$([char]0x5b)$([char]0x9519)$([char]0x8bef)$([char]0x5d) $([char]0x672a)$([char]0x627e)$([char]0x5230)$([char]0x65e5)$([char]0x5fd7)$([char]0x6587)$([char]0x4ef6)"
        Write-Host $msg -ForegroundColor Yellow
        return $null
    }
}

function Extract-GameDir {
    param([string]$logContent)

    $regex = "([A-Z]:\\.+?\\(GenshinImpact_Data|YuanShen_Data))"
    $match = [regex]::Match($logContent, $regex)

    if ($match.Success) {
        $path = $match.Groups[1].Value
        # "[解析路径] 游戏目录为:"
        $msg = "$([char]0x5b)$([char]0x89e3)$([char]0x6790)$([char]0x8def)$([char]0x5f84)$([char]0x5d) $([char]0x6e38)$([char]0x620f)$([char]0x76ee)$([char]0x5f55)$([char]0x4e3a):"
        Write-Host "$msg $path"
        return $path
    }

    # "无法解析游戏路径"
    $msgErr = "$([char]0x65e0)$([char]0x6cd5)$([char]0x89e3)$([char]0x6790)$([char]0x6e38)$([char]0x620f)$([char]0x8def)$([char]0x5f84)"
    Write-Host "$([char]0x5b)$([char]0x9519)$([char]0x8bef)$([char]0x5d) $msgErr" -ForegroundColor Yellow
    return $null
}

function Get-LatestCacheVersion {
    param([string]$gameDir)

    $webCaches = Join-Path $gameDir "webCaches"
    # "[检查] webCaches 路径:"
    $msg = "$([char]0x5b)$([char]0x68c0)$([char]0x67e5)$([char]0x5d) webCaches $([char]0x8def)$([char]0x5f84):"
    Write-Host "$msg $webCaches"

    if (!(Test-Path $webCaches)) {
        # "未找到 webCaches 目录"
        $msgErr = "$([char]0x672a)$([char]0x627e)$([char]0x5230) webCaches $([char]0x76ee)$([char]0x5f55)"
        throw $msgErr
    }

    $dirs = Get-ChildItem $webCaches -Directory | Sort-Object LastWriteTime -Descending

    if ($dirs.Count -eq 0) {
        # "webCaches 中无版本文件夹"
        $msgErr = "webCaches $([char]0x4e2d)$([char]0x65e0)$([char]0x7248)$([char]0x672c)$([char]0x6587)$([char]0x4ef6)$([char]0x5939)"
        throw $msgErr
    }

    # "[版本] 最新缓存版本为:"
    $msgVer = "$([char]0x5b)$([char]0x7248)$([char]0x672c)$([char]0x5d) $([char]0x6700)$([char]0x65b0)$([char]0x7f13)$([char]0x5b58)$([char]0x7248)$([char]0x672c)$([char]0x4e3a):"
    Write-Host "$msgVer $($dirs[0].Name)"

    return $dirs[0].Name
}

function Extract-GachaLogUrl {
    param([string]$cacheFile)

    # "[读取缓存]"
    $msg = "$([char]0x5b)$([char]0x8bfb)$([char]0x53d6)$([char]0x7f13)$([char]0x5b58)$([char]0x5d)"
    Write-Host "$msg $cacheFile"

    if (!(Test-Path $cacheFile)) {
        # "未找到缓存文件"
        $msgErr = "$([char]0x672a)$([char]0x627e)$([char]0x5230)$([char]0x7f13)$([char]0x5b58)$([char]0x6587)$([char]0x4ef6)"
        throw $msgErr
    }

    $bytes   = Get-Content -LiteralPath $cacheFile -Encoding Byte -Raw
    $content = [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetString($bytes)

    $regex = "https:\/\/.+?&auth_appid=webview_gacha&.+?authkey=.+?&game_biz=hk4e_(cn|global|os)"
    $match = [regex]::Matches($content, $regex) | Select-Object -Last 1

    if ($match) {
        # "[找到祈愿链接]"
        $msgFound = "$([char]0x5b)$([char]0x627e)$([char]0x5230)$([char]0x7948)$([char]0x613f)$([char]0x94fe)$([char]0x63a5)$([char]0x5d)"
        Write-Host "$msgFound $($match.Value)"
        return $match.Value
    }

    # "未找到祈愿链接"
    $msgNot = "$([char]0x672a)$([char]0x627e)$([char]0x5230)$([char]0x7948)$([char]0x613f)$([char]0x94fe)$([char]0x63a5)"
    Write-Host "$([char]0x5b)$([char]0x9519)$([char]0x8bef)$([char]0x5d) $msgNot" -ForegroundColor Yellow
    return $null
}

# ===== 主流程 =====

# "=== 开始检测原神路径与缓存文件 ==="
$msgTitle = "=== $([char]0x5f00)$([char]0x59cb)$([char]0x68c0)$([char]0x6d4b)$([char]0x539f)$([char]0x795e)$([char]0x8def)$([char]0x5f84)$([char]0x4e0e)$([char]0x7f13)$([char]0x5b58)$([char]0x6587)$([char]0x4ef6) ==="
Write-Host $msgTitle

try {
    $logPath = Get-LogPath
    if (-not $logPath) {
        # "[终止] 脚本结束"
        $msg = "$([char]0x5b)$([char]0x7ec8)$([char]0x6b62)$([char]0x5d) $([char]0x811a)$([char]0x672c)$([char]0x7ed3)$([char]0x675f)"
        Write-Host $msg -ForegroundColor Red
        return
    }

    # 日志用默认编码读取（避免强行 UTF-8）
    $logContent = Get-Content -LiteralPath $logPath -Raw -Encoding Default
    $gameDir    = Extract-GameDir $logContent
    if (-not $gameDir) {
        $msg = "$([char]0x5b)$([char]0x7ec8)$([char]0x6b62)$([char]0x5d) $([char]0x811a)$([char]0x672c)$([char]0x7ed3)$([char]0x675f)"
        Write-Host $msg -ForegroundColor Red
        return
    }

    $cacheVer  = Get-LatestCacheVersion $gameDir
    $cacheFile = Join-Path $gameDir "webCaches\$cacheVer\Cache\Cache_Data\data_2"

    # "[最终缓存文件路径]"
    $msgFinal = "$([char]0x5b)$([char]0x6700)$([char]0x7ec8)$([char]0x7f13)$([char]0x5b58)$([char]0x6587)$([char]0x4ef6)$([char]0x8def)$([char]0x5f84)$([char]0x5d)"
    Write-Host "$msgFinal $cacheFile"

    if (!(Test-Path $cacheFile)) {
        # "[错误] 未找到缓存文件:"
        $msgErr = "$([char]0x5b)$([char]0x9519)$([char]0x8bef)$([char]0x5d) $([char]0x672a)$([char]0x627e)$([char]0x5230)$([char]0x7f13)$([char]0x5b58)$([char]0x6587)$([char]0x4ef6):"
        Write-Host "$msgErr $cacheFile" -ForegroundColor Red
        return
    }

    $url = Extract-GachaLogUrl $cacheFile
    if ($url) {
        Set-Clipboard -Value $url
        # "==== 成功 ===="
        $msgOk = "$([char]0x3d)$([char]0x3d)$([char]0x3d)$([char]0x3d) $([char]0x6210)$([char]0x529f) $([char]0x3d)$([char]0x3d)$([char]0x3d)$([char]0x3d)"
        Write-Host $msgOk -ForegroundColor Green

        # "祈愿链接已复制到剪贴板："
        $msgCopy = "$([char]0x7948)$([char]0x613f)$([char]0x94fe)$([char]0x63a5)$([char]0x5df2)$([char]0x590d)$([char]0x5236)$([char]0x5230)$([char]0x526a)$([char]0x8d34)$([char]0x677f)$([char]0xff1a)"
        Write-Host $msgCopy
        Write-Host $url
    }
}
catch {
    $errMsg = $_.Exception.Message
    $prefix = "$([char]0x5b)$([char]0x9519)$([char]0x8bef)$([char]0x5d)"
    Write-Host "$prefix $errMsg" -ForegroundColor Red
}

# $endMsg = "$([char]0x811a)$([char]0x672c)$([char]0x6267)$([char]0x884c)$([char]0x5b8c)$([char]0x6bd5)$([char]0xff0c)$([char]0x6309)$([char]0x4efb)$([char]0x610f)$([char]0x952e)$([char]0x9000)$([char]0x51fa)$([char]0x2e)$([char]0x2e)$([char]0x2e)"
# Write-Host $endMsg
# $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
