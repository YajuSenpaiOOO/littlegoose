extends "res://scripts/combat/actor_shadow113.gd"
func projection_shader154() -> Shader: return preload("res://scripts/art/balloon_shadow154.gdshader")
func _process(delta: float) -> void:
 super._process(delta)
 if not visible: return
 if gpu113 and ink.shader!=projection_shader154():
  ink.shader=projection_shader154();field_revision113=-1;last_texture=null
  super._process(0.)
 if not gpu113: return
 var body: MeshInstance3D=visual.get_meta("mesh154")
 var source: ShaderMaterial=body.material_override
 for param in ["tip154","bend154","squash154","collapse154"]: ink.set_shader_parameter(param,source.get_shader_parameter(param))
 var look: Dictionary=battle.time55.palette.sample(battle.time55.visual_hour)
 var sun_amount: float=lerpf(.18,.8,float(look.daylight))
 ink.set_shader_parameter("opacity",.30*sun_amount*float(source.get_shader_parameter("fade154")))
