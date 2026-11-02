## 2026-10-30 · 242音符圆角 / 轻命中声

用户要求保持241玩法数值，只调整命中声音与方框观感。world242继承241，独立music242_preview.cfg/boss_balance242.cfg；BPM120/150/180、窗口/预算/Great1.2/Perfect1.4/自动1/空弹0及组合限制全部沿241。最新242，旧241菜单33/music241保留，主169不改；启动器UTF-8 BOM及真实Windows PowerShell list通过。

music_aim242继承241，238新增默认相同的frame_shape238/draw_base238虚拟绘制钩子，241正拍描边也走该钩子。242音乐运行时不绘旧方形辅助边角，仅保留糖果光标；固定判定边、每拍收缩外框、正拍亮边、命中残影都改为四段圆角短边，不连完整矩形，不填充中心。四角短边约19px、半径7px，圆帽与六段弧；奶油色最近拍/低透明青色后续拍沿旧层次。最近拍右上加小音符；Perfect保留金色四角星与向外淡出。无音乐时仍原瞄准框。几何定位/目标切换/高空蝙蝠无框规则不改；不动3D美术/碰撞/角色/相机/树/光照，无新位图。

音效按实际命中即时播放，不量化或延迟到正拍。新增assets/music242/soft_contact.wav为原创确定性滤波噪声（Python seed242，22050Hz mono PCM16，55ms，2ms淡入/8ms淡出/指数75，低通.70/.30，无定音振荡器）；music_contact242固定2声部-18dB，70ms前沿合并：第一下立即响，窗口内重复只计merged，不排队、不合并伤害。攻击音符/轻节拍不改；伤害与弹反提示不改，敌人倒下提示保留。重开/改装清声音计数与播放器。report.music242记录requests/played/merged/70ms/音量。

覆盖三个实际声音来源：1) CombatSfx22新增默认空Callable，242仅在同步_apply_shot_hit/on_legacy_contact调用栈内替换hit/jelly_hit/crack/crack_soft，调用结束恢复先前回调，hurt/parry等从不拦截；2) balloon_contact158抽取play_voice158，242音乐时转轻触声，spider_sword_contact203沿同函数，保留原粒子/附着/节流；无music_contact242或音乐未装备时原播放器继续；3) jelly_fx31._play中hit_clip/landing_clip的材质声也按需转轻触声，保留壳破碎/粒子/受击反馈，不删除材质FX。原生普通弹/飞机/直剑/剑雨测试确认实际声音请求进入新播放器。旧预览未提供music_contact242，默认旧声音，未做全局音量/总线静音。

最终108项Compatibility检查全通过，docs/music242-validation.json、music242-release.log无脚本/shader错误。含此前98项判定/五组合预算/纸飞机载荷/原生伤害/剑控制/采集归档回归，实际四组合新命中声、作用域恢复、12次密集请求合成1次即时声、短音与2声部、未装音乐返回旧路径、hurt/parry不拦截、多拍圆角绘制。第一轮未测实际声音入口；补测后发现普通飞机走独立材质播放器，music242-final.log中该断言失败，补齐jelly_fx31后release全过，不以失败日志作验收。plush220-music242.png已看，四段圆角/空心/音符已显示。代码检查与播放器触发不等于人工听感验收；音量与触感仍待用户实听，未跑长期性能或全组合平衡。未提交/push。
