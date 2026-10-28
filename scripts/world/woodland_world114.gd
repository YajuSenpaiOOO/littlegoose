extends "res://scripts/world/woodland_world113.gd"
const DURATION114 := 45.
var woodland_ready114 := false
var active114 := false
var auto114 := true
var elapsed114 := 0.
var refill114 := 0.
var packs114 := 0
var spawn_sites114: Array[Vector2]=[]
var spawn_max_us114 := 0
var target114: CharacterBody3D
var aim114 := Vector3.ZERO
var aim_tick114 := -1
var aim_cursor114 := Vector2.INF
var results114 := {}
var trial_ui114: Control
func _trial_ui_script114() -> Script: return preload("res://scripts/combat/trial_ui114.gd")
func _trial_duration114() -> float: return DURATION114
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 114 · 45秒战斗试验 / 瞄准对照")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time114.gd")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/hud114.gd")
func _ready() -> void:
 super._ready()
 while not woodland_ready113: await get_tree().physics_frame
 var layer := CanvasLayer.new();layer.layer=24;add_child(layer)
 trial_ui114=_trial_ui_script114().new();trial_ui114.battle=self;layer.add_child(trial_ui114)
 world_cursor=false;aim_guide_mode=2
 woodland_ready114=true;combat_paused=true;hero.controls_enabled=false;wave_state="waiting"
 _teleport15(meadow.landmarks.grove+Vector2(0,2.));crosshair.hide();time55.guide.hide();frames66.panel.hide();label.get_parent().hide()
 _bake_spawn_sites114();trial_ui114.show_menu(false);_title35();print("WOODLAND114_READY sites=",spawn_sites114.size())
func wave_count110() -> int: return 1
func count_for110(_index: int) -> int: return 3
func start_combat(reposition := true) -> void:
 if not woodland_ready114: return
 active114=true;elapsed114=0.;refill114=0.;packs114=0;target114=null;aim_tick114=-1
 slow_start113=true;trial_offset110=0;weapon_rng.seed=114001
 super.start_combat(reposition)
 fire_needs_release=not auto114 and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
 reward_offered=true;trial_ui114.menu.hide();crosshair.hide()
 encounter_hud.announce("自动瞄准" if auto114 else "方向瞄准＋轻辅助","45秒 · 同时三只 · "+("专心走位、闪避与弹反" if auto114 else "左键射击 · 金色标记表示辅助目标"),2.)
 _title35()
func begin114(automatic: bool) -> void:
 auto114=automatic;start_combat()
func _spawn_wave110(_index: int) -> void:
 var started := Time.get_ticks_usec()
 round_index=0;between_left=0.;last_attacker=null;_clear_combat_shots()
 for enemy in enemies:
  if is_instance_valid(enemy): remove_child(enemy);enemy.queue_free()
 enemies.clear();_prune_actor_shadows();packs114+=1
 var center: Vector2=meadow.landmarks.grove;var occupied: Array[Vector2]=[]
 for i in 3:
  var offset: Vector2=[Vector2(-4.,-2.),Vector2(3.5,-3.),Vector2(.7,-5.5)][i]
  var at := _pick_spawn114(center+offset,occupied);occupied.append(at)
  var enemy: CharacterBody3D=_enemy_script().new()
  enemy.battle=self;enemy.poses=combat_poses;enemy.textures=combat_textures;enemy.name="Trial114_%d_%d"%[packs114,i]
  enemy.rank110=0;enemy.body_scale110=1.;enemy.max_hp110=4.;enemy.hp=4.;enemy.touch110=15.;enemy.speed110=1.
  enemy.behaviors110=[];enemy.role110=i;enemy.home=center;enemy.rest=.55+i*.2;enemy.attack_wait110=1.1+i*.18
  enemy.position=Vector3(at.x,floor_height(at)+.06,at.y);add_child(enemy);enemy.reset_physics_interpolation();enemies.append(enemy);_add_actor_shadow(enemy,enemy.visual)
 next_attack33=combat_clock33+.9;rebuild_cells110();target114=null;aim_tick114=-1
 spawn_max_us114=maxi(spawn_max_us114,Time.get_ticks_usec()-started)
func _bake_spawn_sites114() -> void:
 spawn_sites114.clear();var g: Vector2=meadow.landmarks.grove;var center := g+Vector2(0,2.)
 var wanted: Array[Vector2]=[g+Vector2(-4.,-2.),g+Vector2(3.5,-3.),g+Vector2(.7,-5.5)]
 for radius in [5.,8.]:
  for i in 12: wanted.append(g+Vector2(cos(TAU*i/12.),sin(TAU*i/12.))*radius)
 var shape := CapsuleShape3D.new();shape.radius=.45;shape.height=.9
 var query := PhysicsShapeQueryParameters3D.new();query.shape=shape;query.collision_mask=1|2|16;query.exclude=[hero.get_rid()]
 for point in wanted:
  var at: Vector2=navigation.origin+Vector2(navigation.nearest(point))*navigation.CELL
  if at in spawn_sites114: continue
  var path: PackedVector2Array=navigation.path(at,center)
  if path.is_empty() or path[-1].distance_to(center)>1.1: continue
  query.transform=Transform3D(Basis.IDENTITY,Vector3(at.x,floor_height(at)+.57,at.y))
  if get_world_3d().direct_space_state.intersect_shape(query,1).is_empty(): spawn_sites114.append(at)
func _pick_spawn114(wanted: Vector2,occupied: Array[Vector2]) -> Vector2:
 var player := Vector2(hero.position.x,hero.position.z);var best := Vector2.INF;var score := INF
 for at in spawn_sites114:
  if at.distance_squared_to(player)<12.25: continue
  var available := true
  for other in occupied:
   if at.distance_squared_to(other)<2.25: available=false;break
  if available and at.distance_squared_to(wanted)<score: score=at.distance_squared_to(wanted);best=at
 if best.is_finite(): return best
 return _spawn_spot110(wanted,occupied,.35)
func enemy_defeated(enemy: CharacterBody3D) -> void:
 if not active114: return
 if steering_indices113.has(enemy): steering_alive113[int(steering_indices113[enemy])]=0
 defeated_count+=1;hitstop(.035);trauma=minf(1.,trauma+.18)
 if target114==enemy: target114=null;aim_tick114=-1
 var alive := false
 for other in enemies:
  if is_instance_valid(other) and not other.dead: alive=true
 if not alive: refill114=.9
func _open_draft() -> void: pass
func _spawn_next_round() -> void: pass
func _can_auto_leave_encounter() -> bool: return false
func fire_input_held() -> bool:
 if not active114 or combat_paused or not is_instance_valid(hero) or not hero.controls_enabled or hero.guarding109 or hero.knocked_down: return false
 if not auto114: return Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)
 _refresh_aim114(get_viewport().get_mouse_position());return is_instance_valid(target114) and not target114.dead
func aim_at_screen(point: Vector2) -> Vector3:
 if not woodland_ready114 or not active114: return super.aim_at_screen(point)
 _refresh_aim114(point);return aim114
func resolved_fire_target(target: Vector3,_origin: Vector3) -> Vector3: return target
func _visible114(enemy: CharacterBody3D,origin: Vector3) -> bool:
 var point: Vector3=enemy.hit_area.global_position
 if origin.distance_squared_to(point)>100. or not camera.is_position_in_frustum(point): return false
 var query := PhysicsRayQueryParameters3D.create(origin,point,1|2,[hero.get_rid()])
 return get_world_3d().direct_space_state.intersect_ray(query).is_empty()
func _refresh_aim114(cursor: Vector2) -> void:
 var tick := Engine.get_physics_frames()
 if tick==aim_tick114 and (auto114 or cursor==aim_cursor114) and (not is_instance_valid(target114) or not target114.dead): return
 aim_tick114=tick;aim_cursor114=cursor
 var origin := projectile_origin();var ray_origin := camera.project_ray_origin(cursor);var ray := camera.project_ray_normal(cursor)
 var plane_hit: Variant=Plane(Vector3.UP,origin.y).intersects_ray(ray_origin,ray)
 aim114=plane_hit if plane_hit!=null else origin+Vector3.FORWARD*6.
 var screen_origin := camera.unproject_position(origin);var wanted := cursor-screen_origin;var previous := target114
 target114=null;var best := INF
 for enemy in enemies:
  if not is_instance_valid(enemy) or enemy.dead or not _visible114(enemy,origin): continue
  var score: float
  if auto114:
   score=origin.distance_squared_to(enemy.hit_area.global_position)*(.78 if enemy==previous else 1.)
  else:
   if aim_model.sprite_contains(camera,cursor,enemy.visual):
    score=-1.+origin.distance_to(enemy.hit_area.global_position)*.003
   else:
    var toward: Vector2=camera.unproject_position(enemy.hit_area.global_position)-screen_origin
    if wanted.length_squared()<144. or toward.dot(wanted)<=0.: continue
    var angle := absf(toward.angle_to(wanted));var lateral := absf(toward.cross(wanted.normalized()))
    if angle>.22 or lateral>58.*get_viewport().get_visible_rect().size.y/1000.: continue
    score=angle+origin.distance_to(enemy.hit_area.global_position)*.003
  if score<best: best=score;target114=enemy
 if is_instance_valid(target114):
  var center: Vector3=target114.hit_area.global_position
  var lead: Vector3=target114.velocity*minf(.2,origin.distance_to(center)/Profile.BULLET_SPEED);lead.y=0.;lead=lead.limit_length(.35)
  aim114=center+lead
func finish114() -> void:
 if not active114: return
 active114=false;results114["B" if auto114 else "A"]={"kills":defeated_count,"hits":landed_hits,"shots":fired_count,"hurt":hurt_count,"parries":parry_count,"seconds":elapsed114}
 combat_paused=true;wave_state="waiting";result_open=false;result_dismissed=true;result_at=-1.;reward_offered=true
 _clear_combat_shots();hero.cancel_guard109();hero.controls_enabled=false;hero.locomotion=Vector2.ZERO;hero.combat_impulse=Vector2.ZERO;hero.velocity=Vector3.ZERO
 Engine.time_scale=1.;stop_until=0.;trial_ui114.show_menu(true)
func _physics_process(delta: float) -> void:
 super._physics_process(delta)
 if not woodland_ready114 or not active114: return
 if player_hp<=0.: finish114();return
 if combat_paused: return
 elapsed114+=delta
 if elapsed114>=_trial_duration114(): finish114();return
 if refill114>0.:
  refill114=maxf(0.,refill114-delta)
  if refill114<=0.: _spawn_wave110(0)
func _process(delta: float) -> void:
 if woodland_ready114 and active114 and player_hp<=0.: finish114()
 super._process(delta)
func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and woodland_ready114:
  if event.physical_keycode==KEY_F2: begin114(not auto114);return
  if event.physical_keycode in [KEY_F5,KEY_F8]: start_combat();return
  if event.physical_keycode==KEY_ESCAPE:
   if active114: finish114()
   return
  if event.physical_keycode==KEY_F7 and not active114: return
  if event.physical_keycode==KEY_F11: return
 super._unhandled_input(event)
