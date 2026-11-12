# 278 短臂举灯修订候选与锚点研究

工具：内置image_gen，参考用户选定stand_A和偏好的raise_C。只新生成raise_short.png，stand_A保留原文件。源图未代码改像素；Pillow仅读取虹膜颜色区/alpha边界作初步测量。

原输出：C:/Users/ASUS/.codex/generated_images/01a1902b-b815-7a03-a34e-5bf93c912ce8/exec-436d4107-be59-4ea4-b06e-9b103f3df575.png

用户选择：站稳A可用，喜欢举灯C的另一只手收腰发力，认为右臂长/力量弱/两帧头不一致。新稿缩短并弯曲举灯臂、左手收腰，但抬灯比旧C更低，尚未用户认可，不能称最终高举动作。

alignment-study.json中的虹膜中心/鞋底中点为自动估计，尚需人工校准；原正面region来自walk_backup.json中心帧(633,0,600,800)，foot(300,749)。按虹膜间距统一缩放、按鞋底中点统一平移可以保证已标注锚点/眼距显示一致，不能保证不同生成图头部轮廓和服装像素完全一致；最终严谨做法是同一头部图层复用、身体局部编辑。没有接入hero192或改变其几何/光照，入口仍276。

## 最终提示词

Precise identity-preserving single-keyframe EDIT. Image 1 is the APPROVED standing A master: preserve its head, face size, eye spacing, hair crown, ahoge, hair silhouette, torso proportions, costume and planted boots as closely as possible. Image 2 is only the desired gesture: opposite hand tucked at the waist with contained magical power. Produce ONE revised raised-flashlight pose of exactly image 1's heroine, strict front facing. Main correction: the lifted anatomical RIGHT arm (viewer LEFT) must be SHORT and anatomically believable for a big-headed short-limbed chibi, NOT a long adult arm. Short upper arm rising from correct shoulder, compact BENT elbow, short forearm, fist firmly gripping the same cream/teal/dark-gray household flashlight pointing vertically UP. The wrist may stay beside the temple/upper hair instead of above the highest ahoge: do NOT stretch her arm to clear the giant hair. Keep the raised elbow clear, firm shoulder engagement, slight grounded knee compression, stable boots and restrained resolute expression to suggest real effort, without a tilted torso. Anatomical LEFT hand (viewer RIGHT) clenched close at the waist, elbow drawn inward/back like gathering magic, matching image 2's charm. Preserve approved image1 head proportions rather than making head larger to fill frame. The dress, detached sleeve pink ties and wrist must have sensible connection. Same flashlight thickness and hand scale as image1. No extra joints, fingers, arms. No beam, light, aura, cape, wings, particles, text, scene or external shadow. Unlit lamp. Original chunky pixel-art style and dark-plum outline, no painterly smoothing. ONE complete full-body character on transparent alpha, uncropped boots/hair/flashlight, margins. This is an animation revision, not a new character design or a sprite sheet.
