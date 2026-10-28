extends "res://scripts/world/woodland_world110.gd"
var woodland_ready111 := false
# Extra GDScript broad-phase work did not beat Jolt consistently in stress tests.
var use_grid111 := false
var start_pending111 := false
var reposition_pending111 := true
var grid111=preload("res://scripts/combat/projectile_grid111.gd").new()
var combat_tint111: CanvasModulate
var next_shadows111 := 0
func _skills_script110() -> Script: return preload("res://scripts/combat/battle_skills111.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 111 · 稳定光束 / 昼夜弹幕 / 重开清卡")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time111.gd")
func _ready() -> void:
 super._ready()
 while not woodland_ready110: await get_tree().physics_frame
 grid111.setup(self);combat_tint111=CanvasModulate.new();combat_tint111.name="CombatDayNight111";fx_layer.add_child(combat_tint111)
 get_tree().node_added.connect(_added111)
 woodland_ready111=true;_grade_combat111();_title35();time55.update_guide();print("WOODLAND111_READY")
 if start_pending111:
  start_pending111=false;call_deferred("start_combat",reposition_pending111)
func start_combat(reposition := true) -> void:
 if not woodland_ready111:
  start_pending111=true;reposition_pending111=reposition;return
 buffs.levels.clear()
 if woodland_ready111: grid111.invalidate()
 super.start_combat(reposition)
func _step_shots(delta: float) -> void:
 if woodland_ready111 and use_grid111: grid111.rebuild()
 var tracking: bool=buffs.level("eye_exercise")>0
 for i in range(shots.size()-1,-1,-1):
  var shot: Dictionary=shots[i];var state: Pool110.BulletState=shot.node
  var grace: float=shot.get("spawn_grace111",0.)
  if grace>0.:
   shot.spawn_grace111=maxf(0.,grace-delta);state.previous=state.at;state.at+=Vector3(shot.velocity)*delta;shot.life-=delta
   if shot.life<=0.: pool110.retire(shot);shots.remove_at(i)
   continue
  if tracking: _steer_shot(shot,delta)
  var start: Vector3=state.at;var velocity: Vector3=shot.velocity;var end := start+velocity*delta
  var hit := _trace_shot(shot,start,end);shot.life-=delta
  if not shot.get("stream110",false) and int(shot.get("split_depth110",0))==0:
   shot.trail_distance+=start.distance_to(end)
   if shot.trail_distance>=4.5/Profile.PPM:
    emit_trail(end,velocity.normalized());shot.trail_distance=fmod(shot.trail_distance,4.5/Profile.PPM)
  if not hit.is_empty(): _apply_shot_hit(shot,hit)
  elif shot.life<=0.: _shot_expired(shot)
  if not hit.is_empty() or shot.life<=0.: pool110.retire(shot);shots.remove_at(i)
  else: state.previous=start;state.at=end
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
func _apply_shot_hit(shot: Dictionary,hit: Dictionary) -> void:
 var before := pending_splits110.size()
 super._apply_shot_hit(shot,hit)
 if pending_splits110.size()>before:
  var split: Dictionary=pending_splits110[-1]
  split.velocity111=shot.velocity;split.life111=maxf(.35,float(shot.life)*.5);split.piercing111=shot.get("charged",false) or shot.get("piercing110",false)
func _trace_shot(shot: Dictionary,start: Vector3,end: Vector3) -> Dictionary:
 if not start.is_finite() or not end.is_finite(): shot.life=0.;return {}
 if woodland_ready111 and use_grid111 and not grid111.might_hit(start,end,shot): return {}
 if float(shot.get("spawn_grace111",0.))>0.:
  var mask: int=query110.collision_mask;query110.collision_mask=1|2
  var result := super._trace_shot(shot,start,end);query110.collision_mask=mask;return result
 return super._trace_shot(shot,start,end)
func _process(delta: float) -> void:
 super._process(delta)
 if woodland_ready111: _grade_combat111()
func _grade_combat111() -> void:
 var look: Dictionary=time55.palette.sample(time55.visual_hour)
 var focus: ShaderMaterial=atmosphere41.focus_material
 var high: Vector3=focus.get_shader_parameter("tone_highlights");var low: Vector3=focus.get_shader_parameter("tone_shadows")
 var exposure: float=focus.get_shader_parameter("day_exposure55");var daylight: float=look.daylight
 var rgb := low.lerp(high,.7)*exposure*lerpf(.62,1.,daylight)
 combat_tint111.color=Color(clampf(rgb.x,.28,1.08),clampf(rgb.y,.28,1.08),clampf(rgb.z,.28,1.08),1.)
func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_F5 and not event.ctrl_pressed and not event.alt_pressed:
  start_combat();return
 if woodland_ready111 and event is InputEventKey and event.pressed and (event.ctrl_pressed or event.alt_pressed): grid111.invalidate()
 super._unhandled_input(event)
func _added111(node: Node) -> void:
 if not woodland_ready111: return
 if node is StaticBody3D: grid111.invalidate()
 if (node is AnimatableBody3D or node is RigidBody3D) and (node.collision_layer & 3)!=0: grid111.dynamic_bodies.append(node)
func emit_stream110(target: Vector3) -> void:
 if target.is_finite(): super.emit_stream110(target)
func _release_charged(target: Vector3,ratio: float) -> void:
 if target.is_finite(): super._release_charged(target,ratio)
func screen_direction(at: Vector3,direction: Vector3) -> Vector2:
 if not at.is_finite() or not direction.is_finite() or direction.length_squared()<.000001: return Vector2.RIGHT
 return super.screen_direction(at,direction)
func _steer_shot(shot: Dictionary,delta: float) -> void:
 var age: float=float(shot.get("steer_age111",0.))+delta
 if age<1./30.-.00001: shot.steer_age111=age;return
 shot.steer_age111=0.;super._steer_shot(shot,age)
func _rebuild_terrain() -> void:
 super._rebuild_terrain()
 if woodland_ready111: grid111.bake_terrain()
func fire_at(target: Vector3) -> void:
 if target.is_finite(): super.fire_at(target)
func _draw_projectile_shadows105() -> void:
 if not woodland_ready111: super._draw_projectile_shadows105();return
 var now := Time.get_ticks_msec()
 if now<next_shadows111: return
 next_shadows111=now+33
 var count := 0;var direction: Vector3=-sun.global_basis.z.normalized()
 for shot in shots:
  if count>=24: break
  if shot.get("stream110",false) or int(shot.get("split_depth110",0))>0: continue
  var at: Vector3=shot.node.position
  if not camera.is_position_in_frustum(at): continue
  var projected := at
  for i in 2: projected=at+direction*((floor_height(Vector2(projected.x,projected.z))-at.y)/direction.y)
  var point := Vector2(projected.x,projected.z);var height := floor_height(point)
  var normal := Vector3(-(floor_height(point+Vector2(.1,0))-height)/.1,1.,-(floor_height(point+Vector2(0,.1))-height)/.1).normalized()
  var right := Vector3.FORWARD.cross(normal).normalized();var forward := right.cross(normal)
  var gain: float=shot.art.scale_gain if shot.has("art") else 1.
  shadow_batch110.multimesh.set_instance_transform(count,Transform3D(Basis(right,normal,forward).scaled(Vector3(gain,1.,gain)),Vector3(projected.x,height+.033,projected.z)))
  shadow_batch110.multimesh.set_instance_color(count,Color(1,1,1,clampf(.50-(at.y-height)*.07,.23,.5)));count+=1
 shadow_batch110.multimesh.visible_instance_count=count;shadow_count110=count
