# 独立仓库接手入口

2026-10-28：本目录godot_world已建立独立Git仓库。先读AGENTS.md和docs/GIT_WORKFLOW.md。

- 默认场景：scenes/world/world169.tscn；当前开发预览：scenes/world/world204.tscn。项目配置未改。
- 建立时完整交接快照：docs/checkpoint-handoff-20261028.md，历史快照docs/checkpoint-history-20261028.md。其中父工作目录路径是建立时记录，不是本仓库的跨目录依赖。
- 204已包含森林装饰、蜘蛛试演、203受击毛絮与204纸飞机贴地圈；主角192保持竖直几何。森林正式三鹅解锁、姐姐和正式进度未接。
- 性能工作已有诊断和往返回滚，当前源码以首提交记录为准；旧修复源码备份docs/perf_fix_backup_20261027保留。此基线不是性能优化前原稿，不能据此宣称优化已通过最终验收。
- 前景树糊脸仍是KNOWN_ISSUES.md中暂缓项。不要在美术工作中自行重开遮挡调参。
- 缓存assets/bake84与验收截图未跟踪但保留本机；必要源码/运行资源/UID/import设置跟踪。图片及部分二进制资源使用Git LFS，克隆后需git lfs pull。
- 父工作区art_workbench内的蜘蛛姐姐立绘尚未接游戏，不属于运行依赖。
- 并行线程不要共享Git暂存区或在同一目录切分支；两边都改代码时先建立不同worktree。尚未配置远程或上传GitHub。
