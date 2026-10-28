extends RefCounted
const CAPACITY := 4
const CARDS=preload("res://scripts/combat/cards110.gd")
const COSTS := {"slingshot":2,"flashlight":2,"snack":2,"paper_racer":1,"exercise":1,"eye_exercise":1}
const ORDER := ["slingshot","flashlight","snack","paper_racer","exercise","eye_exercise"]
var equipped: Array[String]=["slingshot","paper_racer"]
func card(id: String) -> Dictionary:
 for entry in CARDS.POOL:
  if entry.id==id: return entry
 return {}
func used(ids: Array) -> int:
 var total := 0
 for id in ids: total+=int(COSTS.get(id,0))
 return total
func valid(ids: Array) -> bool:
 var seen := {}
 for id in ids:
  if not id is String or not COSTS.has(id) or seen.has(id): return false
  seen[id]=true
 return used(ids)<=CAPACITY
func commit(ids: Array) -> bool:
 if not valid(ids): return false
 equipped.assign(ids);return true
func save_to(path: String) -> Error:
 var config := ConfigFile.new();config.set_value("memories","version",1);config.set_value("memories","equipped",equipped)
 return config.save(path)
func load_from(path: String) -> void:
 var config := ConfigFile.new()
 if config.load(path)!=OK or config.get_value("memories","version",0)!=1: return
 var ids: Variant=config.get_value("memories","equipped",[])
 if ids is Array and valid(ids): equipped.assign(ids)
func summary(ids: Array) -> String:
 var names := PackedStringArray()
 for id in ids: names.append(str(card(id).name))
 return "、".join(names) if not names.is_empty() else "先轻装出门"
