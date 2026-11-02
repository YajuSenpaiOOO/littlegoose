# 蜘蛛姐姐运输205 · 内置 imagegen

2026-10-28。身份/站姿基准来自工作区 art_workbench/spider_sister_gentle_idle12/assets/idle_front.png；坐姿/吊床/蝙蝠参考 art_workbench/spider_sister_bat_hammock15/occupied_hammock_open_front.png。不是把立绘降采样。生成透明原图原样复制，未用程序修图。

- idle.png：exec-16d31293-3c58-4407-b62f-7331b316c377.png
- seated.png：exec-badaed7d-db27-4966-96de-daf2fd901724.png
- hammock.png：exec-9d62c6d1-bec8-4f65-8284-ab9eb3648946.png
- bat_up.png：exec-db383177-36b2-4efb-a623-cc599832b5e6.png
- bat_down.png：exec-877703c8-ec9f-4644-869a-338cb6d43f6b.png

独立补画完整空吊床和坐姿身体。蝙蝠下拍基于上拍编辑，身体/挂环保持同画布位置；运行时以挂环配准，不按翅膀alpha边界缩放。单帧受遮挡部分补画存在生成差异，最终游戏比例需实机确认。

## seated

Use case: precise-object-edit. Extract/reconstruct ONLY the seated adult spider woman from this pixel-art transport keypose on transparent background. Remove BOTH bat plush carriers, gold hanging rings, all hammock cloth and any suspension parts. Preserve woman's exact face, glasses, head/body proportions, hairstyle/braid, clothes and colors, exactly four back spider appendages, seated front pose, bent knees and boots. Hands remain extended softly to left/right beside hips, palms braced as if resting on invisible seat side edges; same placement as original. Complete hidden skirt/hair/body behind removed hammock cleanly so sprite is standalone full seated woman. No seat, no base, no extra objects, no shadow. Same crisp pixel cluster art, no repaint into illustration. Whole head curl, limbs and boots with transparent margin. Single sprite, not a sheet.

## hammock

Use case: precise-object-edit. Draw ONLY the EMPTY lavender cloth hammock extracted/reconstructed from the supplied pixel-art keypose. Remove entire woman (including ALL hair, clothes, hands, shoes and spider appendages) and remove both bat plushies. Retain both gold suspension rings, gathered upper cloth knots, rising side cloth panels, ivory trim and tiny web motif. Reconstruct previously hidden fabric under her bottom as a continuous complete sagging shallow open-front sling seat. Full U shape: high left/right attachment rings, broad cloth sides, low central seat. No hole/notch/legs/character parts. Mild above view, exact same pixel-art palette and stepped dark outlines. One transparent cutout, generous margins, no background, no shadow. Clearly empty fabric swing, ready for separate seated sprite to layer in front.

## bat_up

Use case: precise-object-edit. Make ONE independent ball-shaped bat plush sprite based on the bat helpers in this reference. ONLY bat plush, no woman, no hammock, no cloth knots. Round muted plum stuffed body, tiny triangular ears, cheerful dot eyes, embroidered smile and simple cream stitched seam. TWO short lilac bat wings both lifted UP symmetrically, ready for a 2-frame flap. Small gold carrying ring hangs below round body, attached visibly to body by little loop. No limbs, no fur, no claws. Front-facing cute pixel art same palette/outline/density as reference. Entire wings and ring fit with generous transparent margin, no background, no text, no shadow. Single centered sprite.

## bat_down

Use case: precise-object-edit. Make the SECOND FLAP FRAME of this exact pixel bat plush. Keep canvas exactly same dimensions, keep round body, ears, eyes, mouth, seam and gold lower carrying ring at EXACTLY same pixel positions and sizes. CHANGE ONLY the two wings: swing BOTH wings clearly DOWNWARD so their tips are below the round body's middle, a distinct downstroke compared to original upward/outward spread. Keep wing roots fixed where they join body sides. Complete wings inside same canvas with transparent margin. Same clean pixel art palette and outline. No glow, no extra body movement, no background, no words. True transparent background. Single sprite.
