extends "res://scripts/world/woodland_world112.gd"
var woodland_ready113 := false
var gpu_shadows113 := true
var shadow_field113=preload("res://scripts/combat/shadow_field113.gd").new()
var steering_tick113 := -1
var steering_nodes113: Array[CharacterBody3D]=[]
var steering_positions113 := PackedVector3Array()
var steering_rids113: Array[RID]=[]
var steering_alive113 := PackedByteArray()
var steering_indices113 := {}
var steering_level113 := 0
var simple_trace113 := false
var hero_exclude113: Array[RID]=[]
var fast_floor113 := true
var slow_start113 := true
const START_INTERVAL113 := .34
var use_native113 := true
var native_library113: Resource
var native_helper113: RefCounted
func _actor_shadow_script105() -> Script: return preload("res://scripts/combat/actor_shadow113.gd")
func _encounter_hud_script37() -> Script: return preload("res://scripts/combat/hud113.gd")
func _material_fx_script() -> Script: return preload("res://scripts/combat/material_fx113.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time113.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 113 · 战斗更新优化")
func _ready() -> void:
 super._ready()
 while not woodland_ready112: await get_tree().physics_frame
 shadow_field113.rebuild(self)
 if OS.has_feature("windows") and OS.has_feature("x86_64"):
  native_library113=load("res://native/combat113/combat113.gdextension")
  if ClassDB.class_exists("NativeCombat113"): native_helper113=ClassDB.instantiate("NativeCombat113")
 woodland_ready113=true;_title35();print("WOODLAND113_READY native=",native_helper113!=null)
 time55.update_guide()
func attack_cooldown() -> float:
 return super.attack_cooldown()*(START_INTERVAL113/Profile.FIRE_CD if slow_start113 else 1.)
func damage_for_shot(shot: Dictionary) -> float:
 var damage := super.damage_for_shot(shot)
 # Independent charge/beam timings keep their old DPS advantage over basic fire.
 if slow_start113 and (shot.get("charged",false) or shot.get("stream110",false)): damage*=Profile.FIRE_CD/START_INTERVAL113
 return damage
func _spawn_wave110(index: int) -> void:
 super._spawn_wave110(index)
 if not slow_start113: return
 var prefix := "Act%d_"%(index+1)
 for enemy in enemies:
  if not is_instance_valid(enemy) or enemy.dead or not String(enemy.name).begins_with(prefix): continue
  var factor := 1./3. if enemy.rank110==0 else Profile.FIRE_CD/START_INTERVAL113
  enemy.max_hp110*=factor;enemy.hp=enemy.max_hp110
func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.ctrl_pressed and event.alt_pressed and event.physical_keycode==KEY_F11:
  slow_start113=not slow_start113;start_combat();time55.update_guide();return
 super._unhandled_input(event)
func _cache_floor() -> void:
 super._cache_floor()
 if woodland_ready113: shadow_field113.rebuild(self)
func floor_height(at: Vector2) -> float:
 if not fast_floor113 or not woodland_ready113 or not combat_budget105: return super.floor_height(at)
 if floor_recent105.has(at): floor_hits105+=1;return floor_recent105[at]
 if floor_previous105.has(at): floor_hits105+=1;return floor_previous105[at]
 var field: RefCounted=shadow_field113;var key := Vector2i(((at-field.origin)/16.).floor());var height: float
 if field.bridge.has_point(at):
  height=lerpf(lerpf(field.bridge_ends.x,.24,smoothstep(0.,1.3,at.x-field.bridge.position.x)),field.bridge_ends.y,smoothstep(0.,1.3,at.x-field.bridge.end.x+1.3))
 elif floor_tiles.has(key):
  var tile: Dictionary=floor_tiles[key];var w: int=tile.width;var uv: Vector2=(at-tile.rect.position)/tile.rect.size*(w-1)
  var x := clampi(floori(uv.x),0,w-2);var y := clampi(floori(uv.y),0,w-2);var f := uv-Vector2(x,y);var a := y*w+x;var p: PackedVector3Array=tile.vertices
  height=p[a].y+(p[a+1].y-p[a].y)*f.x+(p[a+w+1].y-p[a+1].y)*f.y if f.x>=f.y else p[a].y+(p[a+w+1].y-p[a+w].y)*f.x+(p[a+w].y-p[a].y)*f.y
 else: return super.floor_height(at)
 height=field.support(at,height);floor_misses105+=1
 if floor_recent105.size()>=8192: floor_previous105=floor_recent105;floor_recent105={}
 floor_recent105[at]=height;return height
func _steering_snapshot113() -> void:
 steering_tick113=Engine.get_physics_frames();steering_level113=buffs.level("eye_exercise")
 steering_nodes113.clear();steering_positions113.clear();steering_rids113.clear();steering_alive113.clear();steering_indices113.clear()
 for enemy in enemies:
  if not is_instance_valid(enemy) or enemy.dead: continue
  steering_indices113[enemy]=steering_nodes113.size();steering_nodes113.append(enemy);steering_positions113.append(enemy.position);steering_rids113.append(enemy.hit_area.get_rid());steering_alive113.append(1)
func enemy_defeated(enemy: CharacterBody3D) -> void:
 if steering_indices113.has(enemy): steering_alive113[int(steering_indices113[enemy])]=0
 super.enemy_defeated(enemy)
func _step_shots(delta: float) -> void:
 if use_native113 and is_instance_valid(native_helper113):
  native_helper113.step(self,delta,Profile.PPM);_flush_splits113();return
 if buffs.level("eye_exercise")>0: _steering_snapshot113()
 super._step_shots(delta)
func _flush_splits113() -> void:
 var pending := pending_splits110.duplicate();pending_splits110.clear()
 for split in pending:
  var count := 6 if int(split.depth)==1 else 4
  var velocity: Vector3=split.get("velocity111",Vector3.RIGHT*Profile.BULLET_SPEED)
  var forward := Vector3(velocity.x,0,velocity.z).normalized()
  if forward.length_squared()<.001: forward=Vector3.RIGHT
  for i in count:
   var direction := forward.rotated(Vector3.UP,TAU*float(i)/float(count))
   var shot: Dictionary=data_shot110(split.at+direction*14./Profile.PPM,direction*velocity.length(),float(split.get("life111",.35)))
   shot.split_depth110=split.depth;shot.fixed_damage110=split.damage;shot.spawn_grace111=.06;shot.piercing110=bool(split.get("piercing111",false))
   if has_method("inherit_split153"): call("inherit_split153",shot,split)
func _steer_shot(shot: Dictionary,delta: float) -> void:
 var age: float=float(shot.get("steer_age111",0.))+delta
 if age<1./30.-.00001: shot.steer_age111=age;return
 shot.steer_age111=0.;delta=age
 if steering_tick113!=Engine.get_physics_frames(): _steering_snapshot113()
 var at: Vector3=shot.node.at;var forward := Vector2(shot.velocity.x,shot.velocity.z);var speed2 := forward.length_squared()
 if speed2<.0001: return
 var target: Variant=shot.get("target110");var chosen: int=steering_indices113.get(target,-1) if is_instance_valid(target) else -1
 if chosen>=0 and steering_alive113[chosen]==0: chosen=-1
 if chosen<0 and is_instance_valid(target): shot.target_until110=0.
 if chosen<0 and combat_clock33<float(shot.get("target_until110",0.)): return
 if combat_clock33>=float(shot.get("target_until110",0.)):
  chosen=-1;var closest := pow(240./Profile.PPM,2.);var cone := cos(1.4 if steering_level113==1 else 1.9);var speed := sqrt(speed2)
  for i in steering_positions113.size():
   if steering_alive113[i]==0: continue
   var rid: RID=steering_rids113[i]
   if (not shot.hit_rids.is_empty() and rid in shot.hit_rids) or (not shot.ignore_rids110.is_empty() and rid in shot.ignore_rids110): continue
   var position: Vector3=steering_positions113[i];var toward := Vector2(position.x-at.x,position.z-at.z);var distance := toward.length_squared()
   if distance<closest and forward.dot(toward)>cone*speed*sqrt(distance): chosen=i;closest=distance
  shot.target110=steering_nodes113[chosen] if chosen>=0 else null;shot.target_until110=combat_clock33+.08
 if chosen<0: return
 var desired := (steering_positions113[chosen]+Vector3.UP*.65-at).normalized();var rate := 2.5 if steering_level113==1 else 4.
 var turn := clampf(forward.angle_to(Vector2(desired.x,desired.z)),-rate*delta,rate*delta)
 var flat := forward.normalized().rotated(turn);var speed: float=shot.velocity.length()
 var vy: float=lerpf(shot.velocity.y,desired.y*speed,minf(1.,rate*delta));var horizontal := sqrt(maxf(0.,speed*speed-vy*vy))
 shot.velocity=Vector3(flat.x*horizontal,vy,flat.y*horizontal)
func _trace_shot(shot: Dictionary,start: Vector3,end: Vector3) -> Dictionary:
 if not start.is_finite() or not end.is_finite(): shot.life=0.;return {}
 if use_grid111 or shot.get("piercing110",false) or shot.get("charged",false) or not shot.ignore_rids110.is_empty() or float(shot.get("spawn_grace111",0.))>0.:
  simple_trace113=false;return super._trace_shot(shot,start,end)
 if not simple_trace113:
  hero_exclude113.assign([hero.get_rid()]);query110.exclude=hero_exclude113;simple_trace113=true
 query110.from=start;query110.to=end
 return space110.intersect_ray(query110)
