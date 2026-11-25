extends "res://scripts/room/room_shell396.gd"
# Accepted A desk is the baseline: 397 remains a historical material comparison.
var cabinets398: Dictionary={}
var old398: Array[Dictionary]=[]
var use_cabinets398:=true
func build_furniture() -> void:
 super.build_furniture()
 for id in ["wardrobe","wash"]:
  var root: Node3D=item356(id).root
  for c in root.get_children():
   if c is MeshInstance3D or c is Sprite3D or c==solid357:old398.append({"node":c,"visible":c.visible})
  var model:=preload("res://scripts/room/cabinet_model398.gd").new()
  root.add_child(model);model.build398(id);cabinets398[id]=model
 set_cabinets398(true)
func set_cabinets398(value: bool) -> void:
 use_cabinets398=value
 for id in cabinets398:cabinets398[id].visible=value
 for row in old398:row.node.visible=false if value else row.visible
func set_art356(value: bool) -> void:
 super.set_art356(value)
 # Historical bed display controls must not re-enable an old wardrobe behind the new one.
 if not cabinets398.is_empty():set_cabinets398(use_cabinets398)
