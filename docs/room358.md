## 2026-11-13 · 358 分层双人床结构试版

用户同意先做床。1/回车=358，101/room358，100旧357保留。独立room_shell358/room_world358继承357，不改历史355-357。imagegen重画低细节四象限像素纹理（assets/room358），真实床架/床垫/头板，分开的枕头、床单/被子表层，沿房间轴；不再靠整床卡的人工深度近似。独立碰撞2.55×3，高.76，加真实头板碰撞。材质无自亮、native投影，旧卡/影代理同步关闭。F10新床/旧图，F8两睡位调试块，F9被子，F5占位/F6衣柜/F2昼夜。睡位是调试占位，不是躺卧人物；尚无上床/睡觉/盖被人物隆起与存档。衣柜/地板写实纹理反馈仍待后续重画，本轮只验证床方向。

原生ROOM358_DONE []；床左右连续走位、床/衣柜/墙碰撞、通路/交互、双锚点/盖被拆层对照、CFG不变。layout/bed-side-walk/sleep-slots截图已查看。父实际启动链选1和Enter替身均VERIFIED_LATEST_358_NO_PROCESS_STARTED。主角192与镜头不动。床仍方正结构试版，不宣称最终画风或躺卧演出完成。未提交。


资源：assets/room358/README.md 和 manifest.json；验证脚本scripts/world/validate_room358.gd，报告docs/room358-validation.json。
