extends Node3D

const HILL=preload("res://scripts/world/park_layout136.gd")
const ACTOR=preload("res://scripts/combat/paper347.gd")
const SCRAPS=preload("res://assets/workshop432/torn-homework-drop.png")
const NOTEBOOK=preload("res://assets/workshop432/summit-exercise-book.png")
const ENTRY:=[Vector2(-3.,-.8),Vector2(1.4,-3.4),Vector2(-2.8,2.1),Vector2(3.3,-1.2)]
const TINT:=Color("f6dab0")
const PICKUP_RANGE:=.86

class BookPaper:
 extends "res://scripts/combat/paper347.gd"

 var exit_at:Vector3
 var book_at:Vector3

 func _physics_process(delta:float) -> void:
  if entry347<=0. or dead:
   super._physics_process(delta)
   return
  if battle.combat_paused:return
  entry347=maxf(0.,entry347-delta)
  var progress:=1.-entry347/.9
  var flight:=ease(progress,.62)
  position=book_at.lerp(exit_at,flight)
  active_ai=false
  hit_area.collision_layer=0
  _render_legacy(.23+sin(progress*PI)*.94+progress*.37)
  visual.scale*=lerpf(.20,1.,smoothstep(0.,.38,progress))
  if entry347==0.:play119()

var world:Node3D
var center:Vector2
var marker:Node3D
var papers:Array[Node3D]=[]
var actors:Array[CharacterBody3D]=[]
var active:=false
var spawned:=0
var kills:=0
var pickup_clock:=0.
var book_sprite:Sprite3D

func build() -> void:
 center=world.grove432+HILL.CENTER
 marker=make_prop(center+Vector2(1.0,2.05),1.19,NOTEBOOK)
 marker.name="SummitExerciseBook"
 book_sprite=marker.get_child(1)
 book_sprite.rotation_degrees.x=-55.
 book_sprite.offset.y=NOTEBOOK.get_height()*.41
 book_sprite.position.y=.025
 book_sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON
 marker.get_child(0).free()

func ground(at:Vector2) -> Vector3:
 return Vector3(at.x,world.floor_height(at),at.y)

func make_prop(at:Vector2,width:float,texture:Texture2D=SCRAPS) -> Node3D:
 var prop:=Node3D.new()
 add_child(prop)
 prop.position=ground(at)
 var shadow:=MeshInstance3D.new()
 var plane:=PlaneMesh.new()
 plane.size=Vector2(width*.82,width*.52)
 shadow.mesh=plane
 var ink:=ShaderMaterial.new()
 ink.shader=preload("res://scripts/art/foot_contact16.gdshader")
 shadow.material_override=ink
 shadow.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 shadow.position.y=.014
 prop.add_child(shadow)
 var art:=Sprite3D.new()
 art.texture=texture
 art.pixel_size=width/texture.get_width()
 art.rotation_degrees.x=-52.
 art.position.y=.13
 art.shaded=true
 art.modulate=Color(.83,.82,.77)
 art.alpha_cut=SpriteBase3D.ALPHA_CUT_DISCARD
 art.alpha_scissor_threshold=.72
 art.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
 art.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 prop.add_child(art)
 return prop

func in_reach(prop:Node3D,distance:float) -> bool:
 return world.hero.global_position.distance_squared_to(prop.global_position)<distance*distance

func collect(paper:Node3D) -> bool:
 var count:int=paper.get_meta("paper_count",1)
 var kit=world.memory_kit116
 var previous:int=kit.homework_paper
 kit.homework_paper=mini(previous+count,999999)
 if kit.save_to(world.memory_save116)!=OK:
  kit.homework_paper=previous
  world.materials432.notify("作业纸没能收好 · 可以再捡一次")
  return false
 world.materials432.pickup_fx.burst(paper.get_meta("pickup_point",paper.global_position)+Vector3.UP*.12,TINT)
 world.materials432.notify("捡到扯下的作业纸 ×%d"%count)
 papers.erase(paper)
 paper.queue_free()
 return true

func _physics_process(delta:float) -> void:
 if world.combat_paused or not world.hero.controls_enabled or papers.is_empty():return
 pickup_clock+=delta
 var feet:Vector3=world.hero.global_position
 var hand:=feet+Vector3.UP*.33
 for index in range(papers.size()-1,-1,-1):
  var paper:=papers[index]
  if pickup_clock<float(paper.get_meta("pickup_ready",0.)):continue
  if not paper.has_meta("pickup_point"):
   var offset:=feet-paper.global_position
   if absf(offset.y)>.48 or Vector2(offset.x,offset.z).length_squared()>=PICKUP_RANGE*PICKUP_RANGE:continue
   paper.set_meta("pickup_point",paper.global_position)
   paper.get_child(0).hide()
  paper.global_position=paper.global_position.move_toward(hand,4.6*delta)
  if paper.global_position.distance_to(hand)<.13 and not collect(paper):
   paper.set_meta("pickup_ready",pickup_clock+1.)

func start() -> void:
 active=true
 spawned=0
 kills=0
 world.jobs347.clear()
 world.events347.clear()
 world.actors347.clear()
 world.batch347=-1
 world.age347=0.
 world.hold347=0.
 world.serial347=0
 world.kills347=0
 world.elite_kills347=0
 world.meteor_left347=4.5
 world.queue_batch347()

func step(delta:float) -> void:
 if not active or world.combat_paused:return
 var feet:Vector3=world.hero.global_position
 if Vector2(feet.x,feet.z).distance_to(center)>8.5 or absf(feet.y-world.floor_height(center))>1.75:
  world.finish251(false)
  return
 world.director347(delta)

func spawn(kind:String) -> CharacterBody3D:
 var elite:=kind!="normal"
 var from_book:bool=world.batch347==0 and not elite
 var actor:CharacterBody3D
 if from_book:actor=BookPaper.new()
 elif not elite:actor=ACTOR.new()
 elif kind=="knight":actor=preload("res://scripts/combat/paper_card312.gd").new()
 else:actor=preload("res://scripts/combat/paper_card306.gd").new()
 actor.battle=world
 actor.poses=world.combat_poses
 actor.textures=world.combat_textures
 actor.role110=spawned%3
 actor.home=center
 actor.max_hp110=3. if not elite else (12. if kind=="dinosaur" else 14.)
 actor.hp=actor.max_hp110
 actor.touch110=1.
 actor.set_meta("elite347",elite)
 actor.set_meta("kind347",kind)
 actor.set_meta("batch347",world.batch347)
 if elite:actor.kind301=kind
 var point:Vector2=center+ENTRY[spawned] if from_book else world.entry_point347()
 actor.position=ground(point)+Vector3.UP*.04
 if from_book:
  actor.exit_at=actor.position
  actor.book_at=marker.global_position+Vector3.UP*.04
  actor.position=actor.book_at
 world.add_child(actor)
 if not elite:
  actor.mode119="playing"
  actor.active_ai=false
 if from_book:
  actor.hit_area.collision_layer=0
  actor._render_legacy(.23)
  actor.visual.scale*=.20
  book_sprite.scale=Vector3(.96,1.07,1.)
  create_tween().tween_property(book_sprite,"scale",Vector3.ONE,.26).set_trans(Tween.TRANS_BACK)
 actors.append(actor)
 world.actors347.append(actor)
 world.enemies.append(actor)
 world._add_actor_shadow(actor,actor.visual)
 actor.reset_physics_interpolation()
 world.rebuild_cells110()
 spawned+=1
 world.serial347=spawned
 world.log347("entry",{"type":kind})
 return actor

func defeated(actor:CharacterBody3D) -> void:
 if actor.get_meta("paper_dropped432",false):return
 actor.set_meta("paper_dropped432",true)
 kills+=1
 world.defeated_count=kills
 world.kills347=kills
 if actor.get_meta("elite347",false):
  world.elite_kills347+=1
  world.hold347=2.
  world.log347("elite_defeated")
 world.enemies.erase(actor)
 if world.target114==actor:world.target114=null
 world.aim_tick114=-1
 world.rebuild_cells110()
 var at:=Vector2(actor.position.x,actor.position.z)
 var paper:=make_prop(at,.64)
 papers.append(paper)
 paper.set_meta("pickup_ready",pickup_clock+.44)
 var art:Sprite3D=paper.get_child(1)
 art.position.y+=.55
 var drift:=paper.create_tween().set_parallel()
 drift.tween_property(art,"position:y",.13,.44).set_trans(Tween.TRANS_SINE)
 drift.tween_property(art,"rotation:z",-.24,.44)

func stop() -> void:
 active=false
 book_sprite.scale=Vector3.ONE
 for actor in actors:
  if not is_instance_valid(actor):continue
  world.enemies.erase(actor)
  actor.queue_free()
 actors.clear()
 world.actors347.clear()
 world.jobs347.clear()
 world.clear_patterns327()
 # Keep loose papers in a reachable place between rounds.
 var count:=0
 for index in range(papers.size()-1,-1,-1):
  var paper:=papers[index]
  if paper.has_meta("pickup_point"):continue
  count+=int(paper.get_meta("paper_count",1))
  papers.remove_at(index)
  paper.queue_free()
 if count==0:return
 var stack:=make_prop(center+Vector2(-.45,1.35),.82 if count>1 else .64)
 stack.set_meta("paper_count",count)
 stack.set_meta("pickup_ready",pickup_clock+.35)
 papers.append(stack)
