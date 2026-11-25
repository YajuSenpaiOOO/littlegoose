extends "res://scripts/world/woodland_world353.gd"
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 354 · 换绳追荡 / 猪猪扫喷")
func _ready() -> void:
 await super._ready()
 hint288.text="354 换绳追荡 / 猪猪扫喷\n空中换挂点追投 · 猪猪每轮预告锁扇区 · C装配 / F7重试"
func spawn347(kind: String) -> CharacterBody3D:
 if kind=="normal":return super.spawn347(kind)
 var actor=preload("res://scripts/combat/spider_bomber354.gd").new() if kind=="bomber" else preload("res://scripts/combat/pig354.gd").new()
 actor.battle=self;actor.poses=combat_poses;actor.textures=combat_textures
 actor.role110=serial347%3;actor.home=centre301;actor.touch110=0.;actor.max_hp110=22. if kind=="bomber" else 12.;actor.hp=actor.max_hp110
 actor.set_meta("elite347",true);actor.set_meta("batch347",batch347);actor.set_meta("kind347",kind)
 var wish:=centre301+Vector2(-1.8 if serial347%2==0 else 1.8,-.4)
 var at: Vector2=navigation.origin+Vector2(navigation.nearest(wish))*navigation.CELL
 if kind=="pig":at=pig_site354()
 actor.position=Vector3(at.x,floor_height(at)+.04,at.y)
 add_child(actor)
 if kind=="bomber":actor.mode119="playing"
 actors347.append(actor);enemies.append(actor);serial347+=1
 _add_actor_shadow(actor,actor.visual);actor.reset_physics_interpolation();rebuild_cells110()
 log347("entry",{"type":kind})
 return actor

func pig_site354() -> Vector2:
 var player:=Vector2(hero.global_position.x,hero.global_position.z)
 var best:=entry_point347();var score:=INF
 var shape:=CapsuleShape3D.new();shape.radius=.5;shape.height=1.2
 var query:=PhysicsShapeQueryParameters3D.new();query.shape=shape;query.collision_mask=1|2|16;query.exclude=[hero.get_rid()]
 for i in 16:
  var angle:=TAU*float(i)/16.+float(serial347%2)*.2
  var wish:=player+Vector2(cos(angle),sin(angle))*3.2
  var at: Vector2=navigation.origin+Vector2(navigation.nearest(wish))*navigation.CELL
  if at.distance_to(player)<2.4 or at.distance_to(player)>4.2:continue
  var point:=Vector3(at.x,floor_height(at)+.7,at.y)
  query.transform=Transform3D(Basis.IDENTITY,point)
  if not get_world_3d().direct_space_state.intersect_shape(query,1).is_empty():continue
  var ray:=PhysicsRayQueryParameters3D.create(point,hero.global_position+Vector3.UP*.55,1|2,[hero.get_rid()])
  if not get_world_3d().direct_space_state.intersect_ray(ray).is_empty():continue
  var weight:=absf(at.distance_to(player)-3.2)+at.distance_to(centre301)*.12
  if weight<score:score=weight;best=at
 return best
func report_stats226() -> Dictionary:
 var report:=super.report_stats226();report.runtime_preview=354
 report.pursuit354={"grapple_windup":.25,"anchor_interval":2.1,"max_speed":5.2,"pig_speed":4.2,"pig_life":2.2,"pig_retargets":"warning only"}
 return report
func _process(delta: float) -> void:
 super._process(delta)
 if ready350:guide206.text=guide206.text.replace("353 吊绳投弹蛛","354 换绳追荡 / 猪猪扫喷")
