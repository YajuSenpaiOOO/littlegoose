# 森林183资源

由内置 image_gen 生成，参考已选定的 `art/scary_forest176_refinement/merged_lowland_forest.png`。原图保持透明通道，不做像素重绘；运行时按 alpha >= .6 的包围盒定位。

- `central_oak.png`：中央主景树，实机高7.6m，独立树干与根部碰撞、遮挡淡出和地面投影。
- `yarn_craft_corner.png`：毛线篮、线轴与举爪幽灵小猫的树桩手工角，实机宽1.3m；两处试摆，低矮实体碰撞及投影。
- `lilac_ground_clump.png`：淡紫花、蘑菇与苔石，低矮可穿行点缀，实机宽1.05m；未作为战斗网垫。

前两件完整提示词见 `prompts.json`，花丛提示词见 `flowers_prompt.json`。彩旗仍使用独立资源，不烘焙到树上。
