extends "res://scripts/room/room_shell396.gd"
var pixel397:=true
var materials397: Array[Dictionary]=[]
func build_furniture() -> void:
 super.build_furniture()
 var variants: Dictionary={}
 for piece in desk_model395.pieces395:
  var original: Material=piece.material_override
  var key: int=original.get_instance_id()
  if not variants.has(key):
   var variant: Material=original
   if original is ShaderMaterial and original.shader==preload("res://scripts/room/wood395.gdshader"):
    var wood:=original.duplicate() as ShaderMaterial;wood.shader=preload("res://scripts/room/wood397.gdshader")
    wood.set_shader_parameter("paint",preload("res://assets/room397/wood-atlas.png"));variant=wood
   elif original is StandardMaterial3D and original.albedo_texture!=null and original.albedo_texture.resource_path=="res://assets/room395/details-atlas.png":
    var detail:=original.duplicate() as StandardMaterial3D
    detail.albedo_texture=preload("res://assets/room397/details-atlas.png")
    detail.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;variant=detail
   variants[key]=variant
  materials397.append({"piece":piece,"a":original,"b":variants[key]})
 set_pixel397(true)
func set_pixel397(value: bool) -> void:
 pixel397=value
 for row in materials397:row.piece.material_override=row.b if value else row.a
