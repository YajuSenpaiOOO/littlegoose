# 林地87素材生成记录

2026-10-20，使用内置 image_gen 工具（imagegen skill 默认路径），未使用CLI或API密钥。用于当前项目，三张原图均已复制到本目录；没有覆盖旧图。

- moss_boulders87.png：三种苔岩轮廓；完整最终提示词 rock-prompt.txt。生成原件 exec-5a123082-5548-4aa4-a9a6-7c1500e581c1.png。
- woodland_plants87.png：蕨草、低灌木与疏草三种簇；完整最终提示词 plant-prompt.txt。生成原件 exec-952bdf76-b2eb-4a36-b6f5-0325dfb6cad2.png。
- painted_rock_face87.png：用于实际坡面的手绘苔石表面材质，非山体背景立片；完整最终提示词 cliff-prompt.txt。生成原件 exec-79241d27-46ae-4378-8fe1-bc1888d964f9.png。

内置工具原件目录：C:/Users/ASUS/.codex/generated_images/01a14e32-c53e-7ca3-a249-b34b85513675/。

两张精灵图保留生成透明alpha。atlas_regions.json仅记录可见alpha>0.5对应的三块区域；运行时按项目forest14的既有方式提取区域并生成mipmap，没有修改源PNG。分割图块为纹理图集使用，不是重绘或合成图片。素材色彩以现有forest14/a_trees的暖绿、灰绿与绘本笔触为方向，提示词明确避免照片、密孔、塑料3D与黑洞。
