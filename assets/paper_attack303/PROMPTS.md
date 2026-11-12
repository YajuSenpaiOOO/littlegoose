# 303 · 折叠纸火舌资源

内置image_gen按参考paper_cards301/dinosaur.png的纸质/色块/描边风格生成一张独立火舌；参考是风格输入，不是编辑恐龙本体。透明原始PNG无损复制为[fire.png](D:/work/Agent/workplace/小白鹅大冒险/godot_world/assets/paper_attack303/fire.png)，未程序修绘/降采样。来源C:/Users/ASUS/.codex/generated_images/01a1902b-b815-7a03-a34e-5bf93c912ce8/exec-80ab035d-abb1-4a4a-9691-f76aff7dbe0e.png。

2172×724，alpha128有效边界[60,13,2133,716]，左侧窄端约(55,440)为嘴部接入参考，原图hash见layout.json。三色纸层/折痕/胶带均在原图中。没有绳子、支杆或操纵者画进火中。

运行paper_fire303用同一纹理的三个连续UV区段原生网格，沿嘴部锁定方向分段显露/缩回，有少量折面起伏，不是另画多帧燃烧。最长4.2m、画面横向宽约1.65m；世界嘴点由恐龙局部像素(260,605)映射，朝右翻转时同步嘴点/顶端挂点。火舌瞬态VFX采用面向观察方向的带状网格，保持可读，未改变角色X=0显示原则。无受击/实体碰撞/接触影；伤害由同一展开长度的锁定扇区处理，原生射线截断障碍并截掉视觉；原生深度参与遮挡。材质unshaded、.94基底，作为绘本特效在夜间仍可读；不是照明灯，没有新增环境光源或全场亮度调整。

## 完整提示词

Use case: gameplay pixel-art VFX asset, new single horizontal paper flame tongue for attached cardboard dinosaur. Reference is STYLE only: same chunky stepped dark-plum outlines, large readable pixel clusters, warm layered cardstock, visible folded paper/tape, cute picture-book puppet theatre. Draw ONLY ONE long horizontal stylized PAPER FIRE BREATH cutout. At far LEFT a small narrow nozzle point, opening outward toward RIGHT into broad jagged flame tips. Three visibly overlapping folded cardstock layers: terracotta-red outer flame, golden orange middle flame, cream-yellow inner flame; a few angular accordion creases suggest unfolding paper, not liquid or smoke. Shape should feel powerful but playful, broad at right, continuous connected flame silhouette from left origin to tips. Full flame shown in generous alpha margins, landscape aspect about3:1. No dinosaur, no operator, no rope/pole, no words, no background/floor/cast shadow, NO blurred glow, sparks or photorealistic fire, no sprite sheet. Genuine transparent alpha background. Consistent coarse pixel shapes at game-camera scale; not finely painted illustration. This will unfold programmatically from the left and be attached to the dinosaur's mouth.
