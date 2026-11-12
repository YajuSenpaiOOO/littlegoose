extends RefCounted
const BASE=preload("res://scripts/combat/balance_profile288.gd")
const CAPACITY=BASE.CAPACITY
const HEALTH=BASE.HEALTH
const CAT_HP=BASE.CAT_HP
const BAT_HP=BASE.BAT_HP
const BLOCKED=BASE.BLOCKED
const PRESETS=BASE.PRESETS
const COSTS := {"bouncy_ball":1,"hero_moment":2,"pillow_hut":2,"balloon_sword":1,"paper_plane":1,"slingshot":2,"flashlight":2,"snack":2,"exercise":1,"eye_exercise":2,"forest_fireboy":2,"three_player":4,"music_class":2,"red_banner":1,"homework":1,"distract":2,"cup_phone":2,"paper_racer":1,"east_west":1,"boarding_school":3}
static func cost(levels: Dictionary) -> int:
 var total:=0
 for id in levels:total+=int(COSTS.get(id,999))*int(levels[id])
 return total
static func error(levels: Dictionary,capacity: int=CAPACITY) -> String:
 var inherited:=BASE.error(levels,100000)
 if inherited!="":return inherited
 return "超过%d槽，请先卸下一份"%capacity if cost(levels)>capacity else ""
