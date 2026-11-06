<#
    scratchverilog.ps1 —— 用 Edge / Chrome 的 --app 窗口打开本目录下的 ScratchVerilog 编辑器
                          （只有 Firefox 时退化为普通窗口）

    用法：
        scratchverilog.cmd                     打开编辑器（默认示例代码）
        scratchverilog.cmd D:\code\demo.v      打开指定文件
        scratchverilog.cmd .\demo.v            相对路径也行
        scratchverilog.cmd --file .\demo.v     同上，显式写 --file
        把 .v 文件直接拖到 scratchverilog.cmd 图标上，同样可以

    浏览器分工：
        Chromium 系（Edge / Chrome / Chromium）
            --app 无地址栏窗口，加 ?file= 让页面 fetch 读入文件。
        Firefox
            没有 --app，也没有放行 file:// 读本地文件的开关，
            且 file:// 页面本身不允许 fetch 本地文件；
            所以只打开 index.html：传了文件也不读，只在终端提示一句，不报错。

    两条参数的必要性（仅 Chromium 系）：
        --allow-file-access-from-files
            页面用 fetch('file:///...') 读你指定的文件；Chrome/Edge 默认禁止 file:// 页面读本地文件。
        --user-data-dir
            把上面这条放行限制关在独立配置目录里，不波及日常用的浏览器。
            附带效果：主题、语言、缩进设置都存在这里，所有窗口共享（首次打开是默认配置）。
#>
[CmdletBinding()]
param(
    # 要打开的文件；留空则只打开编辑器
    [Parameter(Position = 0)]
    [Alias('File', 'f')]
    [string]$Path,

    # 指定浏览器 exe（默认自动找 Edge / Chrome，最后才用 Firefox）
    [string]$Browser,

    # 指定的 profile 目录（默认 %LOCALAPPDATA%\ScratchVerilog\profile）
    [string]$ProfileDir,

    # 只打印将要执行的命令，不真的启动浏览器（排查用）
    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$htmlPath = Join-Path $scriptDir 'index.html'

if (-not (Test-Path -LiteralPath $htmlPath -PathType Leaf)) {
    Write-Host ''
    Write-Host "找不到 index.html：$htmlPath" -ForegroundColor Red
    Write-Host '请把 scratchverilog.ps1 / scratchverilog.cmd 放在与 index.html 同一目录。' -ForegroundColor Yellow
    Write-Host ''
    exit 1
}

if (-not $ProfileDir) {
    $ProfileDir = Join-Path $env:LOCALAPPDATA 'ScratchVerilog\profile'
}
# 目录在真正需要时才建（Firefox 分支用不到独立 profile）

function Resolve-BrowserPath {
    param([string]$Hint)

    if ($Hint) {
        if (Test-Path -LiteralPath $Hint -PathType Leaf) { return (Resolve-Path -LiteralPath $Hint).ProviderPath }
        $c = Get-Command $Hint -ErrorAction SilentlyContinue
        if ($c) { return $c.Source }
        return $null
    }

    $roots = @($env:ProgramFiles, ${env:ProgramFiles(x86)}, $env:LOCALAPPDATA) | Where-Object { $_ }
    $candidates = @()
    foreach ($root in $roots) {
        $candidates += (Join-Path $root 'Microsoft\Edge\Application\msedge.exe')
        $candidates += (Join-Path $root 'Google\Chrome\Application\chrome.exe')
        # Firefox 排在这一轮最后：有 Chromium 系就优先（Firefox 读不了命令行文件）
        $candidates += (Join-Path $root 'Mozilla Firefox\firefox.exe')
    }
    # 32 位安装的 Edge 常在 x86 目录，上面已覆盖；这里再兜一层系统级路径
    $candidates += 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
    foreach ($c in $candidates) {
        if (Test-Path -LiteralPath $c -PathType Leaf) { return $c }
    }

    foreach ($name in @('msedge', 'chrome', 'chromium', 'firefox')) {
        $cmd = Get-Command $name -ErrorAction SilentlyContinue
        if ($cmd) { return $cmd.Source }
    }
    return $null
}

# 绝对路径 -> file:/// URI。.NET 的 Uri 会编码空格、中文、#、?（Win11 + PS 5.1 实测）
function ConvertTo-FileUri {
    param([string]$LiteralPath)
    $full = (Resolve-Path -LiteralPath $LiteralPath).ProviderPath
    return ([System.Uri]::new($full)).AbsoluteUri
}

$fileUri = ''
$displayName = ''
if ($Path) {
    if (-not (Test-Path -LiteralPath $Path)) {
        Write-Host ''
        Write-Host "文件不存在：$Path" -ForegroundColor Red
        Write-Host ''
        exit 1
    }
    if (Test-Path -LiteralPath $Path -PathType Container) {
        Write-Host ''
        Write-Host "这是文件夹，请指定具体文件：$Path" -ForegroundColor Red
        Write-Host ''
        exit 1
    }
    $resolved = (Resolve-Path -LiteralPath $Path).ProviderPath
    $fileUri = ConvertTo-FileUri $resolved
    $displayName = Split-Path -Leaf $resolved
}

$pageUri = ConvertTo-FileUri $htmlPath
$url = $pageUri
if ($fileUri) {
    # 整个 file:// URI 作为 query 值编码一次，页面 URLSearchParams.get('file') 再解码回来
    $url = $pageUri + '?file=' + [System.Uri]::EscapeDataString($fileUri)
}

$browserPath = Resolve-BrowserPath $Browser
if (-not $browserPath) {
    Write-Host ''
    Write-Host '没找到 Microsoft Edge / Google Chrome / Firefox。' -ForegroundColor Red
    Write-Host '装好其中一个，或用 -Browser "C:\路径\chrome.exe" 指定。' -ForegroundColor Yellow
    Write-Host ''
    exit 1
}

# 只看文件名：Firefox 没有 --app，也读不了命令行传的文件
$isFirefox = ([System.IO.Path]::GetFileNameWithoutExtension($browserPath) -eq 'firefox')

if ($isFirefox) {
    # 只把页面交给默认窗口。故意不传 ?file=：
    # 传了页面会去 fetch，而 Firefox 的 file:// 页面读不了本地文件，必然失败、多一条报错。
    $argLine = '"{0}"' -f $pageUri
} else {
    # 路径里可能有空格（例如用户名带空格），参数统一加引号交给浏览器解析
    $argLine = '--app="{0}" --allow-file-access-from-files --user-data-dir="{1}"' -f $url, $ProfileDir
}

if ($DryRun) {
    Write-Host "browser : $browserPath"
    Write-Host "args    : $argLine"
    if ($isFirefox) {
        Write-Host 'profile : (Firefox 复用默认 profile)'
        if ($Path) { Write-Host 'note    : Firefox 不能命令行读文件，将只打开编辑器' }
    } else {
        Write-Host "profile : $ProfileDir"
    }
    exit 0
}

if ($isFirefox -and $Path) {
    Write-Warning 'Firefox 不能在命令行读入文件，已只打开编辑器；请在编辑器里点「打开文件」，或把文件直接拖到页面上。'
}

if ($displayName -and -not $isFirefox) {
    Write-Host "打开 $displayName ..." -ForegroundColor Green
} else {
    Write-Host '打开 ScratchVerilog ...' -ForegroundColor Green
}

if (-not $isFirefox) {
    if (-not (Test-Path -LiteralPath $ProfileDir)) {
        New-Item -ItemType Directory -Force -Path $ProfileDir | Out-Null
    }
}

Start-Process -FilePath $browserPath -ArgumentList $argLine | Out-Null
exit 0
