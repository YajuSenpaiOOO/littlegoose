# Yard route 15 — image generation record

Mode: built-in image_gen through imagegen skill, transparent_background=true for all four images. No CLI/API fallback. Selected assets copied into `assets/yard15`, original outputs retained under Codex generated_images. Original style A/number2 assets are unchanged.

Reference roles: `assets/forest14/a_cottage.png` supplies design and pixel painterly style; `assets/forest14/a_trees.png` supplies foliage/bark style. `cottage15_guide.png` and `cottage15_guide_close.png` are engine-rendered volume/camera guides, not target colors. `forest14_1.png` supplies actual scene/character scale for props.

## cottage_a

Saved: `assets/yard15/cottage_a.png`

Original: `C:\Users\ASUS\.codex\generated_images\01a142ad-c183-7d90-add6-6eb50443e39a\exec-c837f2e7-3234-4751-9de2-e03578d99a4d.png`

Use case: stylized-concept. Generate ONE isolated cottage on actual transparent background. Restrained painterly pixel-cluster illustration matching reference A from a woodland 2.5D RPG. Natural moss/sage foliage, warm timber, muted blue-gray stone, warm window lights, readable medium-scale detail, no shiny cartoon plastic and no photorealism. Reference1 is the DESIGN/PAINTING reference: retain red clay gable roof, timber cream walls, stone base, central arched door, three windows, flower boxes, chimney, one-and-half-story proportions. Reference2 is the ACTUAL GAME CAMERA geometry guide: use the house's roof depth, slight view of right side, foundation and front-wall foreshortening from this guide, NOT its plain material or surrounding world/UI. Correct the design reference's almost-flat elevation to a believable shallow down-view perspective. Camera nominal25 degrees depression, house offset to left of screen: modest right side visible (about 10 degrees yaw), front dominates, roof ridge extends back, coherent doorstep top plane and visible narrow stone plinth. Front-left warm light, darker underside/contact creases; NO baked cast shadow beneath object. Entire cottage and footing complete, 8% clear transparent margins, no terrain plate, grass, trees, UI or text.

## cottage_b

Saved: `assets/yard15/cottage_b.png`

Original: `C:\Users\ASUS\.codex\generated_images\01a142ad-c183-7d90-add6-6eb50443e39a\exec-55705655-d8ee-4513-bd52-689c8fae2851.png`

Use case: stylized-concept. ONE isolated woodland cottage transparent game sprite. Restrained painterly pixel-cluster illustration matching reference A from a woodland 2.5D RPG. Natural moss/sage foliage, warm timber, muted blue-gray stone, warm window lights, readable medium-scale detail, no shiny cartoon plastic and no photorealism. Reference1 supplies exact cottage DESIGN and pixel painterly style; reference2 supplies camera geometry of the plain house ONLY. Preserve red gable roof, stone/timber cream facade, central arched door, warm windows, chimney and small flower boxes. Redraw from a centered camera looking DOWN25 degrees from horizontal, closer and with slightly MORE clearly visible roof depth than reference1, consistent roof ridge extending away from viewer, step/plinth tops visible, front facade dominates, at most a very small side wall. Keep natural believable gable geometry, no isometric30/45 degree top-down view. This is a second camera-fit candidate of the SAME building, not a different house design. Complete foundation, cohesive upper-left warm light, deep eaves but no cast ground shadow. Transparent exterior, no ground patch, backdrop, other props, glow, UI or text; generous8% margin.

## trees

Saved: `assets/yard15/trees.png`

Original: `C:\Users\ASUS\.codex\generated_images\01a142ad-c183-7d90-add6-6eb50443e39a\exec-a11c90d0-a6e2-42ef-9401-a46942bd928e.png`

Use case: stylized-concept. Transparent sprite atlas with exactly THREE separate complete woodland trees in three non-overlapping equal-width cells side by side. Restrained painterly pixel-cluster illustration matching reference A from a woodland 2.5D RPG. Natural moss/sage foliage, warm timber, muted blue-gray stone, warm window lights, readable medium-scale detail, no shiny cartoon plastic and no photorealism. Match reference leaf rendering and bark detail, but create three DISTINCT companions: left a crooked young broadleaf with sparse small canopy and branching trunk; center a slender two-stem leafy tree with narrow crown; right a medium asymmetrical broadleaf leaning gently left, canopy smaller than the reference's large oak. All green healthy trees, no conifers. Camera25 degrees down from horizontal, upright trunks with complete short roots. Width of each tree fits inside its cell with clear transparent margins on all sides, roots fully uncropped. Leave at least5% canvas width transparent between silhouettes. Absolutely no glow/halo/haze, scenery, ground patches, shadows beneath roots, labels or text. Painterly pixel clusters, restrained outlines, dark leaf undersides and modest warm highlights. Landscape canvas around2.5:1 aspect, no tree touches an image edge.

## props

Saved: `assets/yard15/props.png`

Original: `C:\Users\ASUS\.codex\generated_images\01a142ad-c183-7d90-add6-6eb50443e39a\exec-cf0bbff7-d6d4-4d71-9fdf-2458560f59bc.png`

Use case: stylized-concept. Transparent game prop sprite atlas, exactly THREE separated objects side by side in equal width cells: left a modest neatly stacked firewood pile on a low timber rack; middle a simple sturdy rustic wooden bench with backrest; right one short low irregular mossy gray-stone garden wall segment. Restrained painterly pixel-cluster illustration matching reference A from a woodland 2.5D RPG. Natural moss/sage foliage, warm timber, muted blue-gray stone, warm window lights, readable medium-scale detail, no shiny cartoon plastic and no photorealism. Reference cottage supplies style and materials; in-game screenshot supplies camera context ONLY. Camera looking down25 degrees from horizontal, fronts face viewer, modest visible top surfaces and very shallow right side. Readable at80-140px wide in game, no overly tiny decoration. Whole object bottoms and feet visible, true transparent exterior and broad transparent gaps, no backdrop, vegetation tufts or ground discs, no baked cast ground shadows, no glow, no labels/text. Landscape sprite sheet with three full separated objects, no overlap and no cropped edges.

## Integration notes

Guide matching remains qualitative: the generated A cottage has more side wall than requested, and B was selected as default. Both are retained for comparison against original14. Numeric25-degree prompt alone is not taken as validation. Front-door foot anchors are manually calibrated using a narrow source-column band; roots and prop feet use UV geometry laid onto the actual terrain. Source PNGs are not rewritten by code. Tree/prop atlas cells gain transparent sampling margins and mipmaps at runtime.

