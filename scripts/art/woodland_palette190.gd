extends "res://scripts/art/woodland_palette108.gd"
func _update_actor() -> void:
 super._update_actor()
 # Native Sprite3D lighting now supplies the spotlight response. Remove the
 # old painted-sprite gain and leave headroom for the white hair highlights.
 var old_gain := Color(1.+stage_strength57*.20,1.+stage_strength57*.10,1.+stage_strength57*.015)
 world.hero.visual.modulate*=Color(.72/old_gain.r,.72/old_gain.g,.72/old_gain.b,1.)
func _shader_include() -> String:
 return super._shader_include().replace("route_light89.gdshaderinc","route_light190.gdshaderinc")
func sample_field(at: Vector2) -> Color:
 var sample := super.sample_field(at)
 var low := Vector2(field_bounds.x,field_bounds.y);var high := low+Vector2(field_bounds.z,field_bounds.w)
 var gap := minf(minf(at.x-low.x,high.x-at.x),minf(at.y-low.y,high.y-at.y))
 sample.a*=smoothstep(0.,6.,gap)
 return sample
