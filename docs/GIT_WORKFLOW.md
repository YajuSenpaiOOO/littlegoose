# 独立仓库与协作

建立日期：2026-10-28。godot_world是独立Git仓库，父目录原Git保留且忽略godot_world，不是子模块。不要在父仓库add这个目录。用户创建的远程origin为https://github.com/YajuSenpaiOOO/littlegoose.git；首次上传前干净克隆运行记录见github-readiness-20261028.md。

## 检查点范围

首个提交记录当前204开发状态、169默认入口和现存性能工作；不是未经优化的历史版本。历史性能源码备份docs/perf_fix_backup_20261027保留并纳入Git。详细接手信息快照见checkpoint-handoff-20261028.md；后续以当前实际源码与提交为准。

跟踪源码、场景、项目设置、运行原始资源、资源导入设置、UID、原生扩展源码及现成Windows DLL、设计/验证报告和必要历史备份。图片、音频及二进制美术使用Git LFS。assets/bake84是按内容签名生成、缺失时自动重建的启动缓存，不跟踪。docs内PNG等验收图、.godot、日志不跟踪，原文件均留在本机。首次在新checkout运行可能明显较慢。截图若确需分享，可按需要单独挑选，而不是全量强行add。

根目录旧项目、原始素材和art_workbench不属于本仓库。本仓库已包含现有游戏使用的资源；尚未采用的新画稿需要未来明确导入后提交。父目录启动器与接手文档在仓库内保留一份建立时快照，见tools/workspace_launch_snapshot与docs/checkpoint-*；日常独立启动直接运行下列命令。

## 日常操作

在godot_world目录执行：

```powershell
git status
git diff
git add -- scripts/ scenes/ assets/ docs/ project.godot
git diff --cached --stat
git commit -m "Describe the concrete change"
```

根据本次任务选择具体文件，不要默认提交另一个agent尚未完成的更改。提交前确认场景版本与相应验证。无需每次commit都跑整个游戏回归，但不能把单纯提交称为玩法测试通过。

安装Git LFS后新克隆执行git lfs pull以获得真实二进制资源。普通git diff显示的是LFS指针，工作目录仍是原始PNG等文件。日常git push会通过pre-push hook上传相应LFS对象。首次上传前查看git lfs ls-files与仓库大小，了解远程LFS容量。

本机Git直连GitHub不可达，独立仓库local config使用系统已有代理127.0.0.1:7897；该配置不在提交中。换机器不必使用此地址。若本机代理端口变化需相应更新，若直连可用可执行git config --local --unset http.proxy。

## 同时开发

同一目录的两个agent共享文件、分支与暂存区，切分支不能隔离它们。当前一个线程改world性能、另一个只写外部美术目录，可以继续；若两个线程都改游戏代码，应使用不同Git worktree、不同分支，分别提交后合并。使用codex/前缀创建任务分支。运行性能采样时只开一个相关Godot实例，避免对照受其它实例影响。

禁止为了回退直接git reset --hard或git clean。先检查并保存未提交工作；回退某次已提交修改优先git revert。不要在并行线程仍写同一文件时切分支/还原文件。

## 不依赖父目录的启动

```powershell
& 'D:\work\Agent\Godot_v4.7.2-stable_win64\Godot_v4.7.2-stable_win64.exe' --path . --rendering-method gl_compatibility res://scenes/world/world204.tscn
```

引擎不随仓库提交。项目默认场景仍是169，当前开发预览为204，未改project.godot。父目录00_开始游戏.cmd仍可用。
