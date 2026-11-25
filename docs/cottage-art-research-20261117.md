# 童话屋制作方法调研 · 2026-11-17

用户最新反馈：414仍奇怪，纹理反而过简，允许贴近原参考图丰富程度；主要矛盾是一层矮宽、屋顶过大、全立面一个大三角和大面积同材质，需按体块堆叠重想。当前停止继续在同一体块堆雕花/换四象限材质，不新增415，不改游戏入口或镜头。本轮是资料调研，414保留运行作问题对照。

## 当前模型核算（项目源码，不是网络规范）

home_yard413前墙宽13.1、高3.56；home_yard411缩放XZ.92、Y.98。因此主墙约12.05m宽/3.49m高。主脊local8.15 =>世界相对地面约7.99m，檐口到屋脊约4.50m，比首层墙高还大。视觉矛盾并不只是房屋总占地大，而是把整个宽平面压在同一个等腰大山墙下，腰线贯穿整屋，侧体块弱到正面几乎不读。厚檐/石基虽局部有层次，并未改掉主体轮廓。简单再拉高墙或缩小整屋也不足以解决。

## 作者本人/作者访谈来源

1. Ethan Clark — Creating a Dreamy Cottage with Maya, Substance 3D Painter & Houdini（Palia House，2023-02-14）
https://80.lv/articles/creating-a-dreamy-cottage-with-maya-substance-3d-painter-houdini
作者固定ShotCam、在最终视角反复对照概念轮廓，先体块后网格细化；几何轻微不规整，材质按木/金属/布/瓦等分离，逐层加色彩、粗糙度、缝隙变化。本文本身是高精度展示，不照搬20UDIM/V-Ray资源成本。借鉴镜头校准、体块和分材质层次。
作者项目页：https://ethanclarkart.artstation.com/projects/eldLND

2. Vincent Boichut — Designing a French Countryside Scene in Maya & UE4（2021-05-11）
https://80.lv/articles/designing-a-french-countryside-scene-in-maya-ue4
先用概念的3D块模确认尺寸和组合，按墙/门窗模块拆分；通过木梁/局部砖石打破空白墙面，5–6种瓦片再组合成屋面。借鉴主屋/侧屋/附属屋顶的组合，和有变化的模块复用，不是每片瓦随机噪声或重复同一平滑小样。

3. Alex Creamer — Learn How to Create a Hand-Painted 3D Cottage Using 3DCoat & Maya（2025-01-21）
https://80.lv/articles/learn-how-to-create-a-hand-painted-3d-cottage-using-3dcoat-maya
作者按最终相机调整/轻微扭曲几何平面以读清轮廓，按大组再子组组织资产，3DCoat建立整体气氛后在Photoshop深入绘制资产细节；连光影也大量手绘。这是手绘表现参考，不把其固定视角手绘灯光照抄为我项目昼夜/受光实现。
作者项目：https://alexrcreamer.artstation.com/projects/oJQly4

4. Taylor Harris — Making an Animated Stylized House Diorama in Substance & Unreal（2021-04-27）
https://80.lv/articles/making-an-animated-stylized-house-diorama-in-substance-unreal
概念匹配相机焦距/透视来校准块模；利用共同笔触把不同材质统一，又给三维资产比概念更多部位细节。这是分组材质/纹理组织参考，不照抄其场景灯光。

5. 作者glenatron的可旋转小屋模型（查看几何/手绘，不直接采用资源）
https://sketchfab.com/3d-models/painterly-cottage-0772aec70d584c60a27000af5f6c1ef4

## 针对本项目的建议（由资料与现模型作出的设计推断，非教程规定数值）

- 保留总可用室内面积，外部拆成较挺拔的主屋+偏置侧屋/凸窗+小入口体块；主次宽度/前后深度/屋脊高度明确。不是继续一个12m山墙从左盖到右；侧屋必须在正面镜头能读出来。
- 一层适当抬高、主屋屋脊相对檐口高度降低；先按角色与门作尺标，从25度/16.5m近镜比较无纹理体块。确切比例需要块模实看，不把任意3.8/4m说成建筑规范或先定死。
- 先做主次体块和门窗位置的正面比例对照，再保留已有效的深窗/大石/拱架模块。室内木拱架继续保留，二楼暂缓。必要时平面边界随着主屋/侧屋调整，但不先缩家具/角色来硬塞。
- 材质方向纠正：风格化不等于纯色/低细节；木头需要大木纹/切面亮边/木结裂纹、石块有各自转面和色差/缝隙、瓦片有边沿/局部色变，灰泥有受部位控制的旧化/局部砖石露出。每块重复同一材质小样欠缺这种部位信息。
- 保留材质大中小层次：大色块维持清晰，中尺度纹理说明材料，小细节集中门窗焦点；避免到处同等密度的噪声/裂缝。四个平滑色块图集不应继续作为整栋最终材质方案。
- Godot现有场景组织、碰撞、开门/切顶逻辑可保留；外观模型和手绘纹理应作为有UV/成套模块的美术资产制作，不受只能用GDScript逐块堆盒子的实现方式限制。先校准白模再投入新贴图。

当前没有按上述新方案改模型，未改变默认414；不把资料调研描述成比例已修好。