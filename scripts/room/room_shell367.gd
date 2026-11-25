extends "res://scripts/room/room_shell366.gd"
var pixel367:=false
var pairs367: Array[Dictionary]=[]
var pixel_mats367: Array[ShaderMaterial]=[]
func build_furniture() -> void:
 super.build_furniture()
 var targets: Array=[
  [head364.get_child(0).material_override,Vector2(0.,0.),false],
  [pillow364.get_child(0).material_override,Vector2(1.,0.),false],
  [duvet_mesh366.material_override,Vector2(0.,1.),false],
  [throw_mesh366.material_override,Vector2(1.,1.),false],
  [fitted365.material_override,Vector2(0.,2.),false],
  [skirt365.material_override,Vector2(1.,2.),true]]
 var atlas:=source356("res://assets/room367/pixel_bed_atlas.png")
 for entry in targets:
  var original: ShaderMaterial=entry[0]
  var m:=ShaderMaterial.new();m.shader=preload("res://scripts/room/pixel_bed367.gdshader")
  m.set_shader_parameter("pixel_atlas",atlas);m.set_shader_parameter("tile",entry[1]);m.set_shader_parameter("repeat_u",entry[2])
  var plain: Variant=original.get_shader_parameter("plain_color")
  if plain!=null:m.set_shader_parameter("plain_color",plain)
  pixel_mats367.append(m);craft_mats364.append(m)
  for node in craft364.find_children("*","MeshInstance3D",true,false):
   if node.material_override==original:pairs367.append({"node":node,"original":original,"pixel":m})
 set_pixel367(false)
func set_pixel367(value: bool) -> void:
 pixel367=value
 for row in pairs367:row.node.material_override=row.pixel if value else row.original
