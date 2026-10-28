extends "res://scripts/art/hill_plants143.gd"
func _ready() -> void:
 super._ready()
 # These are soft fronds, not solid shrubs. Keep the shader's walker/trail push.
 for body in shrub_bodies143:
  body.collision_layer=0;body.queue_free()
 shrub_bodies143.clear()
 for batch in batches107:
  if batch.material_override.shader.code.contains("reactive94"):
   batch.material_override.set_shader_parameter("reactive94",true)
   batch.material_override.set_shader_parameter("field94",true)
