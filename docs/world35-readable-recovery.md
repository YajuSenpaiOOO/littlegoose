# 读招35：分开蓄力和恢复轮廓

默认入口为 world35；preview_world_combat34.cmd 保留上一版对照。

- 蓄力继续使用压扁并保持的 anticipation 帧。
- 扑跳落地只用真实的 0.12 秒落地计时选择 landing 帧，此后恢复 idle 站姿，添加幅度很小的呼吸起伏。取消了恢复全程强制选择 landing 帧的逻辑。
- 保留普通扑跳 0.62 秒恢复期与弹反击退恢复期，便于沿用现有反击节奏。
- 起跳前最后 0.16 秒在头顶显示一个小暖色四角闪光，起跳、恢复、死亡阶段均不显示。使用真实深度测试，不透过树林提示敌人。网格只创建一次，不投影。
- PageDown 切换小闪光，可对照纯动作读招；Delete 仍可切换旧版地面提示。右键弹反保持原样。

验证：readability35_probe.gd 12 项通过，检查姿态、明显的轮廓高度差、提示时序、开关与原有恢复时长，并保存三张画面对照。parry35_capture.gd 6 项通过，实测移动扑跳弹反、反击命中、原始特效和时间恢复。parry34_probe.gd 35 项回归通过。

对照截图位于 docs/captures/world_restart/readability35_windup.png、readability35_landing.png、readability35_recovery.png；实战截图为 readability35_live_tell.png 和 readability35_live_parry.png。
