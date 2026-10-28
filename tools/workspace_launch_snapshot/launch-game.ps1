param(
    [ValidateSet('menu','latest','main','spider','history','list')]
    [string]$Mode = 'menu'
)
$ErrorActionPreference = 'Stop'
$workspace = Split-Path -Parent $PSScriptRoot
$project = Join-Path $workspace 'godot_world'
$engine = 'D:\work\Agent\Godot_v4.7.2-stable_win64\Godot_v4.7.2-stable_win64.exe'
$history = Join-Path $PSScriptRoot 'preview_history'
# Update this single table when a new working preview replaces the current one.
$entries = @(
    @{Key='1'; Mode='latest'; Label='最新开发预览：很吓人的森林！204（纸飞机贴地辅助圈）'; Scene='res://scenes/world/world204.tscn'; Extra=@()},
    @{Key='2'; Mode='main'; Label='当前主版本：大地图 169'; Scene='res://scenes/world/world169.tscn'; Extra=@()},
    @{Key='3'; Mode='spider'; Label='小蜘蛛战斗试验：丝球与网垫 173'; Scene='res://scenes/world/world173.tscn'; Extra=@('--','--web173')}
)
if ($Mode -eq 'list') {
    foreach ($entry in $entries) {
        $scenePath = Join-Path $project $entry.Scene.Substring(6)
        if (-not (Test-Path -LiteralPath $scenePath -PathType Leaf)) { throw "场景不存在：$scenePath" }
        Write-Output "$($entry.Mode): $($entry.Label) -> $($entry.Scene)"
    }
    if (-not (Test-Path -LiteralPath $engine -PathType Leaf)) { throw "找不到 Godot：$engine" }
    exit 0
}
if ($Mode -eq 'menu') {
    Write-Host ''
    Write-Host '小白鹅大冒险 · 统一启动入口' -ForegroundColor Cyan
    Write-Host '直接按回车，进入最新开发预览。'
    Write-Host ''
    foreach ($entry in $entries) { Write-Host "  $($entry.Key). $($entry.Label)" }
    Write-Host '  4. 打开历史预览目录'
    Write-Host '  0. 退出'
    Write-Host ''
    $answer = Read-Host '请选择 [默认 1]'
    if ([string]::IsNullOrWhiteSpace($answer)) { $answer='1' }
    if ($answer -eq '0') { exit 0 }
    if ($answer -eq '4') { $Mode='history' }
    else {
        $selected = $entries | Where-Object { $_.Key -eq $answer } | Select-Object -First 1
        if (-not $selected) { Write-Host '无此选项，请重新打开启动入口。'; exit 1 }
        $Mode=$selected.Mode
    }
}
if ($Mode -eq 'history') {
    Start-Process -FilePath 'explorer.exe' -ArgumentList ('"'+$history+'"')
    exit 0
}
$selected = $entries | Where-Object { $_.Mode -eq $Mode } | Select-Object -First 1
$scenePath = Join-Path $project $selected.Scene.Substring(6)
if (-not (Test-Path -LiteralPath $engine -PathType Leaf)) { throw "找不到 Godot：$engine" }
if (-not (Test-Path -LiteralPath $scenePath -PathType Leaf)) { throw "场景不存在：$scenePath" }
Write-Host "正在启动：$($selected.Label)" -ForegroundColor Green
Write-Host '首次载入约需几十秒，请稍候。'
$arguments = @('--path',('"'+$project+'"'),'--rendering-method','gl_compatibility',$selected.Scene)+$selected.Extra
Start-Process -FilePath $engine -ArgumentList $arguments -WorkingDirectory $workspace -WindowStyle Normal
