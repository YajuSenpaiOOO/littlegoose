# 性能修复备份（2026-10-27）

修改前原始文件副本。恢复方法：把需要的文件复制回 `godot_world/scripts/art/` 同名覆盖即可，例如在 godot_world 目录运行：

```
cp docs/perf_fix_backup_20261027/whole_tree_fade200.gd scripts/art/whole_tree_fade200.gd
cp docs/perf_fix_backup_20261027/forest_lighting191.gd scripts/art/forest_lighting191.gd
```

注意这些文件在 git 里是未跟踪状态（从未提交），git 无法恢复，本目录是唯一回滚来源。

- `whole_tree_fade200.gd`：优化后版本把采样射线/主角深度合并为每扫描一次、
  增加完全在相机背后的提前剔除、缓存精灵列表；判定阈值/采样点/alpha掩码不变。
- `forest_lighting191.gd`：优化后版本为真灯加 24m 可见性门控、12m 阴影门控，
  并用字典替代每帧 ordered.find；shader 光池与 201 上传逻辑不变。
- `coastal_edge140.gd`：优化后版本在 NorthernBufferTrim140 构建后把渲染签名
  相同（同shader代码+同uniform+同顶点布局）的surface合并（154→25），保留每组
  第一个材质实例，脚印系统照常触达；地面父节点与地理逻辑不变。

修复前后性能对比见 docs/perf204-run.log（前）与 docs/perf204-after.log（后）；
行为回归 docs/perf-fix-forest200-regression.log（22/22 通过）；
夜景对照 perf_before_shots/ 与 captures/world_restart/perf204night_*。
