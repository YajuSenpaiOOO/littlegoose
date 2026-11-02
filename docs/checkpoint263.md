# 当前开发检查点：263

涵盖205—263以来当前开发分支的角色/姐姐战、团团Boss及增援、武器装配与记录、森林暖灯/受光和最新光线表现。263最终去掉脚边红色光环，保留胸前红灯、HUD脉冲及稳定光束。此检查点记录可运行开发状态，不代表正式世界流程/普通战波次/奖励系统已经接好。

## 启动

在独立godot_world仓库执行：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/launch-game.ps1 -Mode latest
```

默认查找用户指定的D:/work/Agent/Godot_v4.7.2-stable_win64引擎。其它机器可先把环境变量GODOT_EXE设为自己的Godot可执行文件路径。-Mode list列出场景；-Mode main仍为169。项目默认场景不改，Godot引擎不进Git。

图片/音频走Git LFS，新克隆需git lfs pull。assets/bake84、.godot为可重建缓存；首次运行较慢。父工作区启动器和原始美术工作目录不属于此仓库，仓库内启动器可独立运行。

## 验证

当前263先前14项效果/性能检查与4项原生连续开火检查通过；去光环后再次运行原生开火、红灯命中、胸灯跟随、卸装清除检查，报告docs/beam263-native-validation.json。仓库字面依赖审核以tools/check_repository.py结果为准，不替代实机玩法检查。更早各预览检查记录保留于docs。

性能限制见docs/beam263.md：链整理脚本开销下降，整场帧率未改善；高射频射线判定仍保留。树遮挡为既有已知问题。普通战完整节奏/正式成长奖励/纸怪Boss未实现。

开发分支codex/spider-sister-transport205；此次推送保留main现状，不把开发预览伪装成已验收正式主线。没有清理未提交文件；自动生成的docs/startup84-latest.json保留在本机工作树。

本次仓库审核1060项字面资源依赖无缺失；staged whitespace检查通过。去环后4项原生检查再通过，无脚本/shader错误。
