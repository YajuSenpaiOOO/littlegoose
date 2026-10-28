extends "res://scripts/combat/buff_book39.gd"
const CHILD110=preload("res://scripts/combat/cards110.gd")
var rng110 := RandomNumberGenerator.new()
func eligible() -> Array[Dictionary]:
 var result: Array[Dictionary]=[]
 for card in CHILD110.POOL:
  if level(card.id)>=int(card.max): continue
  var blocked := false
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
