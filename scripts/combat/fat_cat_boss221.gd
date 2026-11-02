extends "res://scripts/combat/fat_cat_boss220.gd"
## 221 balance experiment: late commitment, reachable distance, at most two rolls.
var show_lane221 := false
var parry_separation221 := false
var windup_time221 := .5
var locked221 := false
var burst221 := 0
var planned_time221 := 1.
var roll_distance221 := 0.
var previous_player221 := Vector2.INF
var player_velocity221 := Vector2.ZERO
var walls221 := 0
var terrain_stops221 := 0
var completed221 := 0
var last_stop221 := ""
const ROLL_SPEED221 := 9.5
func _ready() -> void:
 super._ready();next_roll220=.9
func enter220(next: String) -> void:
 var follow=next=="windup" and phase220=="roll" and burst221==1
 super.enter220(next)
 if next=="windup":
  parry_separation221=false
  if not follow:burst221=0
  windup_time221=.32 if follow else .5
  locked221=false;lane220.hide()
 if next=="roll":burst221+=1;roll_distance221=0.;last_stop221=""
 if next=="chase":next_roll220=1.35;burst221=0
func followup_allowed221() -> bool:return true
func recovery_time221() -> float:return 1.1
func roll_speed_scale221() -> float:return 1.
func clear_distance221(direction: Vector2,travel: float) -> float:
 var query=PhysicsShapeQueryParameters3D.new();query.shape=get_child(0).shape
 query.transform=global_transform*get_child(0).transform;query.transform.origin.y+=.05
 query.motion=Vector3(direction.x,0.,direction.y)*travel;query.margin=.005
 query.collision_mask=1|2;query.exclude=[get_rid(),battle.hero.get_rid()]
 var fractions=get_world_3d().direct_space_state.cast_motion(query)
 return travel*fractions[0] if fractions.size()==2 else 0.
func lock221(player: Vector2) -> void:
 var at=Vector2(position.x,position.z)
 var lead=(player_velocity221*.16).limit_length(.75)
 var wanted=player+lead
 var direction=(wanted-at).normalized()
 if direction.length_squared()<.01:direction=Vector2.LEFT
 var travel=clampf(at.distance_to(wanted)+3.,4.5,9.975)
 var best=direction;var best_score=-INF
 for angle in [0.,.35,-.35,.65,-.65]:
  var candidate=direction.rotated(angle)
  var clearance=clear_distance221(candidate,travel)
  var score=clearance-absf(angle)*2.
  if score>best_score:best_score=score;best=candidate
 roll_origin220=at;roll_dir220=best;locked220=wanted
 planned_time221=travel/ROLL_SPEED221;locked221=true;build_lane220()
func build_lane220() -> void:
 if not is_instance_valid(lane220):return
 var st=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var side=Vector2(-roll_dir220.y,roll_dir220.x)*.95
 var length221=clear_distance221(roll_dir220,ROLL_SPEED221*planned_time221)
 length221=maxf(.1,length221)
 for i in 20:
  var a=roll_origin220+roll_dir220*length221*float(i)/20.
  var b=roll_origin220+roll_dir220*length221*float(i+1)/20.
  if absf(battle.floor_height(a)-battle.floor_height(b))>.25:break
  for point in [a-side,a+side,b+side,a-side,b+side,b-side]:st.add_vertex(Vector3(point.x,battle.floor_height(point)+.04,point.y))
 lane220.mesh=st.commit()
func _physics_process(delta: float) -> void:
 if not ready220 or battle.combat_paused or not battle.active114:return
 var player=Vector2(battle.hero.position.x,battle.hero.position.z)
 if previous_player221!=Vector2.INF:
  var measured=(player-previous_player221)/maxf(delta,.001)
  if measured.length()<12.:player_velocity221=player_velocity221.lerp(measured.limit_length(5.5),.25)
  else:player_velocity221=Vector2.ZERO
 previous_player221=player
 var roll_scale=roll_speed_scale221() if phase220=="roll" else 1.
 clock_anim220+=delta;clock220+=delta*roll_scale;flash=maxf(0.,flash-delta)
 if phase220=="down":_render_legacy(0.);return
 var at=Vector2(position.x,position.z)
 if parry_separation221 and at.distance_to(player)>1.6:parry_separation221=false
 var motion=Vector2.ZERO
 if phase220=="chase":
  next_roll220-=delta;path_clock-=delta
  if path_clock<=0.:route=battle.cat_path227(at,player) if battle.has_method("cat_path227") else battle.navigation.path(at,player);path_clock=.35
  while route.size()>1 and at.distance_to(route[0])<.6:route.remove_at(0)
  var toward=(route[0]-at).normalized() if not route.is_empty() else (player-at).normalized()
  for angle in [0.,.65,-.65,1.25,-1.25,1.7,-1.7]:
   var direction=toward.rotated(angle)
   if not test_move(global_transform,Vector3(direction.x,0.,direction.y)*.6) and absf(battle.floor_height(at+direction*.5)-position.y)<.25:
    motion=direction*1.1*float(get_meta("locomotion_scale153",1.));break
  if next_roll220<=0. and at.distance_to(player)<8.5 and (not battle.has_method("cat_can_roll227") or battle.cat_can_roll227(at,player)):enter220("windup");motion=Vector2.ZERO
 elif phase220=="windup":
  if not locked221:
   roll_dir220=(player-at).normalized()
   # Follow only during preparation; final .18s and actual roll are committed.
   if clock220>=windup_time221-.18:lock221(player)
  if clock220>=windup_time221:enter220("roll")
 elif phase220=="roll":
  motion=roll_dir220*ROLL_SPEED221*roll_scale
  if clock220>=planned_time221:
   completed221+=1;last_stop221="range"
   if followup_allowed221() and burst221==1 and not attack_connected and at.distance_to(player)>1.6 and at.distance_to(player)<8. and roll_distance221>1.5:
    enter220("windup")
   else:enter220("recover")
   motion=Vector2.ZERO
 elif phase220=="recover":
  if clock220>=recovery_time221():enter220("chase")
 var was_roll=phase220=="roll"
 var before=position
 var next=at+motion*delta
 var h: float=battle.floor_height(next)
 if absf(h-position.y)>.25:
  if was_roll:terrain_stops221+=1;last_stop221="terrain";enter220("recover")
  motion=Vector2.ZERO;h=position.y
 velocity=Vector3(motion.x,0.,motion.y)
 var hit=move_and_collide(Vector3(motion.x*delta,h-position.y,motion.y*delta))
 var struck_hero=hit!=null and hit.get_collider()==battle.hero
 if was_roll:roll_distance221+=Vector2(position.x-before.x,position.z-before.z).length()
 if hit!=null and phase220=="roll" and not struck_hero:
  walls221+=1;last_stop221="wall";enter220("recover")
 var closest=Geometry2D.get_closest_point_to_segment(player,Vector2(before.x,before.z),Vector2(position.x,position.z))
 if closest.distance_to(player)<1.30 and absf(position.y-battle.hero.position.y)<.75:
  if was_roll and battle.hero.can_parry():deflect(battle.hero.position+Vector3.UP*.6);attack_connected=true;last_stop221="parry"
  elif not parry_separation221 and battle.invulnerability<=0. and battle.hero.dodge_invulnerability<=0.:
   var before_hp: float=battle.player_hp
   battle.hurt_player_from(22. if was_roll else 12.,Vector2(position.x,position.z),"roll" if was_roll else "touch")
   if battle.player_hp<before_hp:
    contact_count220+=1
    if was_roll:rolled_hits220+=1;attack_connected=true;last_stop221="hit"
 if struck_hero and phase220=="roll":enter220("recover")
 _render_legacy(0.)
func deflect(contact: Vector3) -> void:
 super.deflect(contact)
 # A successful parry must not turn into ordinary touch damage on the next tick.
 # This belongs to this cat only: cotton and other attacks keep their own checks.
 parry_separation221=true;attack_connected=true;last_stop221="parry"
func roll_frame220() -> int:
 var cycles=2 if planned_time221>=.75 else 1
 return int(clampf(clock220/maxf(planned_time221,.001),0.,.999999)*float(6*cycles))%6
func _render_legacy(lift: float) -> void:
 super._render_legacy(lift)
 if ready220:lane220.visible=show_lane221 and phase220=="windup" and locked221
