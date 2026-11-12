# 299 · 简化落景 / 正常纸怪抱杆

## 同轮用户追加修订：恐龙放大、纸边卷住杆

用户追加反馈恐龙偏小，纸怪应以边角卷住木杆。本轮第二次内置image_gen编辑生成operator_dinosaur_v2.png，以第一组合为编辑目标：增大恐龙相对纸怪的比例，把矩形夹片换成与纸怪侧边连续相接的S形卷边，横线/红边随卷边延续。原图仍无程序修绘，v1保留对照。来源exec-5b7d44b0-2851-4e2e-b2bc-6f966d641d66.png，原目录同上。元数据layout_v2.json。

运行改用v2：1160×1355，alpha128边界[50,11,968,1310]，纸怪本体约y658..1310=652px，pixel=(37/24)/652，组合总高约3.07m，脚锚(740,1310)。定标是人工估计纸怪轮廓，没把整组缩到普通怪身高，也不宣称生成器精确放大35%。视觉上恐龙比v1明显增大，纸怪本体仍按普通37/24m标定。

高纸偶不再穿低拱门，以免恐龙脑袋穿门框：走城堡左侧后绕出，门仍保留原开合演示。路径为本地(-4.6,-1.3)→(-6.1,1.1)→(-3.7,3.7)→(-1.1,4)，沿原地形采高。这是无伤害表演路径，不是已验证的正式怪物导航/避障；不能称作真实碰撞角色成功绕墙。妹妹城楼折纸/指挥的关键帧仍未绘制，本轮只完成落景与抱杆试验。

### v2完整提示词

Use case: targeted identity-preserve pixel-game sprite edit. Edit the attached paper-monster holding dinosaur puppet composition. Preserve paper monster body size, friendly notebook face, cream paper, blue rules/red margin, folded upper corner, lower-body shape, ground baseline, sage/cream/terracotta dinosaur identity, wooden pole and SAME chunky pixel art cluster scale/outline/palette. TWO changes only. (1) Make DINOSAUR PUPPET about35percent larger RELATIVE TO PAPER MONSTER; dinosaur body/head/tail grows together, more substantial silhouette, paper monster remains same physical body height. Expand transparent canvas/margins if necessary, don't shrink the entire composition to hide this size change. Preserve exactly one dinosaur attached to exactly one pole. (2) Replace the two rectangular mitten-like clamps on pole with the PAPER SHEET'S OWN EDGE CORNERS CURLING AROUND THE POLE. Left edge of main notebook sheet must visibly continue into two rolled/tapered paper corners that spiral partly around wooden stick, with curved fold underside and thickness; blue ruling/red margin may continue into curls where natural. Continuous paper from body to curl, no separate pasted rectangular straps/gauntlets, no detached bands, no human arms/fingers. Keep monster's eyes and smile unobstructed. Rod passes through wrapped curls, visibly held rather than just adjacent. Full sheet bottom, rod end, enlarged dinosaur head/tail/feet all visible in generous alpha margins. Same neutral fixed game view; no extra objects/characters, no background/shadow/text or scene. Genuine transparent background. It is one coherent moving gameplay sprite; do not redesign into a realistic dinosaur or an illustrated portrait.

用户觉得298演出仍怪，提出纸片从天上落下插固定位置或由纸怪吊下，指出正常纸怪抱恐龙木杆需专画，妹妹也需要扒城楼折纸/指挥，担心复杂度。本轮只试最简单的直落插景＋抱杆组合，不增加绳索吊装/妹妹新动作/攻击系统。298保留对照。

## 落景

paper_stage299继承298，城堡/两侧山树保持最终相机平面X=-25度，仅沿世界Y从视野上方落下，脚点轻微下压回弹后稳定。城堡.8–1.42秒从13m上方落下，两侧景1.45/1.83秒分别由10m上方落下，持续.48秒。没有从地面翻起、横向飞行或演员平移，也不复活297的程序书/地板。原山顶草地/场地位置/门及地面碰撞、固定妹妹和门口出场路线保留。落稳后才启用既有碰撞；门仍可开合。原生地影跟随卡片，没新增灯。一次小幅trauma仅示意插稳力度，非正式伤害。

## 抱杆资产

内置image_gen，引用paper134/base_C（普通作业纸种族）与paper_stage298/dinosaur（纸偶配色/杆），生成一张纸怪抱杆连恐龙的组合图。两侧纸角折成夹持片包住木棍；无人体手臂。整张图一起摆动/移动，接触关系不会发生旧独立节点的错位。原始PNG无程序改绘/降采样，来源C:/Users/ASUS/.codex/generated_images/01a1902b-b815-7a03-a34e-5bf93c912ce8/exec-3e2c4ff5-2654-4a50-9749-18fc12442c6c.png。

operator_dinosaur.png尺寸1160×1355，alpha128边界[97,41,1012,1297]。原PNG信息/hash见layout.json；图中纸怪本体约y526..1297，共771px（人工估计），以原普通纸怪37/24=1.5417m定像素比例，pixel_size=(37/24)/771≈.002，组合总有效高约2.51m。运行脚点(681,1297)取纸怪身体下方，不以包含上方纸偶的整图中心定占地；这是候选视觉标定，仍待用户观感确认。保留原始bounds中心脚点在metadata作原图记录，运行实际挂点以本文/代码为准。

原298独立小操纵者隐藏，恐龙节点换组合图，沿原门口路径走；旧操纵者原生投影因其隐藏而同步不显示，组合复用恐龙节点投影。角色没有正式碰撞/血量/AI，图中纸怪不是战斗目标。当前整体高于原恐龙，穿门时上方纸偶会被门框逐步遮挡，仍需要确认后选压低杆/出大门或侧绕路线，不能宣称该动作物理制作完整。

## 控制与范围

world299是独立开场入口，F12重播/F3回院。最新299，73/stage298保留上版、72/stage297更早版、71/combat291完整战斗，169不改。没有正式进度或奖励变化。

妹妹扒城垛/低头折纸/抬手指挥暂列下一步少量关键姿态，不扩充一整套行走动画或绳索吊装。已存在抱书与空手抬手两帧；本轮没有新生成妹妹姿态，也没有解决关门后被城堡遮住的问题。先确认简单落景与纸怪的尺寸、抱杆是否成立。

## 验证

validate_paper299检查无旧3D书地板、组合图/普通纸怪尺寸、固定显示面下落、固定女孩、落点接地、原门口入场、重播/取消/恢复控制。报告docs/paper299-validation.json，截图paper299-{falling,castle-drop,wing-drop,landed,operator}.png。以最终报告为准，不能当Boss实战或完整各角遮挡验收。

最终v2实机20项检查全通过，无新script/shader错误，保留既有relay_flag245警告；已看castle-drop/landed/operator截图。验证已随v2调整为按652px纸怪本体标定，以及从侧后绕出，不再以穿门为通过条件。没有验证真实敌人的碰撞寻路或新增战斗。人物城楼姿态仍未做，本轮到此为止，避免把简单演出扩成一整套吊装/行走系统。

## 完整生成提示词

Use case: production pixel-game composite animation asset. IMAGE1 is the ordinary PAPER MONSTER: preserve its cream notebook sheet body, blue horizontal ruled lines, red left margin line, torn left edge, folded upper corner, tiny dark oval eyes and small smile. IMAGE2 is the paper DINOSAUR PUPPET with control rod, preserve sage/cream/terracotta cardstock and chunky pixel style. Draw ONE connected full-body OPERATOR HOLDING DINOSAUR-ROD composition, genuine transparent background. Critical: paper monster is NORMAL-SIZED, not a miniature assistant: its sheet body must occupy about65% of composition's full visible height, while small dinosaur above it is about45%, overlap between zones is fine. Place the paper monster lower-right, standing/floating just above a common ground baseline. It has no human arms/legs: two side corners of the paper curl forward into short folded-paper hand tabs that visibly WRAP AROUND and firmly grip the vertical rod at two nearby heights, with clear overlap/contact. No disembodied human hands. Rod is in front/left of sheet, ends near sheet bottom not far below. Dinosaur is attached at upper-left of rod above the monster, not merely floating beside it; body small enough for normal sheet monster to hold. Operator's simple friendly face remains visible to right of pole. All components unified in one sprite so pole and folded grips cannot drift apart. Cozy ugly-cute amateur puppet theatre, slight whole assembly lean, naturally readable support and weight. Keep exact species identity of ordinary paper sheet and same chunky pixel clusters/outline scale as references, simple stepped shading no smooth illustration. Dinosaur is paper cutout not living creature; no extra dinosaur stick in its body. ONE operator and ONE dinosaur only. Whole thing and sheet bottom/rod end inside generous alpha margins, no ground/shadow/scenery/text/labels/extra poses.
