extends "res://scripts/art/forest_projection186.gd"
func _ready() -> void:
 super._ready();ink.shader=preload("res://scripts/art/forest_projection187.gdshader")
func _process(delta: float) -> void:
 super._process(delta)
 if not is_instance_valid(visual): return
 var source: Texture2D=visual.texture
 if source is AtlasTexture:
  var extent: Vector2=source.atlas.get_size()
  ink.set_shader_parameter("paint",source.atlas)
  ink.set_shader_parameter("region187",Vector4(source.region.position.x/extent.x,source.region.position.y/extent.y,source.region.size.x/extent.x,source.region.size.y/extent.y))
 else: ink.set_shader_parameter("region187",Vector4(0,0,1,1))
