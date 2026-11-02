extends RefCounted
const CAPACITY := 6
const HEALTH := 14.
const CAT_HP := 160.
const BAT_HP := 32.
const COSTS := {"hero_moment":2,"pillow_hut":2,"balloon_sword":1,"paper_plane":1,"slingshot":2,"flashlight":2,"snack":2,"exercise":1,"eye_exercise":2,"forest_fireboy":1,"three_player":2,"music_class":2,"red_banner":1,"homework":1,"distract":2,"cup_phone":2,"paper_racer":1,"east_west":1,"boarding_school":3}
const BLOCKED := ["boarding_school","paper_racer","east_west"]
const PRESETS := [
 {"name":"普通机队","levels":{"three_player":1,"eye_exercise":1,"paper_plane":1,"exercise":1}},
 {"name":"舞台爆发","levels":{"three_player":1,"hero_moment":1,"eye_exercise":1}},
 {"name":"小屋稳健","levels":{"three_player":1,"pillow_hut":1,"paper_plane":1,"homework":1}},
 {"name":"重弹笔记","levels":{"forest_fireboy":1,"slingshot":1,"homework":1,"eye_exercise":1}},
 {"name":"气球剑机队","levels":{"three_player":1,"balloon_sword":1,"paper_plane":1,"eye_exercise":1}},
 {"name":"本体对照","levels":{}}
]
static func cost(levels: Dictionary) -> int:
 var total=0
 for id in levels:total+=int(COSTS.get(id,999))*int(levels[id])
 return total
static func error(levels: Dictionary) -> String:
 if int(levels.get("music_class",0))>0:
  if int(levels.music_class)!=1:return "乐器课原型仅开放一份"
  for weapon in ["slingshot","flashlight","balloon_sword","paper_plane"]:
   if int(levels.get(weapon,0))>0:return "乐器课原型先使用普通弹幕，此武器的节奏适配待制作"
 for id in levels:
  if not COSTS.has(id):return "未知碎片"
  if id in BLOCKED and int(levels[id])>0:return "该碎片不参与本轮第一地区测试"
  var card={}
  for entry in preload("res://scripts/combat/cards168.gd").POOL:
   if entry.id==id:card=entry;break
  if not levels[id] is int or levels[id]<0 or levels[id]>int(card.get("max",1)):return "碎片份数超出有效等级"
 if levels.get("hero_moment",0)>0 and levels.get("homework",0)>0:return "主角时刻与课堂笔记共用主动位置"
 if levels.get("balloon_sword",0)>0 and levels.get("flashlight",0)>0:return "气球剑与手电筒不能同时装配"
 if cost(levels)>CAPACITY:return "超过6槽，请先卸下一份"
 return ""
