extends "res://scripts/world/woodland_world104.gd"
var combat_budget105 := true
var floor_recent105: Dictionary={}
var floor_previous105: Dictionary={}
var floor_hits105 := 0
var floor_misses105 := 0
var woodland_ready105 := false
var projectile_canvas105: Node2D
var next_status105 := 0
func _status() -> void:
 var now := Time.get_ticks_msec()
 if combat_budget105 and world_ready and now<next_status105: return
 next_status105=now+200
 super._status()
func _clear_combat_shots() -> void:
 for shot in shots:
   if shot.has("art") and is_instance_valid(shot.art) and shot.art.get_meta("batched105",false): shot.art.queue_free()
 super._clear_combat_shots()
func _projectile_mesh_enabled24() -> bool: return not combat_budget105 or not legacy_feel
func _projectile_anchor24(at: Vector3) -> Variant:
 if not combat_budget105: return super._projectile_anchor24(at)
 var art := preload("res://scripts/combat/legacy_canvas24.gd").new()
 art.battle=self;art.at=at;art.set_meta("batched105",true)
 fx_layer.add_child(art);art.set_process(false);art.hide();return art
func _material_fx_script() -> Script: return preload("res://scripts/combat/material_fx105.gd")
func _frame_overlay_script67() -> Script: return preload("res://scripts/world/frame_overlay105.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time105.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 105 · 战斗运算预算 / 持续开火压测")
func _actor_shadow_script105() -> Script: return preload("res://scripts/combat/actor_shadow105.gd")
func _add_actor_shadow(actor: Node3D,sprite: Sprite3D) -> void:
 var shadow: MeshInstance3D=_actor_shadow_script105().new()
 shadow.battle=self;shadow.visual=sprite;shadow.enabled=silhouettes_enabled
 actor.add_child(shadow);actor_shadows.append(shadow)
 if actor==hero: hero_contact.hide()
 else:
  var contact: MeshInstance3D=actor.get("shadow")
  if is_instance_valid(contact): contact.hide()
func _fit_contact(mark: Node3D,at: Vector3,lift: float) -> void:
 if combat_budget105 and not mark.is_visible_in_tree(): return
 super._fit_contact(mark,at,lift)
func _update_bullet_shadow(shot: Dictionary) -> void:
 if not combat_budget105: super._update_bullet_shadow(shot)
func _process(delta: float) -> void:
 super._process(delta)
 if combat_budget105:
  # Shadow placement is visual; physics still advances/traces every shot at 60Hz.
  _draw_projectile_shadows105()
func _draw_projectile_shadows105() -> void:
 for shot in shots:
  if shot.has("shadow") and not shot.get("stream110",false): super._update_bullet_shadow(shot)
func _ready() -> void:
 super._ready()
 while not woodland_ready104: await get_tree().physics_frame
 projectile_canvas105=preload("res://scripts/combat/projectile_canvas105.gd").new();projectile_canvas105.battle=self;fx_layer.add_child(projectile_canvas105)
 floor_recent105.clear();floor_previous105.clear()
 woodland_ready105=true;_title35();print("WOODLAND105_READY backend=",ProjectSettings.get_setting("physics/3d/physics_engine"))
func invalidate_height_cache105() -> void:
 floor_recent105.clear();floor_previous105.clear()
func _cache_floor() -> void:
 super._cache_floor();invalidate_height_cache105()
func floor_height(at: Vector2) -> float:
 if not combat_budget105 or not woodland_ready105: return super.floor_height(at)
 if floor_recent105.has(at): floor_hits105+=1;return floor_recent105[at]
 if floor_previous105.has(at):
  floor_hits105+=1
  return floor_previous105[at]
 var height := super.floor_height(at);floor_misses105+=1
 # Exact coordinates, no rounding or changed height; two bounded generations.
 if floor_recent105.size()>=8192:
  floor_previous105=floor_recent105;floor_recent105={}
 floor_recent105[at]=height;return height
