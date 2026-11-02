## 2026-10-30 · 240节奏采集 / 正拍与偏差提示

用户要求先补乐器课判定采集并优化可读性，保持窗口和伤害。独立world240继承239：Perfect±80ms×1.4、Great±160ms×1.2、自动×1、空弹零伤害及点击不锁下一拍均不改。music_clock240只为事件标注resolved240（已判定拍又点击），不改逻辑。music_stats240按事件收集：perfect/great/empty_click/auto为发射口径，占比分母=手动点击+自动轮数；漏拍missed_beat/避让skip单列，不把点击和漏拍混为一类。追猫fight/修补repair等阶段分计数。

timing负数为早、正数为晚；统计未消费拍的手动输入偏差，包括空弹早按，排除已消费拍重复点击，单列excluded_resolved_beat_clicks。保存均值/标准差/中位数/P95绝对偏差/早晚个数、8桶分布（界线-160,-80,-40,0,40,80,160ms）。计数/和/平方和/直方图全程累计，分位数使用前5000个非重复输入样本；事件明细前2000条（时间为未暂停真实节拍秒、阶段、拍号、kind、gain、offset、resolved）。分位数/明细有明确采样上限，不能宣称无限全量。空记录均值/中位数为空，占比0，不伪造精度。

world240在共用flush逐事件观察一次，继续239发射；session为当前装配段全部数据，recording只在现有C开始记录激活期间采集，report的music240字段含二者。原5秒自动保存/导出/结束归档路径不变，完整音乐快照随结束冻结，重开/改装清零；新增C摘要列计数与发射占比、均值/中位数。旧记录没有点击时序，不回填。测试专用user://music240_validation_records，不改人工boss_records。

可读性：music_aim240继承239多拍收缩，最近一拍更粗亮（4px），后续两拍降透明（.22/.12）；238新增默认不变的frame_alpha238/frame_width238虚拟钩子，旧238/239保持原值。音乐激活时取消acquired117入场padding缩放，使判定边界不被锁定入场动画移动。每个正拍用同一rhythm.time短亮边（100ms），声音tick仍沿旧同一时钟；不是已完成硬件延迟校准。判定下方加早←正拍→晚短偏差条（中央金色Perfect、两侧青色Great），手动结果显示带符号毫秒，marker保留1秒，自动/漏拍不画假偏差。已消费拍空弹显示“MISS · 此拍已结束”，不显示+0ms，避免误导成按准却Miss。未改3D美术/角色/相机/光照/碰撞/树。

76项Compatibility检查全过（docs/music240-validation.json、music240-final.log），无脚本/shader错误；含原62项伤害/空弹/旋律/组合回归，采集分母/均值/桶/阶段/上限、真实记录JSON每5秒检查点、结束快照冻结/重开清零、五组合已消费拍提示区分。截图plush220-music240.png已看。末尾仅补C摘要占比文字并做music240-parse.log解析检查。未做人工偏差分布分析、硬件时延校准、长期性能或全部平衡验收，不把窗口难度归咎玩家。

独立music240_preview.cfg/boss_balance240.cfg；最新240，239保留菜单31/music239，旧主169和旧预览均保留，启动器UTF-8 BOM及实际Windows PowerShell list通过。未提交/push。
