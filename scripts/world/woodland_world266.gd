extends "res://scripts/world/woodland_world265.gd"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 266 · 断层前小憩 / 连续增援")
func boss_script251() -> Script:return preload("res://scripts/combat/tuantuan_rest266.gd")
func roster_script264() -> Script:return preload("res://scripts/combat/encounter_roster266.gd")
func minion_script260() -> Script:return preload("res://scripts/combat/tuantuan_minion266.gd")
func select_rest265() -> Vector2:
 var centre: Vector2=meadow.landmarks.grove
 # Authored bay in front of the ridge, beyond the decorative shrub line.
 for offset in [Vector2(0,-12),Vector2(-1.5,-12),Vector2(1.5,-12)]:
  var at=centre+offset;var path=entry_navigation261.path(centre,at)
  if path.is_empty() or path[-1].distance_to(at)>.8:continue
  var shape=BoxShape3D.new();shape.size=Vector3(4.1,1.2,2.6)
  var query=PhysicsShapeQueryParameters3D.new();query.shape=shape;query.collision_mask=2;query.transform.origin=Vector3(at.x,floor_height(at)+.7,at.y)
  if get_world_3d().direct_space_state.intersect_shape(query,1).is_empty():return at
 push_error("266 ridge-front rest bay blocked");return centre+Vector2(0,-12)
func place_rest265(sleeping: bool) -> void:
 if not rest_selected265:rest_at265=select_rest265();rest_selected265=true
 if not is_instance_valid(cushion265):
  cushion265=preload("res://scripts/art/rest_cushion266.gd").new();cushion265.battle=self;add_child(cushion265)
 cushion265.position=Vector3(rest_at265.x,floor_height(rest_at265),rest_at265.y)
 boss247.position=cushion265.position;boss247.reset_physics_interpolation();boss247.rest265(sleeping);time55.apply_look()
func _process(delta: float) -> void:
 super._process(delta)
 if ready264:guide206.text=guide206.text.replace("265 林间空地","266 林间空地").replace("265 大团团挑战","266 大团团挑战").replace("山脚","断层前")
