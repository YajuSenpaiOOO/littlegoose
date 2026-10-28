# 35° 地表纹理提示词

使用内置 image_gen，非透明输出。两次独立生成，以 docs/captures/props35.png 为材质参考。输出直接保存到 assets/environment/angle35/grass_ground_v1.png 与 dirt_ground_v1.png，未进行像素编辑。

生成的是垂直俯视的材质纹理；运行时按统一地面坐标投影到 35° 平面。道路形状及边缘由场景材质计算，镜头移动不重绘地皮。纹理的无缝性仍须在实机里验证，不把提示词当成保证。

## grass

Use case: stylized-concept. Asset: seamless tileable square 1:1 ground material texture for a 2D illustrated game, no scene composition. Reference is ONLY the existing props' painterly material and muted palette. Paint a quiet muted sage/olive meadow grass surface viewed EXACTLY VERTICALLY DOWN, flat orthographic ground texture. It will be projected to 35-degree ground plane in engine; DO NOT pre-tilt the texture. Restrained large soft gouache color patches, subtle paperlike painted grain, low contrast, sparse tiny short grass marks grouped into a few irregular tufts. Keep most surface calm for a small anime character and bullet readability. Sophisticated muted greens, avoid yellow/brown grass, vivid lime, neon, saturation and busy speckling. Uniform detail scale and neutral diffuse light everywhere. Opposite edges match seamlessly, no vignette, no center focal point, no path, dirt, stones, flowers, fallen leaves, bushes, tree, object, shadow, grid, border, UI or text. This is an albedo surface texture, NOT a landscape illustration. Square image full bleed.

## dirt

Use case: stylized-concept. Asset: seamless tileable square 1:1 ground material texture for a 2D illustrated game. Reference is ONLY the props' gently hand-painted material quality. Paint pale warm taupe-beige fine compacted earth path surface viewed EXACTLY VERTICALLY DOWN, flat orthographic. Pure dirt fills ENTIRE image; path shape and grass edge will be made in engine. Very restrained soft gouache texture, subtle broad natural color patches, almost no grit, only a handful of tiny flat mineral flecks, low contrast and no dramatic dark cracks. Neutral diffuse light, no directional sunlight. Opposite edges seamless, no vignette or frame. No grass, road boundary, stone pavers, stepping stones, large rocks, flowers, objects, raised forms, shadows, UI or text. Not yellow sand or orange desert, not photoreal. Square image full bleed, calm and readable at game camera scale.
