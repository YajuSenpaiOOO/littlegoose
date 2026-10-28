extends "res://scripts/combat/memory_kit118.gd"
const BALANCE119=preload("res://scripts/combat/encounter119_balance.gd")
var gel119 := 0
var next_event119 := 1
var last_reward119 := 0
func _init() -> void:
 equipped.clear()
 for id in ORDER: owned[id]=0;crafted[id]=0;unlocked[id]=id=="slingshot"
func try_craft119(id: String,stock: Dictionary,made: Dictionary,gel: int) -> int:
 if id!="slingshot" or gel<BALANCE119.SLINGSHOT_GEL or not super.craft118(id,stock,made): return -1
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
func load_from(path: String) -> void:
 var config := ConfigFile.new()
 if config.load(path)!=OK or config.get_value("memories","version",0)!=3: return
 var stock: Variant=config.get_value("memories","owned",{});var made: Variant=config.get_value("memories","crafted",{});var open: Variant=config.get_value("memories","unlocked",{})
 var ids: Variant=config.get_value("memories","equipped",[])
 var gel: Variant=config.get_value("memories","gel119",-1);var next: Variant=config.get_value("memories","next_event119",0);var last: Variant=config.get_value("memories","last_reward119",-1)
 if not stock_valid118(stock,made,open) or not ids is Array or not gel is int or gel<0 or gel>999999 or not next is int or next<1 or not last is int or last<0 or last>=next: return
 var previous := unlocked;unlocked=open
 if not valid(ids,stock): unlocked=previous;return
 owned=stock;crafted=made;equipped.assign(ids);gel119=gel;next_event119=next;last_reward119=last
