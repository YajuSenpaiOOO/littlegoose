extends "res://scripts/combat/balloon_shadow154.gd"
func projection_shader154() -> Shader: return preload("res://scripts/art/balloon_shadow158.gdshader")
func _process(delta: float) -> void:
 super._process(delta)
 if visible and gpu113:
  var body: MeshInstance3D=visual.get_meta("mesh154")
  ink.set_shader_parameter("clip_tip158",body.material_override.get_shader_parameter("clip_tip158"))
