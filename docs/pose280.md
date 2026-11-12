## 2026-11-03 · 280统一底稿与局部举灯改稿

用户反馈279亮度/像素颗粒与原正面不同，举灯头小且整体跳变；授权修。内置image_gen先参考原walk_source中间正面（身份/配色/颗粒）+站稳A（姿势），生成assets/hero_transform280/stand.png；再仅参考新stand局部改双臂生成raise.png。原PNG复制不修绘，完整提示词/来源/尺寸/边界/接入记录PROMPTS.md。两图1173x1341，高置信alpha边界头顶96/97、脚底1229/1228。不能称逐像素头部锁定，尚有细节变化。

新增独立world280/pose_review280，原正面固定/新帧循环硬切/半透明叠图。新两帧共用foot(587,1229)、scale .595*.75，无逐帧眼距缩放、无补间；head与lowerbody叠图基本重合，比279稳定，原稿风格仍有少量差异待用户验收。已看引擎截图，检查脚锚稳定通过，visual_acceptance=false等待用户。没有接入战斗变身或改hero192材质/几何/脚锚，没有灯光披风。

两套启动器latest280；68/ball276回战斗，169未变。未提交/push。

资源细节见 assets/hero_transform280/PROMPTS.md。验证 docs/pose280-validation.json 仅检查根脚锚稳定，不能代表美术通过。
