extends "res://scripts/world/woodland_world103.gd"
var woodland_ready104 := false
var fast_aim104 := true
var grade_enabled104 := true
var high_shadows104 := false
var shadow_original104 := Vector2.ZERO
var aim_key104: Array=[]
var aim_value104 := Vector3.INF
var aim_solves104 := 0
var aim_hits104 := 0
func _porch_script() -> Script: return preload("res://scripts/art/woodland_palette104.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time104.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 104 · 瞄准缓存 / 阴影预算 / 林荫色层")
func elevated_surface_point(point: Vector2) -> Vector3:
 if not fast_aim104 or floor_tiles.is_empty() or not is_instance_valid(ground): return super.elevated_surface_point(point)
 # Cache only static terrain intersection; enemy-body picking stays in aim_at_screen.
 # Camera and terrain mesh changes invalidate even a stationary mouse cursor.
 var key := [point,camera.global_transform,camera.fov,camera.h_offset,camera.v_offset,get_viewport().get_visible_rect().size,terrain_enabled,ground.mesh.get_instance_id()]
 if key==aim_key104: aim_hits104+=1;return aim_value104
 aim_key104=key;aim_solves104+=1
 var origin := camera.project_ray_origin(point);var ray := camera.project_ray_normal(point)
 var query := PhysicsRayQueryParameters3D.create(origin,origin+ray*300.,1)
 var hit := get_world_3d().direct_space_state.intersect_ray(query)
 if hit.is_empty(): aim_value104=Vector3.INF;return aim_value104
 var lo := 0.;var hi := origin.distance_to(hit.position)
 for i in 18:
  var t := (lo+hi)*.5;var at := origin+ray*t
  if at.y>floor_height(Vector2(at.x,at.z))+AIM_CLEARANCE: lo=t
  else: hi=t
 aim_value104=origin+ray*(lo+hi)*.5;return aim_value104
func set_shadow_quality104(high: bool) -> void:
 high_shadows104=high
 sun.directional_shadow_max_distance=shadow_original104.x if high else 42.
 sun.directional_shadow_mode=int(shadow_original104.y) if high else DirectionalLight3D.SHADOW_PARALLEL_2_SPLITS
func set_grade104(enabled: bool) -> void:
 grade_enabled104=enabled
 if is_instance_valid(porch49) and porch49.has_method("apply_grade104"): porch49.apply_grade104()
func _ready() -> void:
 super._ready()
 while not woodland_ready103: await get_tree().physics_frame
 shadow_original104=Vector2(sun.directional_shadow_max_distance,sun.directional_shadow_mode);set_shadow_quality104(false)
 for batch in forest87.flower_batches94: batch.material_override.set_shader_parameter("flower_petals104",true)
 aim_key104.clear();woodland_ready104=true;_title35();time55.update_guide()
 print("WOODLAND104_READY old_shadow=",shadow_original104," balanced=42/two_splits")
func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.alt_pressed:
  if event.physical_keycode==KEY_Q: set_shadow_quality104(not high_shadows104);time55.update_guide();return
  if event.physical_keycode==KEY_B: set_grade104(not grade_enabled104);time55.update_guide();return
 super._unhandled_input(event)
