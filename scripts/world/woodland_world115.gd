extends "res://scripts/world/woodland_world114.gd"
const ACQUIRE_ANGLE115 := .56 # 32 degrees to acquire; no small pixel-radius gate.
const RETAIN_ANGLE115 := .96 # 55 degrees to retain while the pointer drifts.
const SWITCH_MARGIN115 := .14
const CURSOR_DEADZONE115 := 28.
var woodland_ready115 := false
func _init() -> void: auto114=false
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 115 · 方向软锁定 / 手动射击")
func _trial_ui_script114() -> Script: return preload("res://scripts/combat/trial_ui115.gd")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/hud115.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time115.gd")
func _ready() -> void:
 super._ready()
 while not woodland_ready114: await get_tree().physics_frame
 woodland_ready115=true;_title35();time55.update_guide();print("WOODLAND115_READY")
func _refresh_aim114(cursor: Vector2) -> void:
 if auto114: super._refresh_aim114(cursor);return
 var tick := Engine.get_physics_frames()
 if tick==aim_tick114 and cursor==aim_cursor114 and (not is_instance_valid(target114) or not target114.dead): return
 aim_tick114=tick;aim_cursor114=cursor
 var origin := projectile_origin()
 var intersection: Variant=Plane(Vector3.UP,origin.y).intersects_ray(camera.project_ray_origin(cursor),camera.project_ray_normal(cursor))
 aim114=intersection if intersection!=null else origin+Vector3.FORWARD*6.
 # Direction is measured from the player, so the following goose cannot wobble selection.
 var screen_origin := camera.unproject_position(hero.global_position+Vector3.UP*.8)
 var direction := cursor-screen_origin;var previous := target114
 var small_motion := direction.length_squared()<pow(CURSOR_DEADZONE115*get_viewport().get_visible_rect().size.y/1000.,2.)
 target114=null;var best := INF
 for enemy in enemies:
  if not is_instance_valid(enemy) or enemy.dead or not _visible114(enemy,origin): continue
  var score: float
  if aim_model.sprite_contains(camera,cursor,enemy.visual):
   score=-2.+origin.distance_to(enemy.hit_area.global_position)*.001
  elif small_motion:
   if enemy!=previous: continue
   score=0.
  else:
   var toward: Vector2=camera.unproject_position(enemy.hit_area.global_position)-screen_origin
   var angle := absf(toward.angle_to(direction))
   if toward.dot(direction)<=0. or angle>(RETAIN_ANGLE115 if enemy==previous else ACQUIRE_ANGLE115): continue
   score=angle+origin.distance_to(enemy.hit_area.global_position)*.002-(SWITCH_MARGIN115 if enemy==previous else 0.)
  if score<best: best=score;target114=enemy
 if is_instance_valid(target114):
  var center: Vector3=target114.hit_area.global_position
  var lead: Vector3=target114.velocity*minf(.2,origin.distance_to(center)/Profile.BULLET_SPEED)
  lead.y=0.;aim114=center+lead.limit_length(.35)
func start_combat(reposition := true) -> void:
 super.start_combat(reposition)
 if woodland_ready114 and active114 and not auto114:
  encounter_hud.announce("方向辅助 · 手动射击","鼠标指大致方向 · 离开怪物仍保持目标 · 左键射击",2.4)
