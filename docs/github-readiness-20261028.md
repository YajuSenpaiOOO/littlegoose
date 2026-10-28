# 首次GitHub上传前运行验证

2026-10-28。远程目标：https://github.com/YajuSenpaiOOO/littlegoose.git。

从93b732a提交使用git clone --no-hardlinks创建全新独立副本，Git LFS实际取回262个资源（合计约296MiB），不复用原项目.godot或assets/bake84。不使用外部美术草稿、旧godot_yard或父工作区资源。验证副本保留在父工作区.tmpwork/github-ready-check，未提交缓存/截图。

Godot 4.7.2 stable Windows x86_64、Jolt、Compatibility、RTX 5060 Laptop、1600×1000下完成首次无界面编辑器导入，随后用真实OpenGL渲染运行测试：

- forest204_capture.gd：11项通过、0失败。森林启动、实际多鹅飞机载荷和投射、地形贴合辅助圈、GPU遮挡有无对照、取消/退出清理。树根日夜截图已查看。
- goose_air_squad169_probe.gd：27项通过、0失败。默认169基础场景启动，每鹅各自起飞、真实落弹、载荷守恒、气球剑、蓄力、笔记重播、暂停/清理与纸/团团切换。
- 冷启动确实重建缓存：204约137秒、169约110秒；这是本次冷启动样本，不是后续启动时长或帧率承诺。
- 原生combat113 DLL成功加载，运行状态显示native=true。

首次导入还生成24个尚未提交的脚本/shader UID，已从验证副本补回源仓库并跟踪，未改玩法代码或项目默认场景。原始基线93b732a和checkpoint/world204-20261028保持。

原始结构化验证结果保存在docs/upload-verification-20261028/。完整逐帧日志与截图留本地，未全量入库。本轮是上传可运行性验证，不意味着性能、前景树避让、旧远景等已知问题已经解决。
