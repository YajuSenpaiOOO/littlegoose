extends "res://scripts/world/woodland_world224.gd"
const TIMES225={"knock":.7,"walk":2.,"board":.8,"lift":1.3,"fly":1.8,"cat_in":2.,"cat_lower":.8,"unload":.45,"depart":1.2}
const ORDER225=["knock","walk","board","lift","fly","cat_in","cat_lower","unload","depart"]
const LABELS225={"knock":"门后传来动静","walk":"姐姐缓缓走出","board":"扶边坐下","lift":"吊床升空","fly":"飞向战场","cat_in":"肥猫运送中","cat_lower":"缓缓放下肥猫","unload":"肥猫落地","depart":"运输蝙蝠离开"}
var ready225 := false
var stage225 := "waiting"
var age225 := 0.
var door225 := Vector2.ZERO
var bed225 := Vector2.ZERO
var wait_at225 := Vector2.ZERO
var air_start225 := Vector3.ZERO
var delivery225: Node3D
var preserve_hero225 := false
var selected_mirror225 := false
var rejected225 := 0
var intro_history225: Array[String]=[]
func _init() -> void:
 super._init();memory_save116="user://plush_boss225_preview.cfg"
func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 225 · 敲门入场 / 四蝙蝠空运肥猫")
func _sister_script220() -> Script:return preload("res://scripts/art/sister_entry225.gd")
func _ready() -> void:
 await super._ready()
 var cottage: Sprite3D=forest188.cottage_sprite
 door225=Vector2(cottage.global_position.x,cottage.global_position.z)+Vector2(0.,.85)
 bed225=door225+Vector2(2.2,.9)
 arena220=choose_arena225()
 wait_at225=door225+Vector2(1.,1.45)
 delivery225=preload("res://scripts/art/cat_airlift225.gd").new();delivery225.world=self;add_child(delivery225)
 ready225=true;active114=false;wave_state="waiting";target114=null;_clear_combat_shots()
 battle_phase220="ended";result220="靠近小屋门口，按E敲门";rig220.hide()
 _teleport15(wait_at225)
func choose_arena225() -> Vector2:
 var shape=CapsuleShape3D.new();shape.radius=1.05;shape.height=2.1
 var query=PhysicsShapeQueryParameters3D.new();query.shape=shape;query.collision_mask=1|2;query.exclude=[hero.get_rid()]
 for offset in [Vector2(4.5,5.5),Vector2(4.,4.),Vector2(3.,5.),Vector2(5.,5.),Vector2(6.,6.),Vector2(6.,4.),Vector2(2.5,6.)]:
  var at=door225+offset;var h: float=floor_height(at)
  query.transform.origin=Vector3(at.x,h+1.12,at.y)
  if absf(h-FOREST188.BASE)<.15 and get_world_3d().direct_space_state.intersect_shape(query,1).is_empty():return at
 push_warning("225: cottage clearing candidates need manual placement review")
 return door225+Vector2(4.5,5.5)
func begin220() -> void:
 # Parent ready normally auto-starts combat. This preview starts at the door.
 if ready225:start_battle225(false)
func _teleport15(at: Vector2) -> void:
 if not preserve_hero225:super._teleport15(at)
func knock225() -> bool:
 if stage225!="waiting" or Vector2(hero.position.x,hero.position.z).distance_to(door225)>2.25:return false
 saved_hp220=player_hp;saved_buffs220=buffs.levels.duplicate(true)
 stage225="knock";age225=0.;intro_history225.assign(["knock"])
 hero.cancel_guard109();hero.reset_actions();hero.controls_enabled=false;hero.velocity=Vector3.ZERO;hero.locomotion=Vector2.ZERO;hero.combat_impulse=Vector2.ZERO
 combat_paused=false;rig220.reset_fall224();rig220.entering225=true;rig220.hide();delivery225.reset225();delivery225.hide()
 var goal=Vector3(arena220.x,floor_height(arena220)+1.6,arena220.y)
 var pixels=(camera.unproject_position(goal+camera.global_basis.x)-camera.unproject_position(goal)).length()
 air_start225=goal+camera.global_basis.x*((-260.-camera.unproject_position(goal).x)/maxf(1.,pixels))
 return true
func start_battle225(keep_player: bool) -> void:
 stage225="battle";combat_paused=false
 rig220.entering225=false;rig220.show();delivery225.hide()
 preserve_hero225=keep_player;super.begin220();preserve_hero225=false
 stage225="battle"
 drop_wait220=4.
func stop225() -> void:
 if active114:super.end220(false)
 stage225="waiting";combat_paused=false;hero.controls_enabled=true
 rig220.entering225=false;rig220.reset_fall224();rig220.hide();delivery225.hide()
 rig220.lost220=-1
 for bat in bats220:bat.hp=bat.max_hp110;bat.set_enabled220(false)
 if is_instance_valid(cat220):cat220.hide();cat220.dead=true;cat220.hit_area.collision_layer=0;cat220.collision_layer=0
 target114=null;clear_pig220();_clear_combat_shots()
func end220(victory: bool) -> void:
 if not ready225:return
 if stage225=="battle":
  super.end220(victory)
  if not victory:stop225()
 else:stop225()
func _process(delta: float) -> void:
 if alternate_encounter251():super._process(delta);return
 if not ready225:super._process(delta);return
 if stage225=="battle":
  super._process(delta)
  guide206.text=guide206.text.replace("224 姐姐软落地","225 敲门Boss")+"\nF8直接战斗 · F7回门口 · 猪猪退场后留空档"
  guide206.text=guide206.text.replace("F7重开","F7回门口")
  return
 var saved=ready220;ready220=false;super._process(delta);ready220=saved
 guide206.text="225 小屋敲门 / 四蝙蝠运猫\n"+("靠近门口按E敲门" if stage225=="waiting" else LABELS225[stage225]+" · F6暂停 · F8跳过")+"\nF7回门口 / F8直接开打 / F3小院"+("\n【暂停】" if combat_paused else "")
 if stage225=="waiting" or combat_paused:return
 age225+=delta
 var duration: float=TIMES225[stage225];var t=clampf(age225/duration,0.,1.)
 var high=arena220+Vector2(1.,-1.2)
 rig220.show();rig220.step225=stage225=="walk"
 if stage225=="knock":rig220.hide();guide206.text+="\n咚、咚……"
 elif stage225=="walk":rig220.entry_pose225(door225.lerp(bed225,smoothstep(0.,1.,t)),bed225,false,true,.08,delta)
 elif stage225=="board":rig220.entry_pose225(bed225,bed225,t>.45,true,.08,delta)
 elif stage225=="lift":rig220.entry_pose225(bed225,bed225,true,true,lerpf(.08,2.,smoothstep(0.,1.,t)),delta)
 elif stage225=="fly":
  var at=bed225.lerp(high,smoothstep(0.,1.,t));rig220.entry_pose225(at,at,true,true,2.,delta)
 else:
  rig220.entry_pose225(high,high,true,true,2.,delta);delivery225.show()
  var ground=Vector3(arena220.x,floor_height(arena220),arena220.y)
  if stage225=="cat_in":delivery225.place225(air_start225.lerp(ground+Vector3.UP*1.6,smoothstep(0.,1.,t)),delta)
  elif stage225=="cat_lower":delivery225.place225(ground+Vector3.UP*lerpf(1.6,.04,smoothstep(0.,1.,t)),delta)
  elif stage225=="unload":delivery225.place225(ground+Vector3.UP*(sin(t*PI)*.06),delta,0.,sin(t*PI)*.10)
  elif stage225=="depart":delivery225.place225(ground,delta,t)
 if age225>=duration:
  var next=ORDER225.find(stage225)+1
  if next>=ORDER225.size():intro_history225.append("battle");start_battle225(true)
  else:stage225=ORDER225[next];age225=0.;intro_history225.append(stage225)
func fire_at(target: Vector3) -> void:
 if ready225 and stage225=="battle":super.fire_at(target)
func hurt_player(damage: float,from: Vector2) -> void:
 if ready225 and stage225=="battle":super.hurt_player(damage,from)
func clear_pig220() -> void:
 var quiet=ready225 and is_instance_valid(pig220) and pig220.phase219=="gone" and cotton220.active.is_empty()
 super.clear_pig220()
 if quiet:drop_wait220=maxf(drop_wait220,2.)
func open_drop225(at: Vector2) -> bool:
 var h: float=floor_height(at)
 if absf(h-FOREST188.BASE)>.25:return false
 var shape=SphereShape3D.new();shape.radius=.48
 var query=PhysicsShapeQueryParameters3D.new();query.shape=shape;query.collision_mask=1|2;query.exclude=[hero.get_rid()]
 query.transform.origin=Vector3(at.x,h+.52,at.y)
 return get_world_3d().direct_space_state.intersect_shape(query,1).is_empty()
func safe_drop225(at: Vector2,direction: Vector2,distance: float) -> bool:
 if not open_drop225(at):return false
 var cat_at=Vector2(cat220.position.x,cat220.position.z)
 if at.distance_to(cat_at)<2.:return false
 if cat220.phase220 in ["roll","windup"]:
  var close=Geometry2D.get_closest_point_to_segment(at,cat220.roll_origin220,cat220.roll_origin220+cat220.roll_dir220*9.975)
  if close.distance_to(at)<1.7:return false
 var side=Vector2(-direction.y,direction.x)
 var end=at+direction*distance
 if not open_drop225(end+side*1.25) and not open_drop225(end-side*1.25):return false
 var ray=PhysicsRayQueryParameters3D.create(Vector3(at.x,floor_height(at)+.4,at.y),Vector3(end.x,floor_height(end)+.4,end.y),1|2,[hero.get_rid()])
 return get_world_3d().direct_space_state.intersect_ray(ray).is_empty()
func pig_target225() -> Vector2:
 return Vector2(hero.position.x,hero.position.z)+(Vector2(hero.velocity.x,hero.velocity.z)*.2).limit_length(.6)
func choose_drop220() -> Vector2:
 var target=pig_target225()
 var base=Vector2(-1.,.4).normalized()
 for mirror in [false,true]:
  var direction=Vector2(-base.x,base.y) if mirror else base
  var side=Vector2(-direction.y,direction.x)
  for distance in [2.4,2.8,3.1]:
   for offset in [0.,.35,-.35]:
    var at=target-direction*distance+side*offset
    if safe_drop225(at,direction,distance):selected_mirror225=mirror;return at
 rejected225+=1;return Vector2.INF
func release_pig220() -> void:
 var direction=Vector2(1.,.4).normalized() if selected_mirror225 else Vector2(-1.,.4).normalized()
 if not safe_drop225(drop_goal220,direction,2.4):rejected225+=1;return
 clear_pig220()
 pig220=preload("res://scripts/art/pig_drop225.gd").new();pig220.world=self;pig220.mirrored225=selected_mirror225;pig220.direction219=direction
 pig220.position=Vector3(drop_goal220.x,floor_height(drop_goal220),drop_goal220.y)
 rig220._process(0.);pig220.source220=rig220.seated.global_position+camera.global_basis.y*.25
 add_child(pig220);pig220.stream=cotton220;cotton220.pig=pig220;cotton220.running=true;dropped220+=1
func _input(event: InputEvent) -> void:
 if ready225 and event is InputEventKey and event.pressed and not event.echo:
  match event.physical_keycode:
   KEY_E:
    if stage225=="waiting":knock225()
    get_viewport().set_input_as_handled();return
   KEY_F7:stop225();_teleport15(wait_at225);return
   KEY_F8:start_battle225(false);return
   KEY_F2:stop225();return
   KEY_F6:
    if stage225 not in ["waiting","battle"]:combat_paused=not combat_paused;return
   KEY_F3:stop225();super._input(event);return
  if stage225!="battle":return
 super._input(event)
