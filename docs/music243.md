## 2026-10-30 · 243蝙蝠固定判定框 / 后续拍提亮

用户反馈蝙蝠辅助框不断大小变化、后续较远拍难看清。music_aim243继承242，只改音乐模式蝙蝠frame_rect223：不再以扑翅/受损贴图有效边界、offset、pixel_size计算尺寸；中心跟随actor.hit_area.global_position，按相机right/up投影固定1.44×.96世界单位范围，在每个修补窗口首次登记屏幕归一尺寸（除以视口高度）。窗口内尺寸固定，仅中心跟随蝙蝠移动，窗口结束/重开/改装清缓存，下次修补重新登记，视口调整按高度比例缩放。非音乐模式沿旧瞄准框；高空/disabled仍不给辅助框，不改蝙蝠图/碰撞/血量/动画。

最近拍仍alpha1/4px，后两拍alpha .22/.12→.52/.36，线宽1→2px，保持远→近层次，不改72px/s等效收缩进度、BPM/窗口/预算/空弹/旋律/音效与采集。world243继承242，独立music243_preview.cfg/boss_balance243.cfg，最新243，旧242菜单34/music242保留。启动器UTF-8 BOM、实际PowerShell list已过，主169与历史预览保留。

最终113项Compatibility检查通过：docs/music243-validation.json、music243-release.log，无脚本/shader错误。沿242全部原生伤害/声音/组合/统计回归，额外修补阶段30个真实帧覆盖扑翅及HP100%/60%/20%，判定尺寸误差<.001屏幕像素；同步改变视觉offset与pixel_size仍尺寸不变；后拍alpha/线宽、高空无框、退出修补缓存清理检查均过。首轮fixture手动进入repair忘清旧phase_age导致立即rise，次轮清缓存检查恰好在_process前读取，分别修复测试阶段年龄与等待两帧，不改生产以迎合断言；以release结果为准。

截图plush220-music243.png、music243-bat.png；专用probe_bat243锁定演员用于低空修补截图（music243-bat-preview.log），避免测试鼠标在屏幕角落导致自动软锁丢靶，功能测试尺寸检查直接采样真实演员。图像观感待用户确认，不宣称已完成所有战斗读拍验收；未做长期性能/全组合平衡。未动相机/主角/树/其它3D资源。未提交/push。
