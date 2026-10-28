extends "res://scripts/world/woodland_world146.gd"
var queued149 := Vector3.INF
var air_frame149 := 0.
var air_lift149 := 0.
func _paper_manager_script146() -> Script: return preload("res://scripts/combat/paper_bomb149.gd")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/paper_hud149.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 149 · 地面标记 / 高空三投")
func _ready() -> void:
 super._ready()
 while not hill_ready146: await get_tree().physics_frame
 if "--bomb149" in OS.get_cmdline_user_args(): paper_trial129=true;start_combat()
func ground_aim149(screen: Vector2) -> Vector3:
 var origin := camera.project_ray_origin(screen);var direction := camera.project_ray_normal(screen)
 var query := PhysicsRayQueryParameters3D.create(origin,origin+direction*300.,1,[hero.get_rid()])
 var hit := get_world_3d().direct_space_state.intersect_ray(query)
 var at: Vector3
 if not hit.is_empty(): at=hit.position
 else:
  var point: Variant=Plane(Vector3.UP,hero.position.y).intersects_ray(origin,direction)
  at=point if point!=null else hero.position+Vector3.FORWARD*6.
 var offset := Vector2(at.x-hero.position.x,at.z-hero.position.z).limit_length(12.)
 at=Vector3(hero.position.x+offset.x,0,hero.position.z+offset.y)
 at.y=floor_height(Vector2(at.x,at.z))+.05
 return at
func aim_at_screen(point: Vector2) -> Vector3:
 if hill_ready146 and buffs.level("paper_plane")>0: return ground_aim149(point)
 return super.aim_at_screen(point)
func paper_aim146() -> Vector3: return ground_aim149(get_viewport().get_mouse_position()) if buffs.level("paper_plane")>0 else super.paper_aim146()
func attack_cooldown() -> float:
 if buffs.level("paper_plane")>0: return maxf(.05,(preload("res://scripts/combat/paper_bomb149.gd").AIRTIME149/3.)/buffs.rate()*(2. if buffs.level("three_player")>0 else 1.))
 return super.attack_cooldown()
func _update_camera(delta: float,snap := false) -> void:
 if is_instance_valid(camera): camera.position.y-=air_lift149
 var wanted := 1. if active114 and buffs.level("paper_plane")>0 else 0.
 air_frame149=wanted if snap else move_toward(air_frame149,wanted,delta*1.8)
 var saved := camera_distance;camera_distance*=1.+.14*air_frame149
 super._update_camera(delta,snap);camera_distance=saved
 if is_instance_valid(camera): air_lift149=1.1*air_frame149;camera.position.y+=air_lift149
func _clear_combat_shots() -> void:
 queued149=Vector3.INF;super._clear_combat_shots()
func _step_fire_input(delta: float) -> void:
 if buffs.level("paper_plane")==0 or buffs.level("slingshot")>0: super._step_fire_input(delta);return
 if not is_instance_valid(paper_memories146): return
 var held := fire_input_held()
 if not held: fire_needs_release=false
 if paper_memories146.writing146: queued149=Vector3.INF;paper_memories146.pending_mark149=Vector3.INF;return
 if not active114 or combat_paused or result_open or player_hp<=0. or wave_state!="fighting" or between_left>0. or fire_needs_release or not hero.controls_enabled or hero.dash_left>0. or hero.guarding109 or hero.knocked_down: return
 if cooldown<=0. and (held or queued149.is_finite()):
  fire_at(queued149 if queued149.is_finite() else paper_aim146());queued149=Vector3.INF;cooldown=attack_cooldown()
func _input(event: InputEvent) -> void:
 if event is InputEventMouseButton and event.button_index==MOUSE_BUTTON_LEFT and event.pressed and hill_ready146 and active114 and not combat_paused and not result_open and buffs.level("paper_plane")>0 and buffs.level("slingshot")==0 and not paper_memories146.writing146 and hero.controls_enabled and (not is_instance_valid(memory_ui116) or not memory_ui116.visible):
  queued149=ground_aim149(event.position);paper_memories146.pending_mark149=queued149
 super._input(event)
func bomb_impact149(packet: Dictionary,mark: Vector3,gain: float) -> void:
 var damage := 0.;var snack := 0;var charged := false;var note := false
 for spec in packet.specs:
  damage+=float(spec.damage);snack=maxi(snack,int(spec.snack));charged=charged or bool(spec.charged);note=note or bool(spec.note110)
 if packet.stream: damage*=maxf(1.,float(packet.burst_time)/float(packet.pulse_interval))
 var targets := enemies.duplicate()
 for enemy in targets:
  if not is_instance_valid(enemy) or enemy.dead or not enemy.is_visible_in_tree(): continue
  var centre: Vector3=enemy.hit_area.global_position
  if Vector2(centre.x-mark.x,centre.z-mark.z).length()>1.4 or absf(centre.y-mark.y)>3.5: continue
  var query := PhysicsRayQueryParameters3D.create(mark+Vector3.UP*.2,centre,1|2,[hero.get_rid()])
  if not get_world_3d().direct_space_state.intersect_ray(query).is_empty(): continue
  var direction := Vector3(centre.x-mark.x,.25,centre.z-mark.z).normalized()
  var shot := {"packet146":true,"fixed_damage110":damage*gain,"velocity":direction*6.,"life":.5,"damage_multiplier":1.,"charged":charged,"piercing110":charged,"note110":note,"stream110":bool(packet.stream),"snack146":snack,"tracking146":0,"split_depth110":0}
  _apply_shot_hit(shot,{"collider":enemy.hit_area,"position":centre,"normal":Vector3.UP})
func _flush_splits113() -> void:
 var room := maxi(0,(512-shots.size())/6)
 if pending_splits110.size()>room: pending_splits110.resize(room)
 super._flush_splits113()
func start_combat(reposition := true) -> void:
 super.start_combat(reposition)
 if hill_ready146 and paper_trial129: encounter_hud.announce("地面标记 · 高空三投","左键标记／按住连续呼叫 · 初始约3架在空，无三架上限 · 1—6换组合 · Q笔记",3.)
