extends "res://scripts/room/room_shell395.gd"
var solids396: Dictionary={}
var use_solids396:=true
func build_furniture() -> void:
 super.build_furniture()
 for id in ["desk_chair","tea","tea_chair","goose_stool"]:
  var model:=preload("res://scripts/room/furniture_model396.gd").new()
  item356(id).root.add_child(model);model.build396(id);solids396[id]=model
 set_solids396(true)
func set_solids396(value: bool) -> void:
 use_solids396=value;set_desk395(value)
 for row in furniture394:
  if row.id=="desk":continue
  solids396[row.id].visible=value;row.sprite.visible=not value
  for c in row.originals:c.visible=false
  for c in row.shadows:c.visible=not value;c.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_SHADOWS_ONLY
