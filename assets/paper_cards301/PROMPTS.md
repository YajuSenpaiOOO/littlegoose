# 301 · 吊线纸偶战斗试验

用户决定先停复杂城堡演出，改成天上的纸怪用线吊着小恐龙、小骑士、小怪兽卡片，先验证基本战斗。本轮内置image_gen三次生成，原始透明PNG无损复制至本目录，没有程序重绘/降采样。dinosaur以paper_stage298/dinosaur.png为编辑目标（去杆、加挂耳）；knight/monster以新的dinosaur.png作风格参考，不是人物身份参考。

来源目录 C:/Users/ASUS/.codex/generated_images/01a1902b-b815-7a03-a34e-5bf93c912ce8/
- dinosaur.png：exec-07cfab9b-c181-4306-ac5d-3319c37a1a02.png
- knight.png：exec-3b1444d7-0a0a-4e24-bf8c-19e45bd87455.png
- monster.png：exec-0c3c088b-38bd-4474-bb67-edbee0e7a97e.png

尺寸、alpha128有效边界、中心脚锚、顶部挂点、SHA256见layout.json。挂点从顶部约3%高度的不透明横截面取中点，是挂耳实体中的程序锚点，不承诺恰在孔洞中心。卡片有效高2.1m，独立StandardMaterial沿用纸布景策略：albedo=.7、正常受光、无主角倾斜法线贴图，平面固定X=-25度、保持原图比例。操纵者复用paper134/base_C.png，本体约1m，悬在卡片上方；独立材质，非发光。吊线为有深度的原生ImmediateMesh，端点由卡片实际transform和操纵者局部挂点计算，不是固定屏幕叠层。无新增灯光。

根节点在真实地形上以CharacterBody3D滑动，碰撞mask1|2，窄脚下胶囊作障碍响应，不把整张透明矩形当真实体积。hit Area3D capsule radius.65/height2是玩法受击范围；纸怪操纵者与线无额外受击/阻挡，打下面的卡片即可。无常态碰撞伤害，只有招式有效窗。复用actor_shadow113原生投影，显示浮起时地影由实际visual位移计算，不叠旧圆片接触影。已有主角169/192几何与脚点不改，不重开森林光照/树避让。

第一轮6张，顺序恐龙/骑士/怪兽/骑士/恐龙/怪兽，场上最多2张，后续每3秒在名额有空时进入；击落后最迟.8秒补位。每张18HP。进入.85秒降下且不可攻击，之后可用现有弹幕/弹力球/手电等攻击，不是存活等待战。恐龙锁定扇形火、骑士锁方向冲刺、小怪兽锁点砸落，预告统一.95秒，锁定后不继续追踪。每招最多一次1.5伤害，原生闪避/无敌/防御照常，完美弹反中断并晕1.5秒、反伤4。击落后操纵者把破卡往上收，.65秒淡出。

暂时不放城堡/妹妹，不走门、不复用开场演出；301只测纸偶攻击，不是正式纸妹妹Boss，没有Boss血条/阶段/掉落/剧情/正式进度。火目前用扇形地面发亮区域示意，并非完整纸火喷吐美术。旧团团资源只用作现有敌人字段/武器协议兼容底层，视觉替换为新卡片。300和291留作独立对照。

## dinosaur 完整提示词

Use case: gameplay pixel sprite targeted edit. Edit reference dinosaur paper puppet into a SINGLE hanging dinosaur cardboard cutout. Preserve cute sage-green cream terracotta small dinosaur, thick dark-plum stepped pixel outline, broad simple pixel clusters, handmade layered colored cardstock/tape look. Remove wooden pole completely, no ground stand, no operator or string drawn. Add ONE tiny reinforced cream hanging tab at top center directly above body so a runtime thread can attach. Full body feet tail visible, compact readable silhouette, neutral side-facing-left puppet view like reference. Genuine transparent background, no floor/shadow/scenery/text, no glow or painted lighting. One coherent cutout, not realistic animal, no sprite sheet.

## knight 完整提示词

Use case: gameplay pixel sprite, single new paper-cutout knight asset in same visual family as reference paper dinosaur. Reference only for chunky stepped dark-plum outlines, large pixel clusters, warm cream cardstock, sage/terracotta palette, tiny masking tape patches and flat handmade paper layers. Create ONE adorable toy cardboard LITTLE KNIGHT, compact oversized round helmet, friendly two-dot eyes in dark visor, short body, sage and muted dusty-blue paper armor, cream shield with simple terracotta star, small blunt cardboard lance pointing diagonally forward down toward viewer left. It is visibly a flat cutout stage puppet, not a living realistic person. One tiny reinforced hanging tab with hole at top center helmet. Full body/lance/shield visible with transparent margins. NO wooden pole, NO string, NO operator, NO stand or base, NO background/floor/shadow/text, no glow, no fine illustrative rendering. Fixed game-view cutout matching reference shape density. Genuine alpha transparency, one asset not sheet.

## monster 完整提示词

Use case: gameplay pixel sprite, single new hanging cardboard monster cutout asset. Reference dinosaur is STYLE reference only: thick stepped dark-plum outlines, large simple pixel clusters, handmade flat colored cardstock/tape layers, warm muted cream sage terracotta palette. Create ONE adorable chunky LITTLE MONSTER stage cutout, compact round dusty-lavender body, two tiny cream horns, big friendly eyes and a playful one-tooth grin, stubby broad arms raised outward and two short feet, cream belly with simple sage zigzag patch, tiny masking-tape repair. Cute theatrical pretender trying to look scary, not horror, no dinosaur or knight features. One reinforced cream hanging tab with small hole at TOP CENTER. Full silhouette all feet/arms visible, generous genuinely transparent alpha margins. No wood pole, NO rope/string/operator/stand/base, no scenery/shadow/floor/text/glow. Keep flat papercraft stage-puppet form, big readable pixel clusters, not smooth portrait rendering. One asset not sprite sheet.


## 本轮验证

Compatibility 36项全过，docs/paper301-validation.json。实际发射原生弹幕并命中真实受击Area；三类各自预告锁定、伤害、单次接触、完美弹反取消攻击、闪避无敌和暂停；检查两张上限、补位、六张清场、重开和控制恢复；新增真实StaticBody隔挡攻击的检查。无新script/shader错误，旧relay_flag245警告仍保留。

已看三类预告和分开站位的混合实机截图。修正第一轮过白：取消角色竖直法线的重复倾斜，采用纸布景.7基底受光；缩短操纵者至卡片本地3.1m+lift，防止砸地蓄力时出屏。验证截图的主角红色由受伤测试后冻结主角/世界物理造成，未改主角材质/配色。尚未人工连续游玩，也未做新增卡片四时段完整观感验收。火焰当前仍是高亮扇区占位，尚无专画纸火或喷吐动画；骑士/怪兽用程序整体位移摆动，不是已绘制多帧。

两处启动器latest301，75/stage300保留城楼演出对照，71/combat291完整团团/手电仍保留。未提交或push。
