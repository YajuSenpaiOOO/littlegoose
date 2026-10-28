# 101 林地微景与局部声景

2026-10-20，默认world101，旧100保留。根目录play.cmd / preview_woodland101.cmd启动；Ctrl+Alt+F2游园，F3秋千，Ctrl+Alt+A开关新增环境音。

## 画面

4簇蘑菇、3组松果枯枝、5片独立落叶集中树根/倒木周围；透明底不带草团或土块。落叶4×4小网格顺地势，shader降饱和与亮度。立面使用forest_receiver95、porch局部光照、原生投影和低强度柔接触影，落叶只接影。图集用内置image_gen参照原yard15树图生成，原图透明alpha保留，运行时AtlasTexture裁切；[完整提示词与生成记录](../assets/woodland101/GENERATION.md)。

路边5段不连续草石分两批：25颗低矮碎石复用手绘石材，50簇短草直接共享grass_material，包括主角压力、行走拖尾和风。没有新增硬碰撞，中央活动通道保留。

3只奶白/淡紫蝴蝶双翼在中线铰接。位置10Hz、翼动shader；每0.25秒检查主角28m与镜头外扩范围，夜间隐藏、远处停止位置更新。静态物件40m/批次46m可见距离，无逐物体CPU投影脚本。

## 声音

两个复用AudioStreamPlayer3D，加跟随主角的AudioListener3D。鸟鸣为短合成啁啾，白昼/主角22m内才触发，间隔9–16秒，距离衰减。绳索为柔和合成摩擦/木质提示，实际撞动或明显摆动转向才触发，1秒冷却，主角近12m触发/14m截止。Ctrl+Alt+A静音不影响战斗音效。没有新增全图循环音或每次事件创建声道。声音为程序合成而非录音；自动检查覆盖触发与门控，主观音色待体验。

## 验证

world101继承100，继续用99世界表面，不改旧地形和碰撞。真实渲染terrain_world101_probe **51项通过**，包括车站原侧阶/前阶上下、旧小院高度、林地整环、高台上下、原路、中央横纵走位、三波战斗寻路/击败/选卡、树卡分离、长根贴地、真实秋千碰撞/推摆/回落，以及新增素材/草材质共享/蝴蝶范围/昼夜/声效/静音。

随后仅修饰叶色与双翼网格，woodland101_capture **4项通过**：双翼12顶点、摆件接地、夜间隐藏、远处无鸟鸣。最终昼/暮/夜实拍日志无错误警告。共55项；未更改坐姿交互，不宣称消除既有偶发卡顿。

- woodland101-validation.json / woodland101-render.log：51项回归
- woodland101-visual-validation.json / woodland101-final-render.log：4项最终补验
- woodland101-startup.log：默认入口检查（自动退出）
- captures/world_restart/woodland101_root_microgarden.png：近景
- captures/world_restart/woodland101_path_edge.png：路缘
- captures/world_restart/woodland101_park_day.png、woodland101_park_sunset.png、woodland101_park_night.png：最终昼夜
