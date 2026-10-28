extends "res://scripts/world/forest194_capture.gd"
class Trial195:
 extends "res://scripts/world/woodland_world195.gd"
 func _hero_script() -> Script: return Walker194
func world_script192() -> Script: return Trial195
func result_prefix192() -> String: return "forest195"
func extra_checks192() -> void:
 await super.extra_checks192()
 sample.hero.command=Vector2.ZERO;sample.hero.controls_enabled=false;sample.hero.set_physics_process(false)
 var fade: RefCounted=sample.whole67
 verify(fade.get_script()==preload("res://scripts/art/whole_tree_fade195.gd"),"one shared foreground policy selected for all registered map trees")
 sample._teleport15(Vector2(-34.,27.));await hour(12.);await settle(120)
 sample.hero.velocity=Vector3(0,0,2.);await settle(90)
 verify(fade.forecast195.distance_to(fade.center_pixels)>8.,"southbound lookahead clears view before body overlap")
 await picture("south_lookahead")
 var held: Array=[]
 for entry in fade.entries.values():
  if entry.target: held.append(entry)
 verify(not held.is_empty(),"south forest route actually exercises occluding crowns")
 sample.hero.velocity=Vector3.ZERO;await settle(30)
 var retained := true
 for entry in held: retained=retained and entry.held>0. and entry.opacity<.6
 verify(retained,"brief stop retains faded group instead of immediately restoring crowns")
 await picture("south_stopped")
 var roots_match := true
 for piece in sample.root_pieces:
  if fade.entries.has(piece.sprite.get_instance_id()):
   roots_match=roots_match and is_equal_approx(float(piece.node.material_override.get_shader_parameter("fade")),float(piece.sprite.material_override.get_shader_parameter("fade")))
 verify(roots_match,"root pieces follow the same tree opacity")
 metrics.registered_trees=sample.trees.size();metrics.occluding_at_south=held.size()
