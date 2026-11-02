extends "res://scripts/world/woodland_world109.gd"
const Pool110=preload("res://scripts/combat/projectile_pool110.gd")
const DATA110=preload("res://scripts/combat/encounter_data110.gd")
var woodland_ready110 := false
var trial_offset110 := 0
var cells110 := {}
var scan110 := 0.
var query110 := PhysicsRayQueryParameters3D.new()
var space110: PhysicsDirectSpaceState3D
var contact_frame110 := -1
var contacts110 := 0
var surface_frame110 := -1
func reserve_feedback110() -> bool:
 var frame := Engine.get_process_frames()
 if frame!=contact_frame110: contact_frame110=frame;contacts110=0
 if contacts110>=2: return false
 contacts110+=1;return true
func data_shot110(origin: Vector3,velocity: Vector3,life: float) -> Dictionary:
 var state=pool110.take_node();state.position=origin;state.reset_physics_interpolation()
 var shot: Dictionary=_projectile_record110(state,velocity)
 shot.life=life;shot.shadow=state.shadow;shot.trail_distance=0.;shot.art=pool110.take_art(self);shot.art.follow=state
 shots.append(shot);fired_count+=1;return shot

var pool110=preload("res://scripts/combat/projectile_pool110.gd").new()
var skills110: Node2D
var shot_origin110 := Vector3.INF
var emitter110: Node3D
var contact_emitter110: Node3D
var shadow_batch110: MultiMeshInstance3D
var shadow_count110 := 0
var splitting110 := false
var pending_splits110: Array[Dictionary]=[]
var beam_left110 := 0.
var beam_power110 := 1.
var stream_emitting110 := false
var fragment_emitting110 := false
var stream_generation110 := 0
var stream_sequence110 := 0
var stream_last110 := -10.
func _init() -> void:
 buffs=preload("res://scripts/combat/buff_book110.gd").new();buffs.rng110.randomize()
func _hero_script() -> Script: return preload("res://scripts/combat/hero110.gd")
func _enemy_script() -> Script: return preload("res://scripts/combat/tuantuan110.gd")
func _time_script() -> Script: return preload("res://scripts/world/woodland_time110.gd")
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 110 · 团团怪完整战斗演练 / 按住蹲防")
func _skills_script110() -> Script: return preload("res://scripts/combat/battle_skills110.gd")
func _ready() -> void:
 super._ready()
 while not woodland_ready109: await get_tree().physics_frame
 skills110=_skills_script110().new();skills110.battle=self;fx_layer.add_child(skills110)
 projectile_canvas105.set_process(false);projectile_canvas105.hide();_build_shadow_batch110()
 space110=get_world_3d().direct_space_state;query110.collision_mask=1|2|8;query110.collide_with_areas=true;query110.hit_from_inside=true
 woodland_ready110=true;_apply_owned_buffs();_title35();time55.update_guide();print("WOODLAND110_READY childhood_cards=14 acts=13 rounds=6")
func wave_count110() -> int: return 6
func wave_config110(index: int) -> Dictionary: return DATA110.ACT_TABLE[mini(trial_offset110+index,12)]
func count_for110(index: int) -> int:
 var c := wave_config110(index)
 return (maxi(4,int(c.count)-3)+1 if index==5 else int(c.count))+int(c.elite)
func spawn_offsets() -> Array: return [] # The 3-wave prototype spawner is replaced below.
func start_combat(reposition := true) -> void:
 super.start_combat(reposition)
 total_enemies=0
 for i in wave_count110(): total_enemies+=count_for110(i)
 _spawn_wave110(0)
func _spawn_next_round() -> void:
 if wave_state!="fighting" or player_hp<=0.: return
 _spawn_wave110(round_index+1)
func _spawn_wave110(index: int) -> void:
 round_index=index;between_left=0.;last_attacker=null;_clear_combat_shots();_prune_actor_shadows()
 for previous in enemies:
  if is_instance_valid(previous) and previous.dead: previous.hit_area.collision_layer=0
 if is_instance_valid(skills110): skills110.reset110()
 var config := wave_config110(index);var normal := maxi(4,int(config.count)-3) if index==5 else int(config.count)
 var occupied: Array[Vector2]=[];var g: Vector2=meadow.landmarks.grove
 for i in normal+int(config.elite)+(1 if index==5 else 0):
  var rank := 0 if i<normal else (1 if i<normal+int(config.elite) else 2)
  var size: float=float(config.scale)*(1. if rank==0 else (1.7 if rank==1 else 2.6))
  var a := TAU*float(i)/float(normal+int(config.elite)+1)+.35
  var wanted := g+Vector2(cos(a)*7.7,sin(a)*5.8-1.)
  var at := _spawn_spot110(wanted,occupied,.35*size)
  var enemy: CharacterBody3D=_enemy_script().new();enemy.battle=self;enemy.poses=combat_poses;enemy.textures=combat_textures
  enemy.name="Act%d_%d_Rank%d"%[index+1,i,rank];enemy.rank110=rank;enemy.body_scale110=size
  enemy.max_hp110=float(config.get("boss_hp",float(config.hp)*8.)) if rank==2 else float(config.hp)*(2.5 if rank==1 else 1.)
  enemy.hp=enemy.max_hp110;enemy.touch110=float(config.touch)*10.;enemy.speed110=float(config.spd)*(.55 if rank==2 else (.9 if rank==1 else 1.))
  enemy.behaviors110=config.behaviors;enemy.role110=i;enemy.home=g;enemy.rest=.55+i*.12;enemy.attack_wait110=1.1+i*.18
  enemy.position=Vector3(at.x,floor_height(at)+.06,at.y);add_child(enemy);enemy.reset_physics_interpolation();enemies.append(enemy);_add_actor_shadow(enemy,enemy.visual)
  occupied.append(at)
 next_attack33=combat_clock33+.8;rebuild_cells110()
 if is_instance_valid(encounter_hud): encounter_hud.announce("团团大王登场" if index==5 else "第 %d 幕"%(index+1),"清完本幕选一张记忆 · 演练档 %d"%(trial_offset110+1),1.8)
func _spawn_spot110(wanted: Vector2,occupied: Array[Vector2],radius: float) -> Vector2:
 var shape := CapsuleShape3D.new();shape.radius=radius;shape.height=maxf(radius*2.,radius/.35*.8)
 for i in 20:
  var at := _safe_spawn(wanted+Vector2(sin(i*2.4),cos(i*2.4))*float(i)*.4,occupied)
  var q := PhysicsShapeQueryParameters3D.new();q.shape=shape;q.collision_mask=1|2|16
  q.transform=Transform3D(Basis.IDENTITY,Vector3(at.x,floor_height(at)+shape.height*.5+.12,at.y))
  if get_world_3d().direct_space_state.intersect_shape(q,1).is_empty(): return at
 return _safe_spawn(wanted,occupied)
func reserve_attack(enemy: CharacterBody3D) -> bool:
 if combat_paused or wave_state!="fighting" or between_left>0. or combat_clock33<next_attack33: return false
 var busy := 0
 for other in enemies:
  if is_instance_valid(other) and other!=enemy and not other.dead and other.attack_phase in ["windup","lunge"]: busy+=1
 if busy>=(1 if round_index<2 else 2): return false
 last_attacker=weakref(enemy);next_attack33=combat_clock33+maxf(.40,1.-round_index*.11);return true
func draft_message() -> String:
 return "第 %d / %d 幕清完 · 选择一张，%s"%[round_index+1,wave_count110(),"继续下一幕" if wave_reward_pending else "带回这场回忆"]
func _open_draft() -> void:
 draft_choices.shuffle()
 if draft_choices.size()>3: draft_choices=draft_choices.slice(0,3)
 super._open_draft()
func _continue_after_buff(card: Dictionary) -> void:
 if wave_reward_pending: super._continue_after_buff(card);return
 result_open=true;result_dismissed=false;result_at=-1.;hero.controls_enabled=false;draft_ui.close();encounter_hud.show_result()
 encounter_hud.announce(str(card.name),"大王战完成 · 可以继续探索或F5重试",2.)
func enemy_defeated(enemy: CharacterBody3D) -> void:
 super.enemy_defeated(enemy)
 if wave_state=="cleared" and is_instance_valid(skills110): skills110.reset110()
func rebuild_cells110() -> void:
 cells110.clear()
 for enemy in enemies:
  if not is_instance_valid(enemy) or enemy.dead: continue
  var key := Vector2i(floori(enemy.position.x/3.),floori(enemy.position.z/3.))
  if not cells110.has(key): cells110[key]=[]
  cells110[key].append(enemy)
func near_enemies110(at: Vector2,radius: float) -> Array:
 var found := [];var key := Vector2i(floori(at.x/3.),floori(at.y/3.));var n := ceili(radius/3.)+1
 for y in range(-n,n+1):
  for x in range(-n,n+1):
   for enemy in cells110.get(key+Vector2i(x,y),[]):
    if is_instance_valid(enemy) and not enemy.dead and Vector2(enemy.position.x,enemy.position.z).distance_squared_to(at)<=radius*radius: found.append(enemy)
 return found
func line_clear110(a: Vector2,b: Vector2) -> bool:
 var q := PhysicsRayQueryParameters3D.create(Vector3(a.x,floor_height(a)+.6,a.y),Vector3(b.x,floor_height(b)+.6,b.y),1|2)
 return get_world_3d().direct_space_state.intersect_ray(q).is_empty()
func rank_land110(enemy: CharacterBody3D) -> void:
 trauma=minf(1.,trauma+(.40 if enemy.rank110==2 else .18));Audio.play("crack",.75)
 if is_instance_valid(jelly_fx): jelly_fx.burst(enemy.position+Vector3.UP*.1,Vector3.UP,false)
 if enemy.rank110==2:
  if is_instance_valid(skills110): skills110.wave110(enemy)
 elif enemy.position.distance_to(hero.position)<2.88:
  if hero.can_parry(): enemy.deflect(hero.position+Vector3.UP*.65)
  else: hurt_player(enemy.touch110*1.5,Vector2(enemy.position.x,enemy.position.z))
func _physics_process(delta: float) -> void:
 super._physics_process(delta)
 if not combat_ready or combat_paused: return
 scan110-=delta
 if scan110<=0.: scan110=.10;rebuild_cells110()
 if is_instance_valid(skills110): skills110.step110(delta)
func _apply_owned_buffs() -> void:
 super._apply_owned_buffs()
 if is_instance_valid(skills110): skills110.sync_geese110()
func projectile_origin() -> Vector3:
 return shot_origin110 if shot_origin110.is_finite() else super.projectile_origin()
func attack_cooldown() -> float:
 return super.attack_cooldown()*(.5 if buffs.level("three_player")>0 else 1.)**-1
func damage_for_shot(shot: Dictionary) -> float:
 if shot.has("fixed_damage110"): return float(shot.fixed_damage110)
 var mult := pow(.6,buffs.level("distract"))*(.6 if buffs.level("forest_fireboy")>0 else 1.)
 var threshold := 5 if buffs.level("red_banner")==2 else 10
 if buffs.level("red_banner")>0 and combo>=threshold: mult*=1.4
 return super.damage_for_shot(shot)*mult
func fire_at(target: Vector3) -> void:
 if not woodland_ready110: super.fire_at(target);return
 var origins: Array[Vector3]=skills110.origins110()
 var lanes: int=1+buffs.level("distract")
 for index in origins.size():
  var origin: Vector3=origins[index];emitter110=goose if index==0 else skills110.geese110[index-1]
  for i in lanes:
   shot_origin110=origin;var direction: Vector3=(target-origin).normalized().rotated(Vector3.UP,deg_to_rad(9.*(i-(lanes-1)*.5)))
   var count := shots.size();super.fire_at(origin+direction*12.)
   if shots.size()>count: _tag_shot110(shots[-1])
 shot_origin110=Vector3.INF;emitter110=null
func _release_charged(target: Vector3,ratio: float) -> void:
 if buffs.level("flashlight")>0: beam_left110=1.1*(.45+.55*ratio);beam_power110=1.;Audio.play("slingshot");hitstop(.06,true);return
 var origins: Array[Vector3]=skills110.origins110() if is_instance_valid(skills110) else [projectile_origin()]
 for index in origins.size():
  var origin: Vector3=origins[index];emitter110=goose if index==0 else skills110.geese110[index-1]
  for i in 1+buffs.level("distract"):
   shot_origin110=origin;var count := shots.size();var direction := (target-origin).normalized().rotated(Vector3.UP,deg_to_rad(9.*(i-buffs.level("distract")*.5)));super._release_charged(origin+direction*12.,ratio)
   if shots.size()>count: _tag_shot110(shots[-1])
 shot_origin110=Vector3.INF;emitter110=null
func _tag_shot110(shot: Dictionary) -> void:
 if weapon_rng.randf()<(1. if buffs.level("music_class")>=3 else float(buffs.level("music_class"))*.33): shot.note110=true;shot.damage_multiplier=float(shot.get("damage_multiplier",1.))*1.5
 shot.split_depth110=0
func _step_fire_input(delta: float) -> void:
 if buffs.level("flashlight")>0 and buffs.level("slingshot")>0 and beam_left110>0.: return
 if buffs.level("flashlight")>0 and buffs.level("slingshot")==0:
  if fire_input_held() and not fire_needs_release and wave_state=="fighting" and not result_open and between_left<=0.: beam_left110=.12;beam_power110=1.
  elif not fire_input_held(): fire_needs_release=false
  return
 super._step_fire_input(delta)
func _apply_shot_hit(shot: Dictionary,hit: Dictionary) -> void:
 if not hit.collider.has_meta("enemy"):
  blocks+=1;notify_miss()
  var frame := Engine.get_process_frames()
  if frame!=surface_frame110:
   surface_frame110=frame;legacy_contact_art(hit.position,-shot.velocity.normalized(),false);Audio.play("crack")
  return
 var split: bool=not hit.is_empty() and hit.collider.has_meta("enemy") and not hit.collider.get_meta("enemy").dead and buffs.level("snack")>int(shot.get("split_depth110",0))
 var damage := damage_for_shot(shot)
 super._apply_shot_hit(shot,hit)
 if shot.get("stream110",false) and hit.collider.has_meta("enemy") and is_instance_valid(skills110): skills110.beam_hits110+=1
 if split: pending_splits110.append({"at":hit.position,"damage":damage*.5,"depth":int(shot.get("split_depth110",0))+1,"rid":hit.collider.get_rid()})
func _step_shots(delta: float) -> void:
 # One typed pass; no per-projectile scene tree or second tracking traversal.
 var tracking: bool=buffs.level("eye_exercise")>0
 for i in range(shots.size()-1,-1,-1):
  var shot: Dictionary=shots[i]
  var state: Pool110.BulletState=shot.node
  if tracking: _steer_shot(shot,delta)
  var start: Vector3=state.at;var velocity: Vector3=shot.velocity;var end := start+velocity*delta
  var hit := _trace_shot(shot,start,end)
  shot.life-=delta
  if not shot.get("stream110",false) and int(shot.get("split_depth110",0))==0:
   shot.trail_distance+=start.distance_to(end)
   if shot.trail_distance>=4.5/Profile.PPM:
    emit_trail(end,velocity.normalized());shot.trail_distance=fmod(shot.trail_distance,4.5/Profile.PPM)
  if not hit.is_empty(): _apply_shot_hit(shot,hit)
  elif shot.life<=0.: _shot_expired(shot)
  if not hit.is_empty() or shot.life<=0.:
   pool110.retire(shot);shots.remove_at(i)
  else: state.previous=start;state.at=end
 var pending := pending_splits110.duplicate();pending_splits110.clear()
 for split in pending:
  for i in (6 if buffs.level("snack")==2 else 4):
   var a := TAU*float(i)/float(6 if buffs.level("snack")==2 else 4);var dir := Vector3(cos(a),0,sin(a))
   var shot: Dictionary=data_shot110(split.at+dir*(.62+5./Profile.PPM),dir*Profile.BULLET_SPEED,.5)
   shot.split_depth110=split.depth;shot.fixed_damage110=split.damage;shot.ignore_rids110=[split.rid]
func parry_success(contact: Vector3,outward: Vector3) -> void:
 super.parry_success(contact,outward)
 if buffs.level("paper_racer")>0:
  for enemy in near_enemies110(Vector2(contact.x,contact.z),2.5): enemy.impulse+=Vector2(outward.x,outward.z).normalized()*8.
func _projectile_node110() -> Variant: return pool110.take_node()
func _projectile_record110(node: Variant,velocity: Vector3) -> Dictionary:
 var record: Dictionary=pool110.record(node,velocity);record.hit_rids=[];record.ignore_rids110=[];return record
func _projectile_anchor24(_at: Vector3) -> Variant: return pool110.take_art(self)
func _attach_projectile110(node: Variant) -> void: node.reset_physics_interpolation()
func _bullet_shadow110(node: Variant) -> Variant: return node.shadow
func _retire_projectile110(shot: Dictionary) -> void: pool110.retire(shot)
func _clear_combat_shots() -> void:
 for shot in shots: pool110.retire(shot)
 shots.clear();pending_splits110.clear();beam_left110=0.
func _leave_encounter() -> void:
 if is_instance_valid(skills110): skills110.reset110()
 super._leave_encounter();cells110.clear()
func _exit_tree() -> void:
 super._exit_tree();pool110.dispose()
func _unhandled_input(event: InputEvent) -> void:
 if event is InputEventKey and event.pressed and not event.echo and not event.ctrl_pressed and not event.alt_pressed and event.physical_keycode==KEY_F11:
  trial_offset110=(trial_offset110+1)%8;start_combat();return
 super._unhandled_input(event)

func _trace_shot(shot: Dictionary,start: Vector3,end: Vector3) -> Dictionary:
 var piercing: bool=shot.get("piercing110",false) or shot.get("charged",false)
 var excluded: Array[RID]=[hero.get_rid()]
 for rid: RID in shot.ignore_rids110: excluded.append(rid)
 if piercing:
  for rid: RID in shot.hit_rids: excluded.append(rid)
 query110.from=start;query110.to=end;query110.exclude=excluded
 for i in 16:
  var hit := space110.intersect_ray(query110)
  if hit.is_empty() or not piercing or not hit.collider.has_meta("enemy"): return hit
  var rid: RID=hit.collider.get_rid();excluded.append(rid);shot.hit_rids.append(rid)
  shot.target110=null;shot.target_until110=0.;_apply_shot_hit(shot,hit)
  query110.exclude=excluded
 return {}
func _shot_sound_enabled110() -> bool: return not stream_emitting110 and not fragment_emitting110
func flashlight_damage_gain110() -> float:return 1.+.6*(1.-health_fraction())
func flashlight_rate_gain110() -> float:return 1.+.6*(1.-health_fraction())
func emit_stream110(target: Vector3) -> void:
 if combat_clock33-stream_last110>.10: stream_generation110+=1
 stream_last110=combat_clock33;stream_sequence110+=1
 var origins: Array[Vector3]=skills110.origins110();var lanes: int=1+buffs.level("distract")
 var empower := flashlight_damage_gain110()
 for emitter in origins.size():
  for lane in lanes:
   var origin := origins[emitter];var direction := (target-origin).normalized().rotated(Vector3.UP,float(lane-(lanes-1)*.5)*.16)
   var shot: Dictionary=data_shot110(origin+direction*5./Profile.PPM,direction*300./Profile.PPM,1.4)
   shot.stream110=true;shot.stream_lane110=emitter*3+lane;shot.stream_generation110=stream_generation110;shot.stream_sequence110=stream_sequence110;shot.stream_heavy110=buffs.level("slingshot")>0
   shot.piercing110=true;shot.hit_rids=[];shot.split_depth110=0;shot.shadow.hide()
   shot.damage_multiplier=(.45 if buffs.level("slingshot")>0 else .4)*empower
 shot_origin110=Vector3.INF

func wave_unit() -> String: return "幕"
func can_perfect_dodge(enemy: CharacterBody3D) -> bool:
 if enemy.get("rank110")!=null and enemy.rank110>0:
  return enemy.estate110 in ["dash","charge","crash"] or (enemy.estate110 in ["rage","hang","lean"] and enemy.timer110<=.12)
 return super.can_perfect_dodge(enemy)

func _steer_shot(shot: Dictionary,delta: float) -> void:
 var at: Vector3=shot.node.position;var forward := Vector2(shot.velocity.x,shot.velocity.z)
 var speed2 := forward.length_squared()
 if speed2<.0001: return
 var saved_target: Variant=shot.get("target110");var chosen: CharacterBody3D=saved_target if is_instance_valid(saved_target) else null
 if is_instance_valid(chosen) and chosen.dead: chosen=null;shot.target_until110=0.
 if not is_instance_valid(chosen) and combat_clock33<float(shot.get("target_until110",0.)): return
 if combat_clock33>=float(shot.get("target_until110",0.)):
  chosen=null;var closest := pow(240./Profile.PPM,2.);var cone := cos(1.4 if buffs.level("eye_exercise")==1 else 1.9)
  var speed := sqrt(speed2)
  for enemy in enemies:
   if not is_instance_valid(enemy) or enemy.dead: continue
   if (not shot.hit_rids.is_empty() and enemy.hit_area.get_rid() in shot.hit_rids) or (not shot.ignore_rids110.is_empty() and enemy.hit_area.get_rid() in shot.ignore_rids110): continue
   var toward := Vector2(enemy.position.x-at.x,enemy.position.z-at.z);var distance := toward.length_squared()
   if distance<closest and forward.dot(toward)>cone*speed*sqrt(distance): chosen=enemy;closest=distance
  shot.target110=chosen;shot.target_until110=combat_clock33+.08
 if not is_instance_valid(chosen): return
 var desired := (chosen.position+Vector3.UP*.65-at).normalized();var rate := 2.5 if buffs.level("eye_exercise")==1 else 4.
 var turn := clampf(forward.angle_to(Vector2(desired.x,desired.z)),-rate*delta,rate*delta)
 var flat := forward.normalized().rotated(turn);var speed: float=shot.velocity.length()
 var vy: float=lerpf(shot.velocity.y,desired.y*speed,minf(1.,rate*delta));var horizontal := sqrt(maxf(0.,speed*speed-vy*vy))
 shot.velocity=Vector3(flat.x*horizontal,vy,flat.y*horizontal)
func _build_shadow_batch110() -> void:
 shadow_batch110=MultiMeshInstance3D.new();shadow_batch110.name="BudgetedProjectileShadows110"
 var mesh := PlaneMesh.new();mesh.size=Vector2(.28,.18)
 var multi := MultiMesh.new();multi.transform_format=MultiMesh.TRANSFORM_3D;multi.use_colors=true;multi.mesh=mesh;multi.instance_count=64;multi.visible_instance_count=0
 shadow_batch110.multimesh=multi;shadow_batch110.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var ink := ShaderMaterial.new();ink.shader=preload("res://scripts/art/projectile_shadow110.gdshader");shadow_batch110.material_override=ink;add_child(shadow_batch110)
func _draw_projectile_shadows105() -> void:
 if not is_instance_valid(shadow_batch110): return
 var count := 0;var direction: Vector3=-sun.global_basis.z.normalized()
 for pass_index in 2:
  for shot in shots:
   if shot.get("stream110",false): continue
   if count>=64: break
   var fragment: bool=int(shot.get("split_depth110",0))>0
   if fragment!=(pass_index==1): continue
   var at: Vector3=shot.node.position
   if not camera.is_position_in_frustum(at): continue
   var projected := at
   for i in 3: projected=at+direction*((floor_height(Vector2(projected.x,projected.z))-at.y)/direction.y)
   var point := Vector2(projected.x,projected.z);var height := floor_height(point)
   var normal := Vector3(-(floor_height(point+Vector2(.1,0))-height)/.1,1.,-(floor_height(point+Vector2(0,.1))-height)/.1).normalized()
   var right := Vector3.FORWARD.cross(normal).normalized();var forward_axis := right.cross(normal)
   var gain: float=shot.art.scale_gain if shot.has("art") else 1.
   var basis := Basis(right,normal,forward_axis).scaled(Vector3(gain,1.,gain))
   shadow_batch110.multimesh.set_instance_transform(count,Transform3D(basis,Vector3(projected.x,height+.033,projected.z)))
   shadow_batch110.multimesh.set_instance_color(count,Color(1,1,1,clampf(.50-(at.y-height)*.07,.23,.5)));count+=1
  if count>=64: break
 shadow_batch110.multimesh.visible_instance_count=count;shadow_count110=count


func _shot_recoil_enabled110() -> bool:
 if stream_emitting110 or fragment_emitting110: return false
 if is_instance_valid(emitter110) and emitter110!=goose:
  emitter110.recoil(shots[-1].velocity);return false
 return true
func resolved_fire_target(target: Vector3,origin: Vector3) -> Vector3:
 return emitter110.resolve_target(target,origin) if is_instance_valid(emitter110) else super.resolved_fire_target(target,origin)
func cup_contact_enemy(enemy: CharacterBody3D,direction: Vector3) -> void:
 if not is_instance_valid(contact_emitter110): super.cup_contact_enemy(enemy,direction);return
 if combat_paused or wave_state!="fighting" or player_hp<=0. or enemy.dead: return
 cup_contact_active=true;cup_contact_hits+=1;enemy.impact_contact=contact_emitter110.muzzle()
 enemy.receive_hit(.5*projectile_damage(),direction);cup_contact_active=false
