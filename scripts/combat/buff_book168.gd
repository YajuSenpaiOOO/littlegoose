extends "res://scripts/combat/buff_book39.gd"
const CHILD110=preload("res://scripts/combat/cards168.gd")
var rng110 := RandomNumberGenerator.new()
func eligible() -> Array[Dictionary]:
 var result: Array[Dictionary]=[]
 for card in CHILD110.POOL:
  if level(card.id)>=int(card.max): continue
  var blocked: bool=(card.id=="hero_moment" and level("homework")>0) or (card.id=="homework" and level("hero_moment")>0) or level("balloon_sword")>0 and card.id=="flashlight"
  for conflict in card.get("conflicts",[]):
   if level(conflict)>0: blocked=true
  if not blocked: result.append(card.duplicate(true))
 return result
func apply(id: String) -> bool:
 for card in eligible():
  if card.id!=id: continue
  levels[id]=level(id)+1
  if id=="east_west":
   var times := 2 if rng110.randf()<(.50 if level(id)==2 else .20) else 1
   for i in times:
    var options := eligible().filter(func(option: Dictionary) -> bool: return option.id!="east_west")
    if options.is_empty(): break
    var bonus: Dictionary=options[rng110.randi_range(0,options.size()-1)];levels[bonus.id]=level(bonus.id)+1
  return true
 return false
func summary() -> String:
 var names := PackedStringArray()
 for card in CHILD110.POOL:
  if level(card.id)>0: names.append(str(card.name)+(" ×"+str(level(card.id)) if level(card.id)>1 else ""))
 return " · ".join(names)



var moment_rate161 := 1.
func rate() -> float: return super.rate()*moment_rate161

var math_scope168 := 0
func level(id: String) -> int:
 if math_scope168>0 and id in ["forest_fireboy","three_player"]: return 0
 return super.level(id)
