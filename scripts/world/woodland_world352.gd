extends "res://scripts/world/woodland_world351.gd"
var closeup_left352:=10.
var closeup_serial352:=0
var next_throw352:=0.
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 352 · 蜘蛛连投 / 镜前荡过")
func _ready() -> void:
 await super._ready()
 hint288.text="352 蜘蛛连投 / 镜前荡过\n10血蜘蛛 · 线团可射散/闪避/弹反 · C装配 / F7重试"
func restart301() -> void:
 super.restart301()
 closeup_left352=10.;closeup_serial352=0;next_throw352=0.
func _silk_script171() -> Script:return preload("res://scripts/combat/silk_ball352.gd")
func reserve_spider170(actor: CharacterBody3D) -> bool:
 if not ready350:return super.reserve_spider170(actor)
 if combat_paused or not active114 or wave_state!="fighting" or actor.dead or not actor.active_ai or age347<next_throw352:return false
 var busy:=0
 for other in live347():
  if other!=actor and other.state170 in ["winding","push"]:busy+=1
 if busy>=2:return false
 next_throw352=age347+.65
 return true
func spawn347(kind: String) -> CharacterBody3D:
 var actor: CharacterBody3D=preload("res://scripts/combat/spider352.gd").new() if kind=="normal" else preload("res://scripts/combat/pig351.gd").new()
 actor.battle=self;actor.poses=combat_poses;actor.textures=combat_textures
 actor.role110=serial347%3;actor.home=centre301;actor.touch110=1.
 actor.max_hp110=10. if kind=="normal" else 12.;actor.hp=actor.max_hp110
 actor.set_meta("elite347",kind!="normal");actor.set_meta("batch347",batch347);actor.set_meta("kind347",kind)
 var at:=entry_point347();actor.position=Vector3(at.x,floor_height(at)+.04,at.y)
 add_child(actor)
 if kind=="normal":actor.mode119="playing"
 actors347.append(actor);enemies.append(actor);serial347+=1
 _add_actor_shadow(actor,actor.visual);actor.reset_physics_interpolation();rebuild_cells110()
 log347("entry",{"type":"spider" if kind=="normal" else "pig"})
 return actor

func tick_atmosphere351(delta: float) -> void:
 atmosphere351=atmosphere351.filter(func(actor):return is_instance_valid(actor))
 atmosphere_clock351-=delta;closeup_left352-=delta
 if atmosphere351.size()>=2:return
 if closeup_left352<=0.:
  spawn_closeup352();closeup_left352=26.+float(closeup_serial352%2)*6.
 if atmosphere_clock351>0. or atmosphere351.size()>=2:return
 atmosphere_clock351=15.+float(atmosphere_serial351%3)*2.
 var actor=preload("res://scripts/combat/spider351.gd").new()
 actor.battle=self;actor.poses=combat_poses;actor.textures=combat_textures
 actor.ambient351=true;actor.ambient_scale351=.45;actor.role110=atmosphere_serial351
 var screen:=get_viewport().get_visible_rect().size
 var pixel:=Vector2(screen.x*(.58 if atmosphere_serial351%2==0 else .73),screen.y*.28)
 var depth: float=(hero.global_position-camera.global_position).dot(-camera.global_basis.z)-2.
 actor.position=camera.project_position(pixel,depth)-Vector3.UP*2.
 add_child(actor);atmosphere351.append(actor);atmosphere_serial351+=1
func spawn_closeup352() -> Node3D:
 var actor=preload("res://scripts/combat/spider352.gd").new()
 actor.battle=self;actor.poses=combat_poses;actor.textures=combat_textures
 actor.ambient351=true;actor.ambient_scale351=2.2;actor.closeup352=true;actor.reverse352=closeup_serial352%2==1
 actor.position=hero.position
 add_child(actor);actor.closeup_pose352(0.);actor.reset_physics_interpolation()
 atmosphere351.append(actor);closeup_serial352+=1
 return actor
func report_stats226() -> Dictionary:
 var report:=super.report_stats226();report.runtime_preview=352
 report.plush352={"spider_hp":10,"contact_damage":false,"attack_slots":2,"ball_speed":3.8,"web_every":4}
 return report
func _process(delta: float) -> void:
 super._process(delta)
 if ready350:guide206.text=guide206.text.replace("351 蛛丝入退场 / 猪猪棉絮","352 蜘蛛连投 / 镜前荡过")
