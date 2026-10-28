# 纸怪掉落物素材 / 145

2026-10-24。使用内置 image_gen.imagegen 生成与编辑，非 CLI。

- 最终源图：paper_scraps.png，透明 PNG，三张撕下来的横线纸。
- 保留米白纸、蓝横线、红边线和梅紫像素轮廓，不画表情，用于普通收集材料。
- region.json 记录运行时主体裁切。paper_scraps145.gd 提供小尺寸贴图精灵入口，以 0.86 alpha 阈值保留清晰像素边缘。生成源图未被覆盖或后处理，保留在项目内。
- 本轮只制作素材和验证画面；正式击败掉落、拾取和背包规则未接入。

## Initial prompt

Create ONE collectible loot sprite for a cute pixel RPG: a small stack of THREE torn notebook paper scraps, lying at a low three-quarter view, slightly fanned, gently curled front corner. Recognizable pale buttery ivory paper, THREE simple pale blue ruled lines on the top sheet, one muted coral-red vertical margin near the torn left edge. Torn left edge with 4-5 large rounded notches, a small folded top right corner. Chunky dark desaturated plum-purple pixel outline (not black), soft lilac and warm cream stepped shadows, limited pastel palette, crisp deliberate pixel clusters. Cute and very readable at about 32-40 pixels wide, matching a small torn notebook-paper enemy, but this is ordinary collected material: NO face, NO eyes, NO mouth, NO hands, NO characters, NO writing, NO symbols, NO numbers, NO UI frame, NO sparkles or glow. Show only this single compact stack on genuinely transparent background, generous clear margins. The pages are broad and mostly flat, not a standing sheet and not a scroll; keep the design very simple rather than dense photorealistic detail.

## Final edit prompt

Edit this game loot sprite. Preserve the exact three torn notebook scraps, colors, shapes, blue ruled lines, red margin, folded corner, and crisp plum pixel outline. Remove ALL of the diffuse purple glow/halo and ALL soft shadow outside the pixel outline. Outside the crisp paper silhouette must be completely transparent alpha=0, no glow and no vignette. Keep the design otherwise unchanged; do not add face, text, symbols or new objects. This is a small ordinary paper crafting material sprite, not a magic item.

最终源图仍有少量半透明外缘，游戏精灵用上述 alpha 阈值处理，不把原图的淡外缘当成发光特效。
