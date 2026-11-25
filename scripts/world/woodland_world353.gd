extends "res://scripts/world/woodland_world352.gd"
const PLAN353=[
 {"name":"小蜘蛛探头","normal":4,"elite":[]},
 {"name":"吊绳投弹蛛","normal":5,"elite":["bomber"]},
 {"name":"绕开猪猪喷道","normal":5,"elite":["pig"]},
 {"name":"空中投弹再来一轮","normal":5,"elite":["bomber"]},
 {"name":"玩偶小队收尾","normal":4,"elite":["pig"]}]
var drops353:=0
var impacts353:=0
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 353 · 吊绳投弹蛛")
func plan347() -> Array:return PLAN353
func _ready() -> void:
 await super._ready()
 hint288.text="353 吊绳投弹蛛\n摆荡举球 → 两投 → 低处喘气 · 大线团可射散 · C装配 / F7重试"
func restart301() -> void:
 super.restart301();drops353=0;impacts353=0
func spawn347(kind: String) -> CharacterBody3D:
 if kind!="bomber":return super.spawn347(kind)
 var actor=preload("res://scripts/combat/spider_bomber353.gd").new()
 actor.battle=self;actor.poses=combat_poses;actor.textures=combat_textures
 actor.role110=serial347%3;actor.home=centre301;actor.touch110=0.;actor.max_hp110=22.;actor.hp=22.
 actor.set_meta("elite347",true);actor.set_meta("batch347",batch347);actor.set_meta("kind347","bomber")
 var wish:=centre301+Vector2(-1.8 if serial347%2==0 else 1.8,-.4)
 var at: Vector2=navigation.origin+Vector2(navigation.nearest(wish))*navigation.CELL
 actor.position=Vector3(at.x,floor_height(at)+.04,at.y)
 add_child(actor);actor.mode119="playing"
 actors347.append(actor);enemies.append(actor);serial347+=1
 _add_actor_shadow(actor,actor.visual);actor.reset_physics_interpolation();rebuild_cells110()
 log347("entry",{"type":"bomber"})
 return actor
func drop_bomb353(actor: CharacterBody3D,from: Vector3) -> CharacterBody3D:
 if not active114 or combat_paused or actor.dead:return null
 while silk171.size()>=MAX_SILK171:remove_silk171(silk171[0])
 var ball=preload("res://scripts/combat/silk_bomb353.gd").new()
 ball.battle=self;ball.start353=from;ball.position=from
 var at:=Vector2(hero.global_position.x,hero.global_position.z)
 ball.goal353=Vector3(at.x,floor_height(at)+.58,at.y)
 combat_effect_root159().add_child(ball);silk171.append(ball);_add_actor_shadow(ball,ball.visual);ball.reset_physics_interpolation()
 drops353+=1;log347("bomb_drop",{"at":[at.x,at.y]})
 return ball
func resolve_bomb353(ball: CharacterBody3D) -> void:
 impacts353+=1
 var at: Vector3=ball.goal353
 if Vector2(hero.global_position.x-at.x,hero.global_position.z-at.z).length()>1.12 or absf(hero.global_position.y-floor_height(Vector2(at.x,at.z)))>.8:return
 if hero.dodge_invulnerability>0.:
  if hero.dash_eligible:hero.dash_eligible=false;perfect_dodge()
 elif hero.can_parry():parry_success(hero.global_position+Vector3.UP*.5,Vector3.UP)
 else:hurt_player(1.,Vector2(at.x,at.z))
func _refresh_aim114(cursor: Vector2) -> void:
 super._refresh_aim114(cursor)
 if is_instance_valid(target114) and target114.has_meta("air_target353"):
  aim114=target114.hit_area.global_position+(target114.velocity*.14).limit_length(.3)
func data_shot110(origin: Vector3,velocity: Vector3,life: float) -> Dictionary:
 var shot:=super.data_shot110(origin,velocity,life)
 if is_instance_valid(target114) and target114.has_meta("air_target353") and velocity.normalized().dot((target114.hit_area.global_position-origin).normalized())>.8:shot.air353=weakref(target114)
 return shot
func seek_air353(shot: Dictionary,delta: float) -> void:
 var level:=int(shot.get("tracking146",buffs.level("eye_exercise")))
 if level<=0:return
 var target: Object=shot.air353.get_ref()
 if not is_instance_valid(target) or target.dead or target.hit_area.collision_layer==0:return
 if target.hit_area.get_rid() in shot.hit_rids or target.hit_area.get_rid() in shot.ignore_rids110:return
 var current: Vector3=shot.velocity
 var desired: Vector3=(target.hit_area.global_position-shot.node.at).normalized()
 var angle:=current.normalized().angle_to(desired)
 var fraction:=minf(1.,(2.5 if level==1 else 4.)*delta/maxf(.001,angle))
 shot.velocity=current.normalized().slerp(desired,fraction)*current.length()
func _steer_shot(shot: Dictionary,delta: float) -> void:
 if shot.has("air353"):seek_air353(shot,delta)
 else:super._steer_shot(shot,delta)
func seek343(shot: Dictionary,delta: float) -> void:
 if shot.has("air353"):seek_air353(shot,delta)
 else:super.seek343(shot,delta)
func report_stats226() -> Dictionary:
 var report:=super.report_stats226();report.runtime_preview=353
 report.plush350={"spiders":23,"pigs":2,"bombers":2,"reward":"none"}
 report.bomber353={"drops":drops353,"impacts":impacts353,"hp":22,"bomb_damage":1,"impact_only":true}
 return report
func _process(delta: float) -> void:
 super._process(delta)
 if ready350:guide206.text=guide206.text.replace("352 蜘蛛连投 / 镜前荡过","353 吊绳投弹蛛").replace("猪猪%d"%live347(true).size(),"精英%d"%live347(true).size())
