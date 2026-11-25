param(
    [ValidateSet('menu','latest','main','spider','forest204','transport205','transport206','transport207','boss212','cat216','pig219','boss220','boss221','boss222','boss223','boss224','boss225','boss226','boss227','boss228','boss229','boss230','boss231','boss232','boss233','boss234','music235','music236','music237','music238','music239','music240','music241','music242','music243','music244','relay245','relay246','boss247','boss248','boss249','boss250','boss251','lighting252','lighting253','lighting254','lighting255','boss256','boss257','boss258','boss259','boss260','boss261','boss262','boss263','encounter264','rest265','rest266','flank267','flower268','roller269','composite270','mixed271','batches272','ball273','ball274','elastic275','ball276','skill288','skin290','combat291','stage297','stage298','stage299','stage300','cards301','cards302','cards303','cards304','cards305','cards306','cards307','cards308','cards309','cards310','cards311','cards312','stage313','boss314','paper347','paper348','paper349','plush350','silk351','pressure352','bomber353','pursuit354','room355','room356','room357','room358','room359','room360','room361','room362','room363','room364','room365','room366','room367','room368','room369','room370','room371','room372','room373','room374','room375','room376','room377','room378','room379','room380','room381','room382','flight383','flight384','flight385','flight386','flight387','flight388','flight389','flight390','room391','room392','room393','room394','room395','room396','room397','room398','room399','room400','room401','room402','home403','home404','map405','home406','home407','home408','home409','home410','home411','home412','home413','home414','home415','home417','home418','home419','home420','home421','home422','home423','home424','home425','home426','home427','home428','home429','home430','home431','home432','history','list')]
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
    @{Key='1'; Mode='latest'; Label='最新开发预览：432（大世界原院小屋）'; Scene='res://scenes/world/world432.tscn'; Extra=@()},
    @{Key='174'; Mode='home432'; Label='大世界原院小屋：432'; Scene='res://scenes/world/world432.tscn'; Extra=@()},
    @{Key='173'; Mode='home431'; Label='大世界行走镜头：431'; Scene='res://scenes/world/world431.tscn'; Extra=@()},
    @{Key='172'; Mode='home430'; Label='A 稿扫檐与石门套：430'; Scene='res://scenes/world/world430.tscn'; Extra=@()},
    @{Key='171'; Mode='home429'; Label='A 稿手绘墙面与装饰：429'; Scene='res://scenes/world/world429.tscn'; Extra=@()},
    @{Key='170'; Mode='home428'; Label='A 稿外墙与点缀：428'; Scene='res://scenes/world/world428.tscn'; Extra=@()},
    @{Key='169'; Mode='home427'; Label='手绘墙石与透明窗：427'; Scene='res://scenes/world/world427.tscn'; Extra=@()},
    @{Key='168'; Mode='home426'; Label='大世界小院落位：426'; Scene='res://scenes/world/world426.tscn'; Extra=@()},
    @{Key='167'; Mode='home425'; Label='实体石阶与屋檐修复：425'; Scene='res://scenes/world/world425.tscn'; Extra=@()},
    @{Key='166'; Mode='home424'; Label='室内顶与合缝：424'; Scene='res://scenes/world/world424.tscn'; Extra=@()},
    @{Key='165'; Mode='home423'; Label='低视点、推门与让路：423'; Scene='res://scenes/world/world423.tscn'; Extra=@()},
    @{Key='164'; Mode='home422'; Label='后屋顶、隔墙与真窗：422'; Scene='res://scenes/world/world422.tscn'; Extra=@()},
    @{Key='163'; Mode='home421'; Label='A稿家具与连续切墙：421'; Scene='res://scenes/world/world421.tscn'; Extra=@()},
    @{Key='162'; Mode='home420'; Label='A稿新小屋外观：420'; Scene='res://scenes/world/world420.tscn'; Extra=@()},
    @{Key='161'; Mode='home419'; Label='同址娃娃屋与小院布局：419'; Scene='res://scenes/world/world419.tscn'; Extra=@()},
    @{Key='160'; Mode='home418'; Label='A稿外屋与连续切墙：418'; Scene='res://scenes/world/world418.tscn'; Extra=@()},
    @{Key='159'; Mode='home417'; Label='A半开放娃娃屋：417'; Scene='res://scenes/world/world417.tscn'; Extra=@()},
    @{Key='158'; Mode='home415'; Label='主屋侧屋体块对照：415'; Scene='res://scenes/world/world415.tscn'; Extra=@()},
    @{Key='157'; Mode='home414'; Label='木屋分层装修与室内拱架：414'; Scene='res://scenes/world/world414.tscn'; Extra=@()},
    @{Key='156'; Mode='home413'; Label='C阁楼木屋正面实体：413'; Scene='res://scenes/world/world413.tscn'; Extra=@()},
    @{Key='155'; Mode='home412'; Label='恢复近景小院镜头：412'; Scene='res://scenes/world/world412.tscn'; Extra=@()},
    @{Key='154'; Mode='home411'; Label='室内外常驻与连续切墙：411'; Scene='res://scenes/world/world411.tscn'; Extra=@()},
    @{Key='153'; Mode='home410'; Label='小号实体屋连续开门运镜：410'; Scene='res://scenes/world/world410.tscn'; Extra=@()},
    @{Key='152'; Mode='home409'; Label='小号3D屋与轻收紧室内：409'; Scene='res://scenes/world/world409.tscn'; Extra=@()},
    @{Key='151'; Mode='home408'; Label='屋外到屋内镜头与黑屏跨门：408'; Scene='res://scenes/world/world408.tscn'; Extra=@()},
    @{Key='150'; Mode='home407'; Label='双向运镜与门槛切面：407'; Scene='res://scenes/world/world407.tscn'; Extra=@()},
    @{Key='149'; Mode='home406'; Label='淡黑进屋与原尺寸室内：406'; Scene='res://scenes/world/world406.tscn'; Extra=@()},
    @{Key='148'; Mode='map405'; Label='大地图小屋落位对照：405'; Scene='res://scenes/world/world405.tscn'; Extra=@()},
    @{Key='147'; Mode='home404'; Label='实体小屋与开门：404'; Scene='res://scenes/world/world404.tscn'; Extra=@()},
    @{Key='146'; Mode='home403'; Label='家园连续进出屋：403'; Scene='res://scenes/world/world403.tscn'; Extra=@()},
    @{Key='145'; Mode='room402'; Label='门口式空间布局：402'; Scene='res://scenes/world/world402.tscn'; Extra=@()},
    @{Key='144'; Mode='room401'; Label='三套镜头构图：401'; Scene='res://scenes/world/world401.tscn'; Extra=@()},
    @{Key='143'; Mode='room400'; Label='窗光与梁角藤蔓：400'; Scene='res://scenes/world/world400.tscn'; Extra=@()},
    @{Key='142'; Mode='room399'; Label='弧梁与角撑：399'; Scene='res://scenes/world/world399.tscn'; Extra=@()},
    @{Key='141'; Mode='room398'; Label='衣柜与洗漱台：398'; Scene='res://scenes/world/world398.tscn'; Extra=@()},
    @{Key='140'; Mode='room397'; Label='书桌画风A/B：397'; Scene='res://scenes/world/world397.tscn'; Extra=@()},
    @{Key='139'; Mode='room396'; Label='实体圆桌与软椅：396'; Scene='res://scenes/world/world396.tscn'; Extra=@()},
    @{Key='138'; Mode='room395'; Label='实体手绘书桌样件：395'; Scene='res://scenes/world/world395.tscn'; Extra=@()},
    @{Key='137'; Mode='room394'; Label='手绘书桌与茶桌：394'; Scene='res://scenes/world/world394.tscn'; Extra=@()},
    @{Key='136'; Mode='room393'; Label='拱窗与绿格窗帘：393'; Scene='res://scenes/world/world393.tscn'; Extra=@()},
    @{Key='135'; Mode='room392'; Label='整面侧墙与三款壁纸：392'; Scene='res://scenes/world/world392.tscn'; Extra=@()},
    @{Key='134'; Mode='room391'; Label='手绘木地板与织毯：391'; Scene='res://scenes/world/world391.tscn'; Extra=@()},
    @{Key='133'; Mode='flight390'; Label='四向蓄力与后冲：390'; Scene='res://scenes/world/world390.tscn'; Extra=@()},
    @{Key='132'; Mode='flight389'; Label='双手蓄力与弹弓加速：389'; Scene='res://scenes/world/world389.tscn'; Extra=@()},
    @{Key='131'; Mode='flight388'; Label='四向基础施法：388'; Scene='res://scenes/world/world388.tscn'; Extra=@()},
    @{Key='130'; Mode='flight387'; Label='羽毛弹与自由空射：387'; Scene='res://scenes/world/world387.tscn'; Extra=@()},
    @{Key='129'; Mode='flight386'; Label='小黑鹅正面施法实战：386'; Scene='res://scenes/world/world386.tscn'; Extra=@()},
    @{Key='128'; Mode='flight385'; Label='自由悬浮与速度上限：385'; Scene='res://scenes/world/world385.tscn'; Extra=@()},
    @{Key='127'; Mode='flight384'; Label='飞行限速与场景碰撞：384'; Scene='res://scenes/world/world384.tscn'; Extra=@()},
    @{Key='126'; Mode='flight383'; Label='四向飞行小黑鹅实战：383'; Scene='res://scenes/world/world383.tscn'; Extra=@()},
    @{Key='125'; Mode='room382'; Label='翼根与手臂层序修正：382'; Scene='res://scenes/world/world382.tscn'; Extra=@()},
    @{Key='124'; Mode='room381'; Label='左右背面飞行：381'; Scene='res://scenes/world/world381.tscn'; Extra=@()},
    @{Key='123'; Mode='room380'; Label='自然悬浮与合并地影：380'; Scene='res://scenes/world/world380.tscn'; Extra=@()},
    @{Key='122'; Mode='room379'; Label='独立双翼逐帧动画：379'; Scene='res://scenes/world/world379.tscn'; Extra=@()},
    @{Key='121'; Mode='room378'; Label='C拆翼拍动试演：378'; Scene='res://scenes/world/world378.tscn'; Extra=@()},
    @{Key='120'; Mode='room377'; Label='正面飞姿A比例对照：377'; Scene='res://scenes/world/world377.tscn'; Extra=@()},
    @{Key='119'; Mode='room376'; Label='小黑鹅呼吸与弹步：376'; Scene='res://scenes/world/world376.tscn'; Extra=@()},
    @{Key='118'; Mode='room375'; Label='睡眠层序与行走节奏：375'; Scene='res://scenes/world/world375.tscn'; Extra=@()},
    @{Key='117'; Mode='room374'; Label='盖被收发与侧面摆臂：374'; Scene='res://scenes/world/world374.tscn'; Extra=@()},
    @{Key='116'; Mode='room373'; Label='小黑鹅移动与跟随：373'; Scene='res://scenes/world/world373.tscn'; Extra=@()},
    @{Key='115'; Mode='room372'; Label='小黑鹅人形同屏：372'; Scene='res://scenes/world/world372.tscn'; Extra=@()},
    @{Key='114'; Mode='room371'; Label='室内性能与出门加载：371'; Scene='res://scenes/world/world371.tscn'; Extra=@()},
    @{Key='113'; Mode='room370'; Label='盖被遮挡与室内补光：370'; Scene='res://scenes/world/world370.tscn'; Extra=@()},
    @{Key='112'; Mode='room369'; Label='小人比例完整睡姿：369'; Scene='res://scenes/world/world369.tscn'; Extra=@()},
    @{Key='111'; Mode='room368'; Label='双枕与3D床躺卧：368'; Scene='res://scenes/world/world368.tscn'; Extra=@()},
    @{Key='110'; Mode='room367'; Label='像素床与手绘床对照：367'; Scene='res://scenes/world/world367.tscn'; Extra=@()},
    @{Key='109'; Mode='room366'; Label='奶油厚被与绿色搭毯：366'; Scene='res://scenes/world/world366.tscn'; Extra=@()},
    @{Key='108'; Mode='room365'; Label='奶油床单与褶边床裙：365'; Scene='res://scenes/world/world365.tscn'; Extra=@()},
    @{Key='107'; Mode='room364'; Label='手绘3D床头和左枕样件：364'; Scene='res://scenes/world/world364.tscn'; Extra=@()},
    @{Key='106'; Mode='room363'; Label='室内跟随镜头对照：363'; Scene='res://scenes/world/world363.tscn'; Extra=@()},
    @{Key='105'; Mode='room362'; Label='分层手绘床：362'; Scene='res://scenes/world/world362.tscn'; Extra=@()},
    @{Key='104'; Mode='room361'; Label='床的手绘渲染对照：361'; Scene='res://scenes/world/world361.tscn'; Extra=@()},
    @{Key='103'; Mode='room360'; Label='羽毛双人床：360'; Scene='res://scenes/world/world360.tscn'; Extra=@()},
    @{Key='102'; Mode='room359'; Label='软寝具试版：359'; Scene='res://scenes/world/world359.tscn'; Extra=@()},
    @{Key='101'; Mode='room358'; Label='分层双人床：358'; Scene='res://scenes/world/world358.tscn'; Extra=@()},
    @{Key='100'; Mode='room357'; Label='立体手绘衣柜：357'; Scene='res://scenes/world/world357.tscn'; Extra=@()},
    @{Key='99'; Mode='room356'; Label='家具角度对照：356'; Scene='res://scenes/world/world356.tscn'; Extra=@()},
    @{Key='98'; Mode='room355'; Label='暖木小屋布局：355'; Scene='res://scenes/world/world355.tscn'; Extra=@()},
    @{Key='97'; Mode='pursuit354'; Label='换绳追荡 / 猪猪扫喷：354'; Scene='res://scenes/world/world354.tscn'; Extra=@()},
    @{Key='96'; Mode='bomber353'; Label='吊绳投弹蛛：353'; Scene='res://scenes/world/world353.tscn'; Extra=@()},
    @{Key='95'; Mode='pressure352'; Label='蜘蛛连投 / 镜前荡过：352'; Scene='res://scenes/world/world352.tscn'; Extra=@()},
    @{Key='94'; Mode='silk351'; Label='蛛丝入退场 / 猪猪棉絮：351'; Scene='res://scenes/world/world351.tscn'; Extra=@()},
    @{Key='93'; Mode='plush350'; Label='姐姐林间普通战：350'; Scene='res://scenes/world/world350.tscn'; Extra=@()},
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
if ($selected.Scene -in @('res://scenes/world/world403.tscn','res://scenes/world/world404.tscn')) { Write-Host '正在进入家园，请稍候。' } else { Write-Host '首次载入约需几十秒，请稍候。' }
$arguments = @('--path',('"'+$project+'"'),'--rendering-method','gl_compatibility',$selected.Scene)+$selected.Extra
Start-Process -FilePath $engine -ArgumentList $arguments -WorkingDirectory $workspace -WindowStyle Normal
