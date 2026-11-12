param(
    [ValidateSet('menu','latest','main','spider','forest204','transport205','transport206','transport207','boss212','cat216','pig219','boss220','boss221','boss222','boss223','boss224','boss225','boss226','boss227','boss228','boss229','boss230','boss231','boss232','boss233','boss234','music235','music236','music237','music238','music239','music240','music241','music242','music243','music244','relay245','relay246','boss247','boss248','boss249','boss250','boss251','lighting252','lighting253','lighting254','lighting255','boss256','boss257','boss258','boss259','boss260','boss261','boss262','boss263','encounter264','rest265','rest266','flank267','flower268','roller269','composite270','mixed271','batches272','ball273','ball274','elastic275','ball276','skill288','skin290','combat291','stage297','stage298','stage299','stage300','cards301','cards302','cards303','cards304','cards305','cards306','cards307','cards308','cards309','cards310','cards311','cards312','stage313','boss314','paper347','paper348','paper349','history','list')]
    [string]$Mode = 'menu'
)
# Keep UTF-8 BOM: this file is loaded by Windows PowerShell 5.1 via the CMD launcher.
$ErrorActionPreference = 'Stop'
$workspace = Split-Path -Parent $PSScriptRoot
$project = $workspace
$engine = if ($env:GODOT_EXE) { $env:GODOT_EXE } else { 'D:\work\Agent\Godot_v4.7.2-stable_win64\Godot_v4.7.2-stable_win64.exe' }
$history = Join-Path $PSScriptRoot 'preview_history'
$legacyHistory = Join-Path (Split-Path -Parent $project) 'tools\preview_history'
if (-not (Test-Path -LiteralPath $history) -and (Test-Path -LiteralPath $legacyHistory)) { $history = $legacyHistory }
# Update this single table when a new working preview replaces the current one.
$entries = @(
    @{Key='1'; Mode='latest'; Label='最新开发预览：349（纸群飞入 / 主动俯冲）'; Scene='res://scenes/world/world349.tscn'; Extra=@()},
    @{Key='92'; Mode='paper349'; Label='纸群飞入 / 主动俯冲：349'; Scene='res://scenes/world/world349.tscn'; Extra=@()},
    @{Key='91'; Mode='paper348'; Label='纸群割草试演：348'; Scene='res://scenes/world/world348.tscn'; Extra=@()},
    @{Key='90'; Mode='paper347'; Label='纸怪连续遭遇：347'; Scene='res://scenes/world/world347.tscn'; Extra=@()},
    @{Key='89'; Mode='boss314'; Label='城防弹幕纸剧场：346'; Scene='res://scenes/world/world314.tscn'; Extra=@()},
    @{Key='88'; Mode='stage313'; Label='城堡 C / 妹妹露台试摆：313'; Scene='res://scenes/world/world313.tscn'; Extra=@()},
    @{Key='87'; Mode='cards312'; Label='骑士牵引 / 冲击反馈：312'; Scene='res://scenes/world/world312.tscn'; Extra=@()},
    @{Key='86'; Mode='cards311'; Label='骑士斜向校准对照：311'; Scene='res://scenes/world/world311.tscn'; Extra=@()},
    @{Key='85'; Mode='cards310'; Label='拉线直冲对照：310'; Scene='res://scenes/world/world310.tscn'; Extra=@()},
    @{Key='84'; Mode='cards309'; Label='恢复305骑士对照：309'; Scene='res://scenes/world/world309.tscn'; Extra=@()},
    @{Key='83'; Mode='cards308'; Label='骑士拉线冲刺对照：308'; Scene='res://scenes/world/world308.tscn'; Extra=@()},
    @{Key='82'; Mode='cards307'; Label='骑士定点回荡对照：307'; Scene='res://scenes/world/world307.tscn'; Extra=@()},
    @{Key='81'; Mode='cards306'; Label='纸偶读招对照：306'; Scene='res://scenes/world/world306.tscn'; Extra=@()},
    @{Key='80'; Mode='cards305'; Label='纸偶追赶定位对照：305'; Scene='res://scenes/world/world305.tscn'; Extra=@()},
    @{Key='79'; Mode='cards304'; Label='旧固定定位攻击对照：304'; Scene='res://scenes/world/world304.tscn'; Extra=@()},
    @{Key='78'; Mode='cards303'; Label='三次提落与无伤回程对照：303'; Scene='res://scenes/world/world303.tscn'; Extra=@()},
    @{Key='77'; Mode='cards302'; Label='竖直纸偶与受击钟摆对照：302'; Scene='res://scenes/world/world302.tscn'; Extra=@()},
    @{Key='76'; Mode='cards301'; Label='旧倾斜纸偶与固定晃动对照：301'; Scene='res://scenes/world/world301.tscn'; Extra=@()},
    @{Key='75'; Mode='stage300'; Label='城楼动作与正门演出对照：300'; Scene='res://scenes/world/world300.tscn'; Extra=@()},
    @{Key='74'; Mode='stage299'; Label='旧落景与侧边出场对照：299'; Scene='res://scenes/world/world299.tscn'; Extra=@()},
    @{Key='73'; Mode='stage298'; Label='旧山顶翻景与出门对照：298'; Scene='res://scenes/world/world298.tscn'; Extra=@()},
    @{Key='72'; Mode='stage297'; Label='旧林地开场对照：297'; Scene='res://scenes/world/world297.tscn'; Extra=@()},
    @{Key='71'; Mode='combat291'; Label='当前完整战斗：291（团团 / 手电）'; Scene='res://scenes/world/world291.tscn'; Extra=@()},
    @{Key='70'; Mode='skin290'; Label='玻璃团团单图变形对照：290'; Scene='res://scenes/world/world290.tscn'; Extra=@()},
    @{Key='69'; Mode='skill288'; Label='手电主动与旧Boss对照：288'; Scene='res://scenes/world/world288.tscn'; Extra=@()},
    @{Key='68'; Mode='ball276'; Label='返回当前战斗预览：276'; Scene='res://scenes/world/world276.tscn'; Extra=@()},
    @{Key='67'; Mode='elastic275'; Label='程序球联动对照：275'; Scene='res://scenes/world/world275.tscn'; Extra=@()},
    @{Key='66'; Mode='ball274'; Label='上一续弹段对照：274'; Scene='res://scenes/world/world274.tscn'; Extra=@()},
    @{Key='65'; Mode='ball273'; Label='首次奖励流程对照：273'; Scene='res://scenes/world/world273.tscn'; Extra=@()},
    @{Key='64'; Mode='batches272'; Label='无奖励六批普通战：272'; Scene='res://scenes/world/world272.tscn'; Extra=@()},
    @{Key='63'; Mode='mixed271'; Label='两滚滚两普通独立试演：271'; Scene='res://scenes/world/world271.tscn'; Extra=@()},
    @{Key='62'; Mode='composite270'; Label='整体滚动单只试演：270'; Scene='res://scenes/world/world270.tscn'; Extra=@()},
    @{Key='61'; Mode='roller269'; Label='滚滚花团团原流程：269（共用花合成修复）'; Scene='res://scenes/world/world269.tscn'; Extra=@()},
    @{Key='60'; Mode='flower268'; Label='抢前路花团团普通战：268'; Scene='res://scenes/world/world268.tscn'; Extra=@()},
    @{Key='59'; Mode='flank267'; Label='上一全员包抄实验：267'; Scene='res://scenes/world/world267.tscn'; Extra=@()},
    @{Key='58'; Mode='rest266'; Label='上一连续增援对照：266'; Scene='res://scenes/world/world266.tscn'; Extra=@()},
    @{Key='57'; Mode='rest265'; Label='上一山脚小憩对照：265'; Scene='res://scenes/world/world265.tscn'; Extra=@()},
    @{Key='56'; Mode='encounter264'; Label='上一普通战短流程：264'; Scene='res://scenes/world/world264.tscn'; Extra=@()},
    @{Key='55'; Mode='boss263'; Label='已认可团团Boss / 武器对照：263'; Scene='res://scenes/world/world263.tscn'; Extra=@()},
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
