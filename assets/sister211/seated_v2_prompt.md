# 211 独立坐姿修订

内置image_gen生成seated_character_v2.png，参考idle211（身份/像素画风）、seated207（坐姿）和hammock205（适配参考）。仅人物透明图；原211带布坐姿保留但不再引用。复用205原吊床、蝙蝠两帧、挂环和206接送/摇摆/投放。坐姿有效高恢复2.10再乘屏幕校准，脚底为独立人物锚点；材质/影子/占地沿用原实现。

完整提示词：

Use case: identity-preserve. Transparent standalone game sprite of ONLY the spider sister, sitting. Image 1 is mandatory current A character identity/style/proportion reference. Image 2 is POSE reference only, not rendering style: recreate its compact seated front pose, bent knees together, boots together tucked under knees, short arms angled down/out and palms resting on invisible seat beside hips. Image 3 is separate EXISTING hammock she will be composited into in the game; DO NOT DRAW ANY HAMMOCK, FABRIC SLING, RINGS, ROPES OR BATS in output. Character must be fully independent with transparent surroundings. Preserve image1 broad face, big head, glasses, amber eyes, rose mauve hair/left braid, gold spider hairclip, cream web apron, plum skirt, lavender shawl and exactly four purple back spider appendages. Hands short and resting close beside hips. Same chunky deliberate pixel clusters and simple shading as image1, avoid detailed high resolution painting. Entire seated body, hair curl and boots inside canvas with margin. Neutral flat asset lighting, no glow, no ground shadow, no background. Output ONLY one seated woman, no furniture whatsoever.
