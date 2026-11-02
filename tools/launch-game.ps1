param(
    [ValidateSet('menu','latest','main','spider','forest204','transport205','transport206','transport207','boss212','cat216','pig219','boss220','boss221','boss222','boss223','boss224','boss225','boss226','boss227','boss228','boss229','boss230','boss231','boss232','boss233','boss234','music235','music236','music237','music238','music239','music240','music241','music242','music243','music244','relay245','relay246','boss247','boss248','boss249','boss250','boss251','lighting252','lighting253','lighting254','lighting255','boss256','boss257','boss258','boss259','boss260','boss261','boss262','history','list')]
    [string]$Mode = 'menu'
)
# Keep UTF-8 BOM: this file is loaded by Windows PowerShell 5.1 via the CMD launcher.
$ErrorActionPreference = 'Stop'
$workspace = Split-Path -Parent $PSScriptRoot
$project = $workspace
$engine = if ($env:GODOT_EXE) { $env:GODOT_EXE } else { 'D:\work\Agent\Godot_v4.7.2-stable_win64\Godot_v4.7.2-stable_win64.exe' }
$history = Join-Path $PSScriptRoot 'preview_history'
# Update this single table when a new working preview replaces the current one.
$entries = @(
    @{Key='1'; Mode='latest'; Label='最新开发预览：263（连续光线 / 红灯预警）'; Scene='res://scenes/world/world263.tscn'; Extra=@()},
    @{Key='54'; Mode='boss262'; Label='上一光线表现对照：262'; Scene='res://scenes/world/world262.tscn'; Extra=@()},
    @{Key='53'; Mode='boss261'; Label='上一武器强度对照：261'; Scene='res://scenes/world/world261.tscn'; Extra=@()},
    @{Key='52'; Mode='boss260'; Label='上一原地入场对照：260'; Scene='res://scenes/world/world260.tscn'; Extra=@()},
    @{Key='51'; Mode='boss259'; Label='已认可团团单体对照：259'; Scene='res://scenes/world/world259.tscn'; Extra=@()},
    @{Key='50'; Mode='boss258'; Label='上一团团强追击对照：258'; Scene='res://scenes/world/world258.tscn'; Extra=@()},
    @{Key='49'; Mode='boss257'; Label='上一团团贴身判定对照：257'; Scene='res://scenes/world/world257.tscn'; Extra=@()},
    @{Key='48'; Mode='boss256'; Label='上一团团惯性对照：256'; Scene='res://scenes/world/world256.tscn'; Extra=@()},
    @{Key='47'; Mode='lighting255'; Label='两人环境调色查验：255'; Scene='res://scenes/world/world255.tscn'; Extra=@()},
    @{Key='46'; Mode='lighting254'; Label='上一暖灯与演员原样对照：254'; Scene='res://scenes/world/world254.tscn'; Extra=@()},
    @{Key='45'; Mode='lighting253'; Label='上一森林叠灯对照：253'; Scene='res://scenes/world/world253.tscn'; Extra=@()},
    @{Key='44'; Mode='lighting252'; Label='上一主角单人受光对照：252'; Scene='res://scenes/world/world252.tscn'; Extra=@()},
    @{Key='43'; Mode='boss251'; Label='团团新版基线对照：251'; Scene='res://scenes/world/world251.tscn'; Extra=@()},
    @{Key='42'; Mode='boss250'; Label='旧169基线团团对照：250'; Scene='res://scenes/world/world250.tscn'; Extra=@()},
    @{Key='41'; Mode='boss249'; Label='上一椭圆地影对照：249'; Scene='res://scenes/world/world249.tscn'; Extra=@()},
    @{Key='40'; Mode='boss248'; Label='上一持续反跳对照：248'; Scene='res://scenes/world/world248.tscn'; Extra=@()},
    @{Key='39'; Mode='boss247'; Label='上一团团三连跳对照：247'; Scene='res://scenes/world/world247.tscn'; Extra=@()},
    @{Key='38'; Mode='relay246'; Label='接力旗与姐姐战对照：246'; Scene='res://scenes/world/world246.tscn'; Extra=@()},
    @{Key='37'; Mode='relay245'; Label='上一接力旗动作对照：245'; Scene='res://scenes/world/world245.tscn'; Extra=@()},
    @{Key='36'; Mode='music244'; Label='上一碎片取舍对照：244'; Scene='res://scenes/world/world244.tscn'; Extra=@()},
    @{Key='35'; Mode='music243'; Label='上一乐器课收尾对照：243'; Scene='res://scenes/world/world243.tscn'; Extra=@()},
    @{Key='34'; Mode='music242'; Label='上一圆角与声音对照：242'; Scene='res://scenes/world/world242.tscn'; Extra=@()},
    @{Key='33'; Mode='music241'; Label='上一剑雨节奏对照：241'; Scene='res://scenes/world/world241.tscn'; Extra=@()},
    @{Key='32'; Mode='music240'; Label='上一节奏采集对照：240'; Scene='res://scenes/world/world240.tscn'; Extra=@()},
    @{Key='31'; Mode='music239'; Label='上一点击空弹对照：239'; Scene='res://scenes/world/world239.tscn'; Extra=@()},
    @{Key='30'; Mode='music238'; Label='上一辅助框判定对照：238'; Scene='res://scenes/world/world238.tscn'; Extra=@()},
    @{Key='29'; Mode='music237'; Label='上一单轨音符对照：237'; Scene='res://scenes/world/world237.tscn'; Extra=@()},
    @{Key='28'; Mode='music236'; Label='上一收缩框对照：236'; Scene='res://scenes/world/world236.tscn'; Extra=@()},
    @{Key='27'; Mode='music235'; Label='上一乐器课原型：235'; Scene='res://scenes/world/world235.tscn'; Extra=@()},
    @{Key='26'; Mode='boss234'; Label='姐姐战阶段收尾：234'; Scene='res://scenes/world/world234.tscn'; Extra=@()},
    @{Key='25'; Mode='boss233'; Label='上一匀速掠过与胶剑减速：233'; Scene='res://scenes/world/world233.tscn'; Extra=@()},
    @{Key='24'; Mode='boss232'; Label='上一连续剑雨与合批对照：232'; Scene='res://scenes/world/world232.tscn'; Extra=@()},
    @{Key='23'; Mode='boss231'; Label='上一新滚动与趴倒对照：231'; Scene='res://scenes/world/world231.tscn'; Extra=@()},
    @{Key='22'; Mode='boss230'; Label='上一纸飞机直落对照：230'; Scene='res://scenes/world/world230.tscn'; Extra=@()},
    @{Key='21'; Mode='boss229'; Label='上一眼25%与手电红灯对照：229'; Scene='res://scenes/world/world229.tscn'; Extra=@()},
    @{Key='20'; Mode='boss228'; Label='上一两段节奏对照：228'; Scene='res://scenes/world/world228.tscn'; Extra=@()},
    @{Key='19'; Mode='boss227'; Label='上一数值与性能对照：227'; Scene='res://scenes/world/world227.tscn'; Extra=@()},
    @{Key='18'; Mode='boss226'; Label='上一装配与性能修复：226'; Scene='res://scenes/world/world226.tscn'; Extra=@()},
    @{Key='17'; Mode='boss225'; Label='上一敲门与空运入场：225'; Scene='res://scenes/world/world225.tscn'; Extra=@()},
    @{Key='16'; Mode='boss224'; Label='上一B姿势软落地：224'; Scene='res://scenes/world/world224.tscn'; Extra=@()},
    @{Key='15'; Mode='boss223'; Label='上一蝙蝠表情与呼吸：223'; Scene='res://scenes/world/world223.tscn'; Extra=@()},
    @{Key='14'; Mode='boss222'; Label='上一姐姐后侧修补动作：222'; Scene='res://scenes/world/world222.tscn'; Extra=@()},
    @{Key='13'; Mode='boss221'; Label='上一追滚与武器反馈：221'; Scene='res://scenes/world/world221.tscn'; Extra=@()},
    @{Key='12'; Mode='boss220'; Label='上一联合Boss战：220'; Scene='res://scenes/world/world220.tscn'; Extra=@()},
    @{Key='11'; Mode='pig219'; Label='猪猪喷棉絮独立试演：219'; Scene='res://scenes/world/world219.tscn'; Extra=@()},
    @{Key='10'; Mode='cat216'; Label='肥猫原版地图角度与移动：216'; Scene='res://scenes/world/world216.tscn'; Extra=@()},
    @{Key='9'; Mode='boss212'; Label='上一Boss节奏试演：212'; Scene='res://scenes/world/world212.tscn'; Extra=@()},
    @{Key='2'; Mode='main'; Label='当前主版本：大地图 169'; Scene='res://scenes/world/world169.tscn'; Extra=@()},
    @{Key='3'; Mode='spider'; Label='小蜘蛛战斗试验：丝球与网垫 173'; Scene='res://scenes/world/world173.tscn'; Extra=@('--','--web173')},
    @{Key='5'; Mode='forest204'; Label='森林战斗 204'; Scene='res://scenes/world/world204.tscn'; Extra=@()},
    @{Key='8'; Mode='transport207'; Label='上一角色预览：207'; Scene='res://scenes/world/world207.tscn'; Extra=@()},
    @{Key='7'; Mode='transport206'; Label='上一运输预览：轻摆与玩偶 206'; Scene='res://scenes/world/world206.tscn'; Extra=@()},
    @{Key='6'; Mode='transport205'; Label='上一运输预览：吊床 205'; Scene='res://scenes/world/world205.tscn'; Extra=@()}
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
    if (-not (Test-Path -LiteralPath $history)) { Write-Host '独立仓库不含旧命令目录；请用 -Mode list 查看场景对照。'; exit 0 }
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
