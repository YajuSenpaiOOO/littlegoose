# 294 · A折纸妹妹游戏小人

> 用户反馈本版比例仍不同于主角，未通过比例确认。后续修订见../paper_girl295/，保留本版作对照。

用户选293 A完整立绘作为纸怪Boss身份，B更有妹妹感且漂亮，保留作以后角色候选。本次内置image_gen单张生成正面抱书待机，以A立绘为身份、主角hero_pixel/walk_source中央正面idle为游戏小人画风/脸宽/大头身参考；不是以立绘作为像素画风参考，也不直接复用292的历史候选。

产物idle_front.png原始PNG直接复制，未程序修绘/抠图/降采样。来源C:/Users/ASUS/.codex/generated_images/01a1902b-b815-7a03-a34e-5bf93c912ce8/exec-5cc06c35-14a7-4ddc-a9b8-2b8c233bce55.png。尺寸、alpha128边界、候选脚点和hash见manifest.json。

目视：栗色短发、蓝黄发夹、绿眼、绿围裙/灰褐裙、棕靴和砖红卡纸本延续A；纸鹤封面、彩色厚页和小恐龙保留，服装细碎纹样简化为色块。表情为略得意而非凶狠。尚未做与主角同镜头世界尺寸/脚点/受光/遮挡比对，不能宣称像素密度已完全一致。

仅新静态候选，未接游戏，尚未画抛书/折纸/指挥/受击/投降动作，也未制作舞台或新Boss逻辑。未来接入沿docs/2_5d_display_contract.md，保持主角169/192比例，世界尺寸、展示面、材质、碰撞和影子需另行标定。本图不自行发光，无新增灯光/碰撞体/影子实例。

## 已明确的开场方向

用户提出不在草地预放一本展开书：她回来发现小纸怪都被打趴，惊讶/气恼后向天上一抛怀中书本，展开纸剧场领域。开场场地原本为草地，舞台因这次行动出现。后续方案建议为书空中翻开、折叠城堡/纸帘/布景落地依次立起，书本再回手或落在指挥台，避免角色空手却仍不断抽纸；后半部分为设计建议，尚未实现/未由用户定稿。最终空白纸投降演出继续保留，不新增第二本预置场地书。

## 完整提示词

Use case: identity-preserve + style-transfer for a production 2.5D pixel game sprite. IMAGE1 is the USER-SELECTED A character portrait, strict identity/costume/book reference ONLY. IMAGE2 is the existing heroine gameplay walking sheet, strict pixel-art style, proportions, face width, eye size, head/body ratio and line-density reference; use its CENTER front idle pose as scale guide. Translate the woman in IMAGE1 into ONE full-body straight FRONT IDLE GAMEPLAY CHIBI SPRITE matching IMAGE2 exactly in style family. This is not another full illustrated portrait and not a sheet. Very large rounded head, broad rounded skin face, widely spaced big sage-green jewel eyes, tiny nose and tiny cheeky proud closed smile with slightly determined brows, compact torso, very short naturally attached arms and legs, about2.5-head-tall as image2. Keep A's warm chestnut fluffy short bob with curled angular ends, small hair curl on crown, TWO blue/yellow page-tab clips on viewer right hair. Cream puff-sleeve high-neck blouse, muted sage green pinafore craft apron over warm taupe ruffled skirt to knees, brown lace-up ankle boots, ivory socks. Simplify portrait micro-lace into a few large readable pixel clusters and hems; keep one blue/red notebook-rule detail on apron lower corner and tiny folded paper crane brooch. Both hands naturally cradle a substantial thick muted terracotta cardstock craft album vertically against chest to waist, below chin so whole face visible. Fingers hold lower side edges, short forearms actually connected to shoulders, no floating hands. Album has simple cream paper-crane cover motif, broad pink/blue/yellow cardstock page edges, two tabs and a tiny mint origami dinosaur peeking above pages. Make the book readable at game size, no tiny lettering, no tool clutter. Body stands neutrally with both feet visible on same baseline; centered foot anchor beneath head. STRICTLY chunky authentic pixel shapes and coherent stepped shade clusters matching IMAGE2, muted dark-plum contour, simple two/three-tone material shading, warm skin like heroine. NO smooth painterly textures/airbrush, NO fine portrait rendering, NO 3D render/vector. NO copy of image1's background/vignette/lighting halo. Genuine transparent background outside only this isolated character/book; no shadow/floor/glow/particles/scenery/castle/labels/text/panels/other people or alternate poses. Generous clear margins, no cropped hair or feet. Preserve identity and cheeky little director personality while adapting it to heroine's compact gameplay sprite.
