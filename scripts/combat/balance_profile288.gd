extends RefCounted
const BASE=preload("res://scripts/combat/balance_profile275.gd")
const CAPACITY=BASE.CAPACITY
const HEALTH=BASE.HEALTH
const CAT_HP=BASE.CAT_HP
const BAT_HP=BASE.BAT_HP
const COSTS=BASE.COSTS
const BLOCKED=BASE.BLOCKED
const PRESETS=[
 {"name":"光能弹力","levels":{"flashlight":1,"bouncy_ball":1,"exercise":1}},
 {"name":"光能速射","levels":{"flashlight":1,"eye_exercise":1}},
 {"name":"重弹笔记","levels":{"slingshot":1,"homework":1}},
 {"name":"气球剑","levels":{"balloon_sword":1,"exercise":1}},
 {"name":"主角时刻","levels":{"hero_moment":1,"eye_exercise":1}},
 {"name":"本体对照","levels":{}}
]
static func cost(levels: Dictionary) -> int:return BASE.cost(levels)
static func error(levels: Dictionary,capacity: int=CAPACITY) -> String:
 if levels.get("flashlight",0)>0 and (levels.get("hero_moment",0)>0 or levels.get("homework",0)>0):return "手电筒、主角时刻、课堂笔记共用Q主动位置"
 return BASE.error(levels,capacity)
