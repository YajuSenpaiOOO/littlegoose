# 230 翻身第四帧局部修正

使用内置 imagegen 技能。原220六格图的第四格为编辑目标，216原版为角色参考。先纠正耳朵/脚归属，再单独去第五脚并倒转嘴形。前两次未采用输出仍在 Codex generated_images；项目保存最终 down-generated.png、原始目标 down-source.png 和运行 roll_sheet.png。仅替换第四格，其余五格逐像素保留。有效边界按alpha>=250取，用最近邻等比装入旧第四格占地，底锚保持(273,418)。

最终一轮完整提示词：

Precise local edit of this ONE transparent micro pixel game cat. Preserve the entire sprite EXACTLY except TWO corrections: (1) REMOVE the extra round foot protruding from the BOTTOM belly contour at approximately (530,930) in the 1280x1280 reference. Fill that small region with the uninterrupted cream/apricot rounded belly edge. Keep FOUR remaining round feet: two along LEFT contour, one at TOP contour, one UPPER-RIGHT contour. Keep the short calico TAIL at far lower-right; tail is not a foot. Keep both triangular pink-inner EARS at their current forehead positions unchanged. (2) Invert the tiny omega mouth 180 degrees around its own center: it should be two tiny dark plum inverted arches like a tilted lower-case m, rather than the current upright w/omega curves. Do NOT rotate eyes, cheeks or the whole cat. All remaining pixels, body silhouette, pose, thick pixel outline, palette, patches, ear positions and scale should remain unchanged. No text, no shadow, no backdrop, genuine transparent background. ONE full-body sprite.
