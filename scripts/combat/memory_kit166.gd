extends RefCounted
const CAPACITY := 4
const CARDS=preload("res://scripts/combat/cards166.gd")
const ORDER := ["hero_moment","pillow_hut","balloon_sword","paper_plane","slingshot","flashlight","snack","paper_racer","exercise","eye_exercise","forest_fireboy","three_player","music_class","red_banner","homework","distract","cup_phone","east_west"]
const COSTS := {"hero_moment":1,"pillow_hut":1,"balloon_sword":1,"paper_plane":1,"slingshot":2,"flashlight":2,"snack":2,"paper_racer":1,"exercise":1,"eye_exercise":1,"forest_fireboy":2,"three_player":3,"music_class":1,"red_banner":1,"homework":1,"distract":2,"cup_phone":2,"east_west":1}
const START := ["slingshot","flashlight","snack","paper_racer","exercise","eye_exercise"]
var equipped: Array[String]=["slingshot","paper_racer"]
var owned := {}
var crafted := {}
var unlocked := {}
func card(id: String) -> Dictionary:
 for entry in CARDS.POOL:
  if entry.id==id: return entry
 return {}
func used(ids: Array) -> int:
 var total := 0
 for id in ids: total+=int(COSTS.get(id,0))
 return total
func valid(ids: Array,stock: Dictionary={}) -> bool:
 if "balloon_sword" in ids and "flashlight" in ids: return false
 if "hero_moment" in ids and "homework" in ids: return false
 if stock.is_empty(): stock=owned
 var counts := {}
 for id in ids:
  if not id is String or not COSTS.has(id) or not unlocked.get(id,false): return false
  counts[id]=int(counts.get(id,0))+1
  if counts[id]>int(stock.get(id,0)): return false
 return used(ids)<=CAPACITY
func commit(ids: Array) -> bool:
 if not valid(ids): return false
 equipped.assign(ids);return true
func stock_valid118(stock: Variant,made: Variant,open: Variant) -> bool:
 if not stock is Dictionary or not made is Dictionary or not open is Dictionary: return false
 for id in ORDER:
  if not stock.get(id) is int or stock[id]<0 or stock[id]>999: return false
  if not made.get(id) is int or made[id]<0 or made[id]>stock[id]: return false
  if not open.get(id) is bool: return false
 return stock.size()==ORDER.size() and made.size()==ORDER.size() and open.size()==ORDER.size()
func migrate118(path: String) -> void:
 var old := preload("res://scripts/combat/memory_kit116.gd").new();old.load_from(path)
 if valid(old.equipped): equipped.assign(old.equipped)
func summary(ids: Array) -> String:
 var names := PackedStringArray()
 for id in ORDER:
  var count := ids.count(id)
  if count>0: names.append(str(card(id).name)+(" ×%d"%count if count>1 else ""))
 return "、".join(names) if not names.is_empty() else "先轻装出门"
func effect118(id: String,count := 1) -> String:
 var data := card(id)
 var words: String=data.fx
 if id=="slingshot": words="按住开火蓄力，松手发射可贯穿演员的重弹。"
 if count>1:
  if id=="slingshot": words+="\n第二份：重弹威力增强，蓄力更快。"
  elif data.has("fx2"): words+="\n第二份："+str(data.fx2)
  elif int(data.max)==1: words+="\n原效果只有一级；可重复占格，额外收益待设计。"
 if id=="east_west": words="旧版：随机获得碎片。制作制下的新效果待设计。"
 return words.replace("敌人","演员").replace("选三张必发","装配三份时必发")

const BALANCE119=preload("res://scripts/combat/encounter119_balance.gd")
var gel119 := 0
var next_event119 := 1
var last_reward119 := 0
func _init() -> void:
 equipped.clear()
 for id in ORDER: owned[id]=0;crafted[id]=0;unlocked[id]=id=="slingshot"
 for id in ["snack","exercise","hero_moment","paper_plane","homework","balloon_sword","pillow_hut"]: owned[id]=1;unlocked[id]=true
func load_from(path: String) -> void:
 var config := ConfigFile.new()
 if config.load(path)!=OK:
  if config.load("user://fixed_stage164.cfg")!=OK and config.load("user://hero_moment161.cfg")!=OK and config.load("user://pillow_hut160.cfg")!=OK and config.load("user://balloon_sword153.cfg")!=OK and config.load("user://paper_memories146.cfg")!=OK and config.load("user://tuantuan119.cfg")!=OK: return
 if config.get_value("memories","version",0)!=3: return
 var stock: Variant=config.get_value("memories","owned",{})
 var made: Variant=config.get_value("memories","crafted",{})
 var open: Variant=config.get_value("memories","unlocked",{})
 if not stock is Dictionary or not made is Dictionary or not open is Dictionary: return
 for id in ["snack","exercise","hero_moment","paper_plane","homework","balloon_sword","pillow_hut"]: stock[id]=maxi(1,int(stock.get(id,0)));made[id]=int(made.get(id,0));open[id]=true
 var ids: Variant=config.get_value("memories","equipped",[])
 var gel: Variant=config.get_value("memories","gel119",0);var next: Variant=config.get_value("memories","next_event119",1);var last: Variant=config.get_value("memories","last_reward119",0)
 if not stock_valid118(stock,made,open) or not ids is Array or not gel is int or gel<0 or gel>999999 or not next is int or next<1 or not last is int or last<0 or last>=next: return
 var previous := unlocked;unlocked=open
 if not valid(ids,stock): unlocked=previous;return
 owned=stock;crafted=made;equipped.assign(ids);gel119=gel;next_event119=next;last_reward119=last
func try_craft119(id: String,stock: Dictionary,made: Dictionary,gel: int) -> int:
 if id!="slingshot" or gel<BALANCE119.SLINGSHOT_GEL or not unlocked.get(id,false) or int(stock.get(id,0))>=999: return -1
 stock[id]=int(stock.get(id,0))+1;made[id]=int(made.get(id,0))+1
 return gel-BALANCE119.SLINGSHOT_GEL

func craft118(_id: String,_stock: Dictionary,_made: Dictionary) -> bool:
 # All crafting must pass the material-aware transaction, never the old free trial method.
 return false

func award119(event: int) -> bool:
 if event<=last_reward119 or event<=0 or event>=next_event119: return false
 gel119+=BALANCE119.GEL_REWARD;last_reward119=event;return true

func save_to(path: String) -> Error:
 var config := ConfigFile.new();config.set_value("memories","version",3)
 for field in ["equipped","owned","crafted","unlocked","gel119","next_event119","last_reward119"]: config.set_value("memories",field,get(field))
 return config.save(path)



