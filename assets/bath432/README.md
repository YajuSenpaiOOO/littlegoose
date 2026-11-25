# 澡棚拉帘演出

## 搁桶台摆件

`rack-atlas.png`（1254 × 1254）由内置 ImageGen 参考澡棚设计图生成，四格依次是镀锌铁、白鹅搪瓷、黑鹅搪瓷、绿漆金属。色图贴合真实杯壁与壶身，杯口、把手、桶提梁和壶塞是立体网格。铁桶落在下层，杯和壶落在上层，随场景受光并使用原搁桶台的碰撞。摆件没有自发光。

### 摆件贴图提示词

One square four-quadrant hand-painted material atlas for a fairy-tale wash shed, using the small prop detail in the supplied concept sheet as palette and illustration reference. Exactly four equal square quadrants; each square goes edge-to-edge with no separators, title, labels, lettering or outside margins. Upper left = flat diffuse texture only, mottled old silver-gray galvanized zinc with light soft broad spangle marks like an old farm bucket, not shiny chrome. Upper right = flat buffalo-cream vintage enamel with exactly one small cute white goose with orange bill and feet facing right centered in the square; the goose occupies about 55% of the square width, with empty enamel around it, no border, no writing. Lower left = same vintage cream enamel, exactly one small charcoal black goose with orange bill and feet facing left centered in the square, same composition and scale. Lower right = flat old muted sage teal green paint on a metal flask with a little worn stipple, subtle scattered small brass-brown worn spots, no scratches larger than 7% of that tile. All quadrants are flat material or decal swatches, no illustrated cup itself, no handles, no 3D preview, no cast shadows, no highlights painted around the goose. Broad hand-painted watercolor and gouache brushwork, restrained and readable at small game scale, muted naturally worn country colors.

## 澡棚表面与挂巾

`surface-atlas.png`（1254 × 1254）和 `wall-towels.png`（可见布与木挂件外保留原透明通道）由内置 ImageGen 参考 `art/concepts/bath432/a-open-curtain-revised.png` 生成。色图按灰泥、红砖、灰陶瓦和红塑料的顺序在运行时取样。瓦图贴在起伏网格上，灰泥和砖沿墙面投影，塑料沿原立体盆壁及盆沿贴合。

挂巾是带木钉板和挂杆的竖直平面，固定在后墙内侧，整张有效悬挂物宽约 1.24 米，锚点在画片底缘中点。挂巾随棚内灯光受光，深度由实际墙面和帘子遮挡，无独立碰撞、自发光或动态投影。表面图继续使用本体已有的照明与碰撞。

### 材质图生成提示词

Create ONE square hand-painted environment material atlas for a rustic fairy-tale outdoor wash shed. The reference design sheet defines style and palettes only. Geometry and lighting are supplied by a game engine. EXACT four equally sized quadrants meeting directly at x=50%, y=50% edge to edge, no dividers, text, margin or background. Top-left: light warm oatmeal aged lime plaster, very faint broad painted patches, some subtle warmer flecks, largely quiet, flat base color. Top-right: muted handmade terracotta reddish-brown horizontal bricks in running bond, broad slightly irregular rectangular bricks and subdued warm tan mortar, three to four legible horizontal rows, some subtle painted chips. Bottom-left: a repeating clay roof texture of rounded longitudinal gray charcoal brown half-cylindrical tiles, rows of overlaps, woodcut/storybook brushwork; tile lengths run vertically on the image and visible ridges also run vertically, slate grey with slight warm weathering. Top-down straight orthographic surface swatch, no perspective, no edges of building. Bottom-right: worn vermilion-red molded plastic flat base color with a few broad subtle cloudy scuffs, very gentle wear markings, no gradients. All four are tileable by intent, diffuse/albedo without harsh cast shadows or bright baked highlights. Restrained natural brushwork with medium-scale readable shapes like the design sheet, no speckle overload or photo textures.

### 毛巾生成提示词

Create one alpha transparent video game hanging prop sprite, art modeled on the wash shed in the supplied concept. Flat frontal orthographic elevation, one small warm wooden rail with two groups of towels: left a cream hand towel hanging from a wooden peg, with a tapered softly folded shape; right a wider folded rectangular cream towel draped over a short warm wood towel bar. Both have two dark muted slate blue woven stripes above hem and gentle scalloped cloth drape. The group spans a comfortably wide roughly 2:1 rectangle, with modest quiet gap between the fabrics. Storybook hand-painted illustrated material, textured like the reference, broad linen folds and restrained warm shadows. Authentic fully transparent alpha around silhouette with clear gap between shapes, no wall or backdrop, anchors included, no cast shadow outside asset, no text or other props.

`curtain-peek.png` 是当前实机过场使用的透明立绘，由内置 ImageGen 参考上一版插画生成。角色面向棚前镜头，约 0.78 米高的垂直画片放在真实帘布后方，帘缝承担前景遮挡。角色画片无碰撞和投影，受场景光和独立暖色补光，补光仅照立绘。台词由游戏界面绘制。

### 当前立绘提示词

Create a single transparent-background 2D game sprite for a cozy fairy-tale in-engine dialogue closeup. Match the white lavender hair, pink feather hair clip, pink eyes, fine hand-painted anime linework, and facial design in the reference (ignore the reference outfit and background). Front-facing head-and-shoulders view, with a small lean to the viewer's right as she peeks from behind an offscreen curtain. She makes soft eye contact with faint pink cheeks, with a little surprised and earnest expression while asking a friend a favor. The framing is a conventional wholesome headshot, from hair tip to just below the shoulders. Simple pale peach opaque towel wrapped high across the shoulders' base to cover the entire torso; only head, neck, and shoulder tops are visible. No hands, no bath, no objects, no curtain, no text, no borders. True alpha background, no colored backdrop or glow halo. Leave small safe margins; fit the full hair silhouette in the frame, and keep the hair/body cut naturally along the bottom. Gentle neutral warm lighting and restrained color, with softly painted skin and hair. Portrait or square composition.

## 历史全屏插画试演

`curtain-glance.png` 是内置 ImageGen 生成的 1672 × 941 全幅插画，参考 `assets/portrait_references/hero/pose_c_lighting_v2.png` 与 432 澡棚正面实机截图。半身特写使用保比例铺满，画面右侧的手和蓝格帘边是切镜的视觉锚点。

插画只显示在 `bath_cutscene432.gd` 管理的演出画布上，不参与世界遮挡、碰撞或光照。帘布过渡由 `bath_cloth_wipe432.gdshader` 绘制。场景内的帘子使用真实双面网格，有可见遮挡，不增加碰撞或动态投影；棚内陶罩灯继续提供局部照明。

## 生成提示词

Illustration-story game CG still for a curtain-pull transition in a handcrafted cozy fairy-tale game. The first image is a character identity and linework reference ONLY: keep the white/lilac hair, pink feather hair clip, pink eyes, watercolor anime outline and layered pale pink clothing, adapted into a fully covering everyday long-sleeved high-neck pink blouse and brown pinafore. The second image is a reference for the small wood shelter's blue and cream checked curtain, warm ochre wood and close-up camera ONLY. One single 16:9 landscape illustration with no HUD, text, frame, collage, or bars. Eye-level intimate medium close-up framed on FACE, shoulders and one hand, character from head to upper chest, positioned around 40% of frame width, not showing anything below the upper chest. She makes shy surprised eye contact with the viewer and gently blushes, as if to say ‘a little privacy, please!’ Her naturally proportioned hand gently pinches the vertical hem of a blue-and-cream gingham curtain already at the screen right around 65% of the width. The curtain occupies the far right ~30%, helping stage a right-to-left wipe. The dark wood post on the far left and the warm pendant lamp bokeh behind her establish continuity with the game. Gentle warm light over the eyes and hair, small soft shadows and lightly illustrated fabric grain. Peaceful, innocent, and storybook-like. No bathing depicted, everyone fully clothed. No added characters, text, or graphics.
