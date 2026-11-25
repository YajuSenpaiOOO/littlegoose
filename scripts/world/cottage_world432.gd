extends "res://scripts/world/woodland_world390.gd"

const LIVING_HOME = preload("res://scripts/room/cottage_living432.gd")
const YARD_LAYOUT = preload("res://scripts/world/yard_layout432.gd")
# The wide wing stops just west of the original garden fence.
const HOME_SITE := Vector2(-7.16,-8.73)
const YARD_START := HOME_SITE+Vector2(0,6.7)
const MEMORY_SHED = preload("res://scripts/art/memory_shed432.gd")
const WORKSHOP_SITE := YARD_LAYOUT.WORKSHOP_SITE
const WORKSHOP_WOOD := WORKSHOP_SITE+Vector2(-2.18,-.21)
var home432: LIVING_HOME
var workshop_shed432: MEMORY_SHED
var contacts_pending432: Array[Dictionary]=[]
var contacts_frame432 := -1
var contacts_next432 := 0
var contacts_anchor432 := Vector3.INF
var contact_ground_ray432: PhysicsRayQueryParameters3D
var smooth_view432 := true
var miniature_view432 := true
var warming_room432 := false
var goose_sweep432: CharacterBody3D
var goose_stalled432:=0.
var goose_recall_wait432:=0.
var goose_fighting432:=false
const GOOSE_RECALL_FX=preload("res://scripts/world/goose_recall_fx432.gd")
const GOOSE_RECALL_FOLD:=.19
const GOOSE_RECALL_REVEAL:=.23
var goose_recall_fx432:GOOSE_RECALL_FX
var goose_recall_age432:=-1.
const PALM_ASSEMBLY = preload("res://scripts/combat/palm_assembly432.gd")
const WORKSHOP_JOURNAL = preload("res://scripts/combat/workshop_journal432.gd")
const MATERIALS_LIST=preload("res://scripts/world/materials_list432.gd")
const FOREST_MATERIALS=preload("res://scripts/world/forest_materials432.gd")
const LIFE=preload("res://scripts/world/cottage_life432.gd")
var life432: LIFE
const PAPER_OUTING=preload("res://scripts/world/paper_outing432.gd")
const PLAYMATE_OFFSETS:=[Vector2(1.,2.5),Vector2(-2.6,-1.8),Vector2(2.9,-2.5)]
var palm432: PALM_ASSEMBLY
var journal432: WORKSHOP_JOURNAL
var materials_list432:MATERIALS_LIST
var journal_hint_alpha432:=1.
var assembling432:=false
var assembly_hint_alpha432:=1.
var materials432: FOREST_MATERIALS
var paper_outing432:PAPER_OUTING
var gel_drops432: Node3D
var playmates432: Array[CharacterBody3D]=[]
var grove432:=Vector2.ZERO
var playing_tuantuan432:=false
var health_before_trial432:=-1.

func _init() -> void:
 super._init()
 memory_kit116=preload("res://scripts/combat/workshop_tin_stock432.gd").new()
 memory_kit116.manual_save=true
 memory_save116="user://cottage432-memory.cfg"

func _time_script() -> Script:
 return preload("res://scripts/world/world_time432.gd")

func _porch_script() -> Script:
 return preload("res://scripts/art/woodland_palette432.gd")

func test_config_path226() -> String:
 return "user://cottage432-loadout.cfg"

func restore_flight_loadout383() -> bool:
 return FileAccess.file_exists(test_config_path226())

func ordinary_record_folder347() -> String:
 return "user://cottage432-encounter-records"

func _title35() -> void:
 DisplayServer.window_set_title("小白鹅 · 432 · 大世界原院小屋")

func speech_script264() -> Script:
 return preload("res://scripts/combat/goose_speech432.gd")

func _relations_script199() -> Script:
 return preload("res://scripts/art/prop_relations432.gd")

func _garden_script() -> Script:
 return preload("res://scripts/art/kitchen_garden432.gd")

func _workshop_script116() -> Script:
 return preload("res://scripts/art/memory_workshop432.gd")

func _assign_ground_materials() -> void:
 super._assign_ground_materials()
 for i in meadow.chunks.size():
  var chunk: Dictionary=meadow.chunks[i]
  if not chunk.rect.intersects(YARD_LAYOUT.BOUNDS):continue
  var lines:=PackedVector4Array()
  var widths:=PackedFloat32Array()
  for id in chunk.segments:
   var segment: Dictionary=meadow.segments[id]
   if segment.route=="home_to_junction" and segment.b.y<=YARD_LAYOUT.JOIN.y+.001 and segment.b.x< -4.6:continue
   YARD_LAYOUT.paint_segment(lines,widths,segment.a,segment.b,segment.radius)
  YARD_LAYOUT.paint_path(lines,widths,chunk.rect,YARD_LAYOUT.ENTRY,YARD_LAYOUT.ENTRY_WIDTH)
  var count:=lines.size()
  assert(count<=64,"yard road exceeds ground shader capacity")
  lines.resize(64)
  widths.resize(64)
  ground_materials[i].set_shader_parameter("route_segments",lines)
  ground_materials[i].set_shader_parameter("route_widths",widths)
  ground_materials[i].set_shader_parameter("route_count",count)

func _ready() -> void:
 await super._ready()
 return_to_yard351()
 cottage_root.hide()
 house_art.hide()
 cottage_body.collision_layer=0
 for foot in house_contacts:foot.mark.hide()
 house_contacts.clear()
 for body in cottage_root.find_children("*","CollisionObject3D",true,false):
  body.collision_layer=0
 var lantern_at:=YARD_LAYOUT.FORK_LANTERN
 var lantern:Node3D=woodland_life.lantern_root
 lantern.global_position=Vector3(lantern_at.x,open_ground432(lantern_at),lantern_at.y)
 var old_contact:=lantern.get_node_or_null("SoftRootContact45")
 if old_contact!=null:
  lantern.remove_child(old_contact)
  old_contact.queue_free()
 garden._contact(lantern,lantern_at,Vector2(.35,.24),.017,.20)
 prepare_house_site()
 var floor_y:=open_ground432(HOME_SITE+Vector2(0,4.36))+.22
 for x in range(-6,7):
  for z in range(-3,4):
   if abs(x)>3 and abs(z)>2:continue
   floor_y=maxf(floor_y,open_ground432(HOME_SITE+Vector2(x,z))+.055)
 home432=LIVING_HOME.new()
 home432.name="Cottage432"
 home432.world=self
 home432.position=Vector3(HOME_SITE.x,floor_y,HOME_SITE.y)
 warming_room432=DisplayServer.get_name()!="headless"
 add_child(home432)
 set_workshop_site()
 setup_forest_materials432()
 life432=LIFE.new()
 life432.world=self
 add_child(life432)
 setup_goose_sweep432()
 contact_ground_ray432=PhysicsRayQueryParameters3D.new()
 contact_ground_ray432.collision_mask=1
 var cottage_bodies: Array[RID]=[]
 for body in home432.find_children("*","CollisionObject3D",true,false):
  if body.collision_layer&1:cottage_bodies.append(body.get_rid())
 contact_ground_ray432.exclude=cottage_bodies
 apply_render_budget432()
 if warming_room432:
  await warm_cottage432()
 _teleport15(YARD_START)
 camera.make_current()
 _title35()
 show_yard_hint()
 print("COTTAGE432_READY site=",home432.position)

func warm_cottage432() -> void:
 var cover:=CanvasLayer.new()
 cover.layer=128
 add_child(cover)
 var backdrop:=ColorRect.new()
 backdrop.color=Color("292522")
 cover.add_child(backdrop)
 backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 var message:=Label.new()
 backdrop.add_child(message)
 message.text="正在准备小屋光影…"
 message.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 message.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
 message.add_theme_font_size_override("font_size",26)
 message.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 # A minimized window can skip drawing. Startup must still advance.
 await get_tree().process_frame
 var controls: bool=hero.controls_enabled
 hero.controls_enabled=false
 _teleport15(HOME_SITE+Vector2(1.24,1.35))
 await home432.warm_rendering()
 hero.controls_enabled=controls
 warming_room432=false
 cover.queue_free()

func apply_render_budget432() -> void:
 time55.efficient_updates432=smooth_view432
 if smooth_view432:
  sun.directional_shadow_mode=DirectionalLight3D.SHADOW_ORTHOGONAL
  sun.directional_shadow_max_distance=26.
 else:
  set_shadow_quality104(false)

func prepare_house_site() -> void:
 var bounds:=Rect2(HOME_SITE+Vector2(-6.23,-3.93),Vector2(12.46,7.22))
 var entry:=Rect2(HOME_SITE+Vector2(-1.22,3.27),Vector2(2.44,2.08))
 for tree in trees:
  var at: Vector3=tree.root.global_position
  if not bounds.has_point(Vector2(at.x,at.z)):continue
  tree.root.hide()
  for body in tree.root.find_children("*","CollisionObject3D",true,false):
   body.collision_layer=0
  print("COTTAGE432_SITE tree cleared ",tree.root.name," ",at)
 # Yard vegetation has several instance batches beyond the meadow grass.
 for batch in find_children("*","MultiMeshInstance3D",true,false):
  var mesh: MultiMesh=batch.multimesh
  if mesh==null:continue
  for i in mesh.instance_count:
   var pose:=mesh.get_instance_transform(i)
   var p: Vector3=batch.to_global(pose.origin)
   if p.y>.72:continue
   var at:=Vector2(p.x,p.z)
   if not (bounds.has_point(at) or entry.has_point(at) or YARD_LAYOUT.KUMQUAT_GROUND.has_point(at) or YARD_LAYOUT.CABINET_GROUND.has_point(at) or YARD_LAYOUT.workshop_paved(at) or YARD_LAYOUT.bath_paved(at)):continue
   pose.basis=Basis.from_scale(Vector3.ZERO)
   mesh.set_instance_transform(i,pose)
 for sprite in find_children("*","Sprite3D",true,false):
  var p: Vector3=sprite.global_position
  var at:=Vector2(p.x,p.z)
  if p.y<.65 and (bounds.has_point(at) or YARD_LAYOUT.bath_paved(at)):sprite.hide()

func _build_props15() -> void:
 # Place the legacy woodpile before its terrain feet and shadow are fitted.
 super._build_props15()
 for prop in props15:
  if prop.id=="wood":
   prop.root.position=Vector3(WORKSHOP_WOOD.x,open_ground432(WORKSHOP_WOOD),WORKSHOP_WOOD.y)
   break

func set_workshop_site() -> void:
 workshop116.hide()
 workshop116.set_process(false)
 for collider in workshop116.find_children("*","CollisionObject3D",true,false):
  collider.collision_layer=0
 workshop_shed432=MEMORY_SHED.new()
 workshop_shed432.name="MemoryShed432"
 workshop_shed432.position=Vector3(WORKSHOP_SITE.x,open_ground432(WORKSHOP_SITE)+.065,WORKSHOP_SITE.y)
 add_child(workshop_shed432)
 workshop_shed432.build(home432)
 var palm_layer:=CanvasLayer.new()
 palm_layer.layer=29
 add_child(palm_layer)
 palm432=PALM_ASSEMBLY.new()
 palm432.world=self
 palm_layer.add_child(palm432)
 palm432.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 journal432=WORKSHOP_JOURNAL.new()
 journal432.sheet=workshop_shed432.props.journal_leaf
 palm_layer.add_child(journal432)
 journal432.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
 journal432.closed.connect(close_journal432)
 journal432.craft_requested.connect(craft_journal432)
 journal432.craft_preview_requested.connect(preview_journal_craft432)
 var list_layer:=CanvasLayer.new()
 list_layer.layer=49
 add_child(list_layer)
 materials_list432=MATERIALS_LIST.new()
 materials_list432.world=self
 list_layer.add_child(materials_list432)
 materials_list432.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func setup_goose_sweep432() -> void:
 goose_sweep432=CharacterBody3D.new()
 goose_sweep432.name="GooseScenerySweep"
 goose_sweep432.collision_layer=0
 goose_sweep432.collision_mask=1|2
 var capsule:=CapsuleShape3D.new()
 capsule.radius=.18
 capsule.height=.92
 var shape:=CollisionShape3D.new()
 shape.position.y=.49
 shape.shape=capsule
 goose_sweep432.add_child(shape)
 add_child(goose_sweep432)
 goose_sweep432.add_collision_exception_with(hero)
 goose.scenery_motion385=move_goose432
 goose_recall_fx432=GOOSE_RECALL_FX.new()
 materials432.pickup_fx.get_parent().add_child(goose_recall_fx432)

func move_goose432(delta: float) -> void:
 var motion: Vector3=goose.velocity385*delta
 if home432.inside or not goose.visible:
  if goose_recall_age432>=0.:cancel_goose_recall432()
  goose_stalled432=0.
  goose_fighting432=false
  goose.global_position+=motion
  return
 if goose_recall_age432>=0. and advance_goose_recall432(delta):return
 var before:Vector3=goose.global_position
 var relative:Vector3=hero.global_position-before
 var gap:=Vector2(relative.x,relative.z).length()
 var leash:float=maxf(0.,goose.flight_radius()-1.) if goose.cup_phone else 0.
 var entering_battle:=active114 and not goose_fighting432
 goose_fighting432=active114
 goose_recall_wait432=maxf(0.,goose_recall_wait432-delta)
 var recall_range:=(4.3 if entering_battle else (6.5 if active114 else 8.))+leash
 var different_level:=absf(relative.y+.43)>1.75
 if goose_recall_age432<0. and goose_recall_wait432==0. and (gap>recall_range or goose_stalled432>=.65 or different_level):
  goose_recall_age432=0.
  goose.velocity385=Vector3.ZERO
  goose_recall_fx432.open(before,false)
  return
 var boost:=1.+smoothstep(2.2+leash,5.7+leash,gap)*.78
 motion.x*=boost
 motion.z*=boost
 if active114:
  goose_stalled432=0.
  goose.global_position+=motion
  return
 goose_sweep432.global_position=goose.global_position
 for attempt in 2:
  if motion.length_squared()<.00000001:break
  var hit:=goose_sweep432.move_and_collide(motion,false,.005,true)
  if hit==null:break
  var normal:=hit.get_normal()
  motion=hit.get_remainder().slide(normal)
  goose.velocity385=goose.velocity385.slide(normal)
 goose.global_position=goose_sweep432.global_position
 var moved:Vector3=goose.global_position-before
 var forward_step:=Vector2(moved.x,moved.z).dot(Vector2(relative.x,relative.z).normalized())
 if gap>2.75+leash and forward_step<delta*.8:
  goose_stalled432+=delta
 else:
  goose_stalled432=0.

func advance_goose_recall432(delta:float) -> bool:
 var previous:=goose_recall_age432
 goose_recall_age432+=delta
 if goose_recall_age432<GOOSE_RECALL_FOLD:
  goose.scale=Vector3.ONE*lerpf(1.,.14,smoothstep(0.,GOOSE_RECALL_FOLD,goose_recall_age432))
  return true
 if previous<GOOSE_RECALL_FOLD:
  goose_recall_wait432=.55
  if not recall_goose432():
   cancel_goose_recall432()
   return false
  goose.scale=Vector3.ONE*.14
  goose.reset_physics_interpolation()
  return true
 var reveal:=smoothstep(GOOSE_RECALL_FOLD,GOOSE_RECALL_FOLD+GOOSE_RECALL_REVEAL,goose_recall_age432)
 goose.scale=Vector3.ONE*lerpf(.14,1.,reveal)
 if reveal>=1.:goose_recall_age432=-1.
 return false

func cancel_goose_recall432() -> void:
 goose_recall_age432=-1.
 if is_instance_valid(goose):goose.scale=Vector3.ONE
 if is_instance_valid(goose_recall_fx432):goose_recall_fx432.clear()

func _travel_region(key:String) -> void:
 if is_instance_valid(materials_list432):materials_list432.restore()
 if goose_recall_age432>=0.:
  cancel_goose_recall432()
 elif is_instance_valid(goose_recall_fx432):
  goose_recall_fx432.clear()
 super._travel_region(key)

func recall_goose432() -> bool:
 var feet:Vector3=hero.global_position
 var travel:Vector3=hero.velocity
 travel.y=0.
 var back:=Vector3.BACK if travel.length_squared()<.4 else -travel.normalized()
 var side:=back.cross(Vector3.UP)
 var space:=get_world_3d().direct_space_state
 var body_shape:=goose_sweep432.get_child(0) as CollisionShape3D
 var fit:=PhysicsShapeQueryParameters3D.new()
 fit.shape=body_shape.shape
 fit.collision_mask=1|2
 fit.exclude=[hero.get_rid()]
 for offset in [back*.80+side*.53,back*.80-side*.53,side*.95,-side*.95,back*.69,Vector3.ZERO]:
  var at:Vector3=feet+offset
  var ray:=PhysicsRayQueryParameters3D.create(at+Vector3.UP*.92,at-Vector3.UP*.92,1,[hero.get_rid()])
  var support:=space.intersect_ray(ray)
  if support.is_empty() or support.normal.y<.60 or absf(support.position.y-feet.y)>.74:continue
  var landing:Vector3=support.position+Vector3.UP*.43
  fit.transform.origin=landing+body_shape.position
  if not space.intersect_shape(fit,1).is_empty():continue
  goose.global_position=landing
  goose.velocity385=Vector3.ZERO
  goose.spring_velocity=Vector2.ZERO
  goose_stalled432=0.
  goose_recall_fx432.open(landing,true)
  return true
 return false

func return_to_yard351() -> void:
 super.return_to_yard351()
 if health_before_trial432>=0.:
  preserve_determination432(health_before_trial432)
  health_before_trial432=-1.
 if is_instance_valid(home432):
  forest_mood188.update188(0.)
  show_yard_hint()

func show_yard_hint() -> void:
 mode264="away"
 guide206.hide()
 hint288.text="432 · 大世界原院小屋\nWASD 移动 · E 互动 · Tab 材料 · J 小黑鹅跟随 / 等候\nCtrl+F7 林地试演 · F3 回院"

func setup_forest_materials432() -> void:
 grove432=meadow.landmarks.grove
 materials432=FOREST_MATERIALS.new()
 materials432.world=self
 add_child(materials432)
 materials432.build()
 paper_outing432=PAPER_OUTING.new()
 paper_outing432.world=self
 add_child(paper_outing432)
 paper_outing432.build()
 gel_drops432=preload("res://scripts/combat/droplets432.gd").new()
 gel_drops432.world=self
 add_child(gel_drops432)
 ball_owned273=bool(memory_kit116.unlocked.get("bouncy_ball",false))
 boss_unlocked264=memory_kit116.tuantuan_unlocked
 awake265=boss_unlocked264
 if is_instance_valid(boss247):
  boss247.process_mode=Node.PROCESS_MODE_INHERIT
  boss247.show()
  place_rest265(not awake265)
  cushion265.show()
 spawn_playmates432()

func ambient119() -> void:
 # The home/legacy encounter lifecycle also calls the old ambient spawner.
 # Only the three playmates routed through the 432 interaction belong here.
 pass

func spawn_playmates432() -> void:
 for index in PLAYMATE_OFFSETS.size():
  var cell:Vector2i=navigation.nearest(grove432+PLAYMATE_OFFSETS[index])
  var at:Vector2=navigation.origin+Vector2(cell)*navigation.CELL
  ambient_minion264(at)
  var actor:CharacterBody3D=minions260.back()
  actor.collision_layer=0
  playmates432.append(actor)

func forest_interaction_available432() -> bool:
 return not active114 and not combat_paused and not home432.inside and hero.controls_enabled and not console226.visible

func nearby_playmate432() -> CharacterBody3D:
 for actor in playmates432:
  if is_instance_valid(actor) and actor.global_position.distance_to(hero.global_position)<2.55:return actor
 return null

func interact_forest432() -> bool:
 if not is_instance_valid(materials432) or ready350 or not forest_interaction_available432():return false
 if life432.open_basin():return true
 if paper_outing432.in_reach(paper_outing432.marker,2.35):
  paper_outing432.start()
  active114=true
  wave_state="fighting"
  stage225="battle"
  battle_phase220="fight"
  elapsed114=0.
  total_enemies=total347()
  defeated_count=0
  refill114=0.
  result_dismissed=true
  reset_player264()
  reset_skill288()
  reset_stats226(false)
  _apply_kit116()
  encounter_hud.reset_round()
  encounter_hud.announce("望海纸坪","小纸怪从作业本里飞出来了！",2.4)
  return true
 if materials432.pick_twig():return true
 if is_instance_valid(nearby_big_tuantuan432()):
  if boss_unlocked264 and boss247.wake_left265<=0.:open_dialog264("boss")
  else:say264("它还在歇着，先去和小团团玩吧。")
  return true
 if not is_instance_valid(nearby_playmate432()):return false
 playing_tuantuan432=true
 mode264="ambient"
 result_dismissed=true
 reset_player264()
 reset_skill288()
 _apply_kit116()
 ordinary264()
 for actor in playmates432:actor.collision_layer=16
 rebuild_cells110()
 encounter_hud.reset_round()
 encounter_hud.announce("和小团团玩一场","六批小团团 · 走到液滴旁边就会收起",2.4)
 return true

func nearby_big_tuantuan432() -> CharacterBody3D:
 if is_instance_valid(boss247) and boss247.visible and boss247.global_position.distance_to(hero.global_position)<3.3:return boss247
 return null

func boss264() -> void:
 if not boss_unlocked264:return
 playing_tuantuan432=true
 playmates432.clear()
 if is_instance_valid(cushion265):cushion265.hide()
 var health:=player_hp
 super.boss264()
 if is_instance_valid(life432) and not ready350:player_hp=health

func apply_levels226() -> void:
 if playing_tuantuan432:_apply_kit116()
 else:super.apply_levels226()

func enemy_defeated(actor: CharacterBody3D) -> void:
 if is_instance_valid(paper_outing432) and paper_outing432.active and actor in paper_outing432.actors:
  paper_outing432.defeated(actor)
  return
 var drop:bool=playing_tuantuan432 and actor in minions260 and not actor.get_meta("gel_dropped432",false)
 super.enemy_defeated(actor)
 if not drop:return
 actor.set_meta("gel_dropped432",true)
 var direction:=Vector2.from_angle(float(actor.role110)*2.4)
 var drop_at:=actor.global_position+Vector3.UP*.35
 var toss:=Vector3(direction.x*.62,1.35,direction.y*.62)
 gel_drops432.spawn120(drop_at,toss)
 life432.maybe_drop_seed(drop_at,Vector3(-toss.x,toss.y,-toss.z))

func paper_active432() -> bool:
 return is_instance_valid(paper_outing432) and paper_outing432.active

func defeat_drop120(actor:CharacterBody3D) -> void:
 if paper_active432() and actor in paper_outing432.actors:return
 super.defeat_drop120(actor)

func plan347() -> Array:
 return PLAN347 if paper_active432() else super.plan347()

func normal_gap347() -> float:
 return .65 if paper_active432() else super.normal_gap347()

func normal_cap347(elite_count:int) -> int:
 if not paper_active432():return super.normal_cap347(elite_count)
 return 2 if batch347==PLAN347.size()-1 else (3 if elite_count>0 else 4)

func elite_gate347() -> int:
 if not paper_active432():return super.elite_gate347()
 return 2 if batch347==PLAN347.size()-1 else 3

func spawn347(kind:String) -> CharacterBody3D:
 if paper_active432():return paper_outing432.spawn(kind)
 return super.spawn347(kind)

func entry_point347() -> Vector2:
 if not paper_active432():return super.entry_point347()
 var entries:=[Vector2(-4.2,-2.8),Vector2(4.2,-2.1),Vector2(-4.2,3.6),Vector2(4.2,3.6),Vector2(0.,-3.6)]
 var feet:=Vector2(hero.position.x,hero.position.z)
 var best:=paper_outing432.center
 for i in entries.size():
  var point:Vector2=paper_outing432.center+entries[(serial347+i)%entries.size()]
  if point.distance_to(feet)>3.5:return point
  if point.distance_to(feet)>best.distance_to(feet):best=point
 return best

func paper_clamp301(at:Vector2) -> Vector2:
 if not paper_active432():return super.paper_clamp301(at)
 return paper_outing432.center+(at-paper_outing432.center).limit_length(5.35)

func add_flight327(at:Vector2,delay:float,duration:float,source:int,meteor:bool) -> void:
 super.add_flight327(at,delay,duration,source,meteor)
 if paper_active432():
  var flight:=flights327.back() as Dictionary
  flight.sprite.reparent(self,true)
  flight.marker.reparent(self,true)
  theatre314.paint_ring327(flight.marker,at,1.35,.60)

func resolve_impact333(blast:Dictionary) -> void:
 if paper_active432() and blast.visual.root.get_parent()!=self:
  blast.radius=1.35
  blast.visual.root.reparent(self,true)
  blast.visual.root.scale*=.65
 super.resolve_impact333(blast)

func collect_gel120() -> bool:
 if memory_kit116.gel119>=999999:return true
 return super.collect_gel120()

func collect_gel432(count:int) -> bool:
 var previous:int=memory_kit116.gel119
 memory_kit116.gel119=mini(previous+count,999999)
 if memory_kit116.save_to(memory_save116)==OK:return true
 memory_kit116.gel119=previous
 return false

func grant_ball273() -> void:
 memory_kit116.set_bouncy_ball(true)
 if memory_kit116.save_to(memory_save116)!=OK:
  memory_kit116.set_bouncy_ball(false)
  materials432.notify("弹力球没能存好 · 可以再挑战一次")
  return
 ball_owned273=true
 materials432.notify("大团团送的弹力球 · 已收进曲奇铁盒")

func finish_ordinary264(victory: bool) -> void:
 var was_tuantuan:=playing_tuantuan432 and mode264=="ordinary"
 super.finish_ordinary264(victory)
 if not was_tuantuan or mode264=="ordinary":return
 playing_tuantuan432=false
 playmates432.clear()
 close_dialog264()
 gel_drops432.gather_leftovers()
 life432.seed_drops.gather_leftovers()
 if victory:
  memory_kit116.tuantuan_unlocked=true
  if memory_kit116.save_to(memory_save116)!=OK:
   materials432.notify("大团团醒了 · 挑战资格暂未存好")
  else:
   materials432.notify("大团团醒了 · 空地上的液滴可以一次收起" if not gel_drops432.items120.is_empty() else "大团团醒了 · 去断层前找它")
 else:
  reset_player264()
  materials432.notify("团团歇一会儿 · 还可以再约玩")
 show_yard_hint()

func reset_player264() -> void:
 var health:=player_hp
 super.reset_player264()
 preserve_determination432(health)

func _leave_encounter() -> void:
 var health:=player_hp
 super._leave_encounter()
 preserve_determination432(health)

func preserve_determination432(health: float) -> void:
 if is_instance_valid(life432) and not ready350:
  player_hp=clampf(health,1.,max_player_health())

func finish251(victory: bool) -> void:
 if is_instance_valid(paper_outing432) and paper_outing432.active:
  active114=false
  stage225="waiting"
  paper_outing432.stop()
  _leave_encounter()
  combat_paused=false
  reset_impact248()
  reset_player264()
  show_yard_hint()
  if victory and not paper_outing432.papers.is_empty():
   materials432.notify("纸怪散开啦 · 作业纸留在台地入口")
  return
 var was_boss:=playing_tuantuan432 and mode264=="boss"
 var health:=player_hp
 super.finish251(victory)
 if not was_boss:return
 preserve_determination432(health)
 playing_tuantuan432=false
 close_dialog264()
 gel_drops432.gather_leftovers()
 life432.seed_drops.gather_leftovers()
 reset_player264()
 cushion265.show()
 show_yard_hint()

func open_ground432(at: Vector2) -> float:
 return super.floor_height(at)

func floor_height(at: Vector2) -> float:
 if is_instance_valid(home432) and is_instance_valid(home432.house):
  var level:=home432.local_floor(at-HOME_SITE)
  if level!=-INF:return level+home432.position.y
 if is_instance_valid(workshop_shed432):
  var local:=at-WORKSHOP_SITE
  if YARD_LAYOUT.WORKSHOP_PAVING.has_point(local):
   var inset:=minf(YARD_LAYOUT.WORKSHOP_PAVING.end.y-local.y,local.y-YARD_LAYOUT.WORKSHOP_PAVING.position.y)
   inset=minf(inset,YARD_LAYOUT.WORKSHOP_PAVING.end.x-absf(local.x))
   return open_ground432(at)+.065*smoothstep(0.,.16,inset)
 return open_ground432(at)

func _ground_below_image(point: Vector3) -> Vector3:
 if contact_ground_ray432!=null:
  var origin:=camera.global_position
  contact_ground_ray432.from=origin
  contact_ground_ray432.to=origin+(point-origin).normalized()*200.
  var hit:=get_world_3d().direct_space_state.intersect_ray(contact_ground_ray432)
  # The fitted yard cards belong to the terrain. The added house floor
  # must not interrupt their rays and send every column through the old solver.
  if not hit.is_empty() and hit.collider==floor_collider.get_parent():
   return hit.position+Vector3.UP*.014
 return super._ground_below_image(point)

func _update_prop_contacts() -> void:
 if not is_instance_valid(home432):
  super._update_prop_contacts()
  return
 if warming_room432 or home432.camera.current:return
 var now:=Time.get_ticks_msec()
 var configuration_changed:=contact_terrain65!=terrain_enabled or contact_enabled65!=contact_enabled or not is_equal_approx(contact_fov65,camera.fov)
 if configuration_changed or camera.global_position.distance_squared_to(contacts_anchor432)>16.:
  contacts_pending432.clear()
  contacts_next432=now
 if Engine.get_process_frames()==contacts_frame432:return
 if contacts_pending432.is_empty():
  if now<contacts_next432:return
  contacts_next432=now+240
  contacts_anchor432=camera.global_position
  for prop in props15:
   if prop.root.position.distance_squared_to(hero.position)<1600.:
    contacts_pending432.append(prop)
 if contacts_pending432.is_empty():return
 contacts_frame432=Engine.get_process_frames()
 var prop: Dictionary=contacts_pending432.pop_front()
 var old_props:=props15
 var old_cards:=fitted_cards
 var old_marks:=contact_marks
 props15=[prop]
 fitted_cards=old_cards.filter(func(card):return card.prop==prop)
 contact_marks=old_marks.filter(func(foot):return foot.prop==prop)
 # Refresh one already-authored fitted card per frame, including the
 # last card in a batch when the player has just stopped moving.
 contact_stamp65=-1000000
 super._update_prop_contacts()
 props15=old_props
 fitted_cards=old_cards
 contact_marks=old_marks

var bath_focus_blend432:=0.

func apply_bath_focus432(blend:float) -> void:
 if blend==0. and bath_focus_blend432==0.:return
 bath_focus_blend432=blend
 var focus:ShaderMaterial=atmosphere41.focus_material
 focus.set_shader_parameter("bath_focus_blend",blend)
 if blend>0.:
  var bath=life432.bath_shed
  var steam_density:float=lerpf(.06,.26,home432.lamp_warmth)
  bath.set_steam(steam_density*(1. if life432.bathing else .56) if bath.lens.current else 0.)
  focus.set_shader_parameter("bath_focus_far",bath.to_local(bath.lens.global_position).z+1.40)

func _process(delta: float) -> void:
 super._process(delta)
 if is_instance_valid(materials_list432) and materials_list432.busy:
  apply_bath_focus432(0.)
  materials_list432.advance(delta)
  return
 if is_instance_valid(materials432) and not warming_room432:
  paper_outing432.step(delta)
  if paper_outing432.active:
   encounter_hud.header.text="望海纸坪 · 第 %d / %d 段 · %d / %d"%[batch347+1,PLAN347.size(),paper_outing432.kills,total_enemies]
   encounter_hud.footer.text="左键 开火 · 走近收作业纸 · Esc 离开"
  if playing_tuantuan432:
   guide206.hide()
   if mode264=="ordinary":
    encounter_hud.header.text="团团 · 第 %d / 6 批 · %d / %d"%[roster264.wave+1,roster264.defeated,roster264.TOTAL]
   else:
    encounter_hud.header.text="大团团 · %d / %d"%[ceili(maxf(0.,boss247.hp)),ceili(boss247.max_hp110)]
   encounter_hud.footer.text="左键 开火 · Shift 闪避 · 右键 弹反 · Esc 离开"
  var available:=forest_interaction_available432() and not ready350
  if available and playmates432.is_empty() and Vector2(hero.position.x,hero.position.z).distance_to(grove432)<22.:
   spawn_playmates432()
  var boss:=nearby_big_tuantuan432() if available else null
  var playmate:=nearby_playmate432() if available and boss==null else null
  var invitation:="挑战大团团" if boss_unlocked264 else "看看大团团"
  var anchor:Node3D=boss if boss!=null else playmate
  var action:=invitation if boss!=null else "和团团玩一场"
  if available and paper_outing432.in_reach(paper_outing432.marker,2.35):
   anchor=paper_outing432.marker
   action="看看作业本"
  if available and life432.basin_in_reach():
   if is_instance_valid(speech112.live) and speech112.live.visible:
    anchor=null
   else:
    anchor=life432.basin
    action="澡盆"
  materials432.update_prompt(delta,available,anchor,action)
 if not contacts_pending432.is_empty():_update_prop_contacts()
 if is_instance_valid(workshop_shed432) and not warming_room432:
  var at:=workshop_shed432.to_local(hero.global_position)
  var stays_near:=absf(at.x)<1.32 and at.z>-.19 and at.z<1.30
  var reaches_table:=absf(at.x)<1.04 and at.z>.06 and at.z<.89
  var use_view:=not active114 and not home432.inside and (stays_near if workshop_shed432.dolly>0. else reaches_table)
  var reading:=journal432.visible
  if reading:
   journal432.advance_craft(delta)
  var workshop_closeup:=workshop_shed432.overhead>0. or workshop_shed432.journal_overhead>0.
  workshop_shed432.update_view(delta,use_view or assembling432 or reading or workshop_closeup,camera,assembling432,reading)
  if reading:
   journal432.place_on_table(workshop_shed432.journal_paper_rect(),workshop_shed432.journal_overhead)
   var look:Dictionary=time55.palette.sample(time55.visual_hour)
   var daylight:=float(look.daylight)
   var outdoor_tone:=palm432.shade_for(look,.76)
   var paper_tone:=workshop_shed432.journal_light_tone(outdoor_tone,daylight)
   workshop_shed432.props.tint_journal_paper(paper_tone*Color(1.40,.89,.95))
   var canvas_tone:=paper_tone.lerp(Color(.74,.73,.72),(1.-daylight)*.50)
   journal432.book.modulate=Color(canvas_tone,journal432.book.modulate.a)
   journal432.diary_body.modulate=outdoor_tone.lerp(canvas_tone,.55)
   journal432.show_craft(canvas_tone)
  palm432.update_view(workshop_shed432.overhead,assembling432)
  var bath_view:=not active114 and not home432.inside and not assembling432 and not reading and not console226.visible
  life432.bath_shed.update_view(delta,bath_view,hero.global_position,camera)
  var bath=life432.bath_shed
  var behind_bath_curtain:bool=bath.lens.current and bath.curtain_amount>=.995
  set_pov_actor_mask432(not workshop_shed432.lens.get_cull_mask_value(20) or behind_bath_curtain)
  apply_bath_focus432(smoothstep(.18,1.,bath.view_amount) if bath.lens.current else 0.)

var assembly_actor_layers432: Dictionary={}

func set_pov_actor_mask432(hides_actor:bool) -> void:
 if hides_actor and assembly_actor_layers432.is_empty():
  for actor in [hero,goose,home432.companion]:
   if not is_instance_valid(actor):continue
   for card in actor.find_children("*","Sprite3D",true,false):
    assembly_actor_layers432[card]=card.layers
    card.layers=MEMORY_SHED.POV_ACTOR_LAYER
 elif not hides_actor and not assembly_actor_layers432.is_empty():
  for card in assembly_actor_layers432:
   if is_instance_valid(card):card.layers=assembly_actor_layers432[card]
  assembly_actor_layers432.clear()

func aim_at_screen(point: Vector2) -> Vector3:
 if not is_instance_valid(home432) or active114 or home432.inside:
  return super.aim_at_screen(point)
 var lens: Camera3D=get_viewport().get_camera_3d()
 var height: float=hero.global_position.y+.45
 var hit: Variant=Plane(Vector3.UP,height).intersects_ray(lens.project_ray_origin(point),lens.project_ray_normal(point))
 return hit if hit!=null else hero.global_position+Vector3.BACK

func _input(event: InputEvent) -> void:
 if is_instance_valid(life432):
  if life432.bed_choice.visible:return
  if life432.basin_choice.visible:
   if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_ESCAPE:
    life432.cancel_basin()
    get_viewport().set_input_as_handled()
   return
  if life432.bathing:
   if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode==KEY_ESCAPE:
    life432.bath_scene.skip()
   get_viewport().set_input_as_handled()
   return
  if life432.resting:
   get_viewport().set_input_as_handled()
   return
 if warming_room432:
  get_viewport().set_input_as_handled()
  return
 if is_instance_valid(materials_list432) and materials_list432.busy:
  if event is InputEventKey:
   if event.pressed and not event.echo and event.physical_keycode in [KEY_TAB,KEY_ESCAPE]:
    materials_list432.close()
   get_viewport().set_input_as_handled()
  return
 if is_instance_valid(journal432) and journal432.visible:
  if event is InputEventKey:
   if event.pressed and not event.echo:
    if event.physical_keycode==KEY_ESCAPE:
     if journal432.craft_fx.busy():journal432.skip_craft()
     else:close_journal432()
    elif event.physical_keycode==KEY_LEFT:journal432.flip_adjacent(-1)
    elif event.physical_keycode==KEY_RIGHT:journal432.flip_adjacent(1)
   get_viewport().set_input_as_handled()
  return
 if assembling432 and event is InputEventMouse and not palm432.can_use_tin():
  get_viewport().set_input_as_handled()
  return
 if is_instance_valid(home432) and event is InputEventKey and event.pressed and not event.echo:
  if assembling432:
   if event.physical_keycode==KEY_ESCAPE:palm432.begin_exit()
   get_viewport().set_input_as_handled()
   return
  if event.physical_keycode==KEY_TAB and not event.ctrl_pressed and not event.alt_pressed:
   if event.shift_pressed:
    map_panel.visible=not map_panel.visible
   elif not active114 and not combat_paused and not home432.sleeping and hero.controls_enabled and not console226.visible and not trial_ui114.menu.visible:
    if home432.camera_move==null or not home432.camera_move.is_running():materials_list432.start()
   get_viewport().set_input_as_handled()
   return
  if event.ctrl_pressed and event.alt_pressed:
   if event.physical_keycode==KEY_U and not home432.inside and not active114:
    home432.decor.toggle_parasol()
    get_viewport().set_input_as_handled()
    return
   if event.physical_keycode==KEY_R:
    smooth_view432=not smooth_view432
    apply_render_budget432()
    encounter_hud.announce("流畅档" if smooth_view432 else "原画质","Ctrl+Alt+R 切换",2.)
    get_viewport().set_input_as_handled()
    return
   if event.physical_keycode==KEY_O and home432.inside:
    home432.furniture_contacts_enabled=not home432.furniture_contacts_enabled
    home432.apply_furniture_contacts()
    get_viewport().set_input_as_handled()
    return
   if event.physical_keycode==KEY_M:
    miniature_view432=not miniature_view432
    get_viewport().set_input_as_handled()
    return
  if event.physical_keycode==KEY_F3 and not ready350 and not event.ctrl_pressed and not event.alt_pressed:
   if playing_tuantuan432 or paper_outing432.active:finish251(false)
   if dialog264.visible:close_dialog264()
   home116()
   show_yard_hint()
   get_viewport().set_input_as_handled()
   return
  if (playing_tuantuan432 or paper_outing432.active) and event.physical_keycode==KEY_ESCAPE:
   finish251(false)
   get_viewport().set_input_as_handled()
   return
  if (playing_tuantuan432 or paper_outing432.active) and (event.physical_keycode==KEY_C or event.physical_keycode in [KEY_F2,KEY_F5,KEY_F7,KEY_F8,KEY_F9,KEY_F10,KEY_F11,KEY_F12]):
   get_viewport().set_input_as_handled()
   return
  if event.physical_keycode==KEY_E and not event.ctrl_pressed and not event.alt_pressed and (home432.interact() or interact_workshop432() or interact_forest432()):
   get_viewport().set_input_as_handled()
   return
  if event.physical_keycode==KEY_F and not event.ctrl_pressed and not event.alt_pressed and interact_workshop432():
   get_viewport().set_input_as_handled()
   return
  if event.physical_keycode==KEY_J and not event.ctrl_pressed and not event.alt_pressed and not console226.visible and home432.toggle_companion_follow():
   get_viewport().set_input_as_handled()
   return
  if event.physical_keycode==KEY_F7 and event.ctrl_pressed and not ready350 and not combat_paused and not console226.visible:
   if home432.sleeping:home432.set_sleep(false)
   clear_minions260()
   playmates432.clear()
   health_before_trial432=player_hp
   ready301=true
   ready347=true
   ready350=true
   goose.use_human383=true
   restart301()
   guide206.show()
   hint288.text="林地玩偶试演 · 人形小黑鹅\n左键蓄力 / 释放 · F7 重试 · F3 回小院"
   get_viewport().set_input_as_handled()
   return
  if not ready350 and event.physical_keycode in [KEY_F7,KEY_F8,KEY_F9,KEY_F10,KEY_F11,KEY_F12]:
   get_viewport().set_input_as_handled()
   return
 super._input(event)

func interact_workshop432() -> bool:
 if not can_open_memory116() or home432.inside or memory_ui116.visible or combat_paused:return false
 if workshop_shed432.at_journal(hero.global_position):
  var icons:=palm432.fragment_art.duplicate()
  icons["paper_plane"]=palm432.paper_plane
  if ball_owned273:memory_kit116.set_bouncy_ball(true)
  journal_hint_alpha432=hint288.modulate.a
  hint288.modulate.a=0.
  speech112.dismiss()
  combat_paused=true
  hero.controls_enabled=false
  journal432.open(memory_kit116,icons,true)
  return true
 if ball_owned273:memory_kit116.set_bouncy_ball(true)
 if not open_memory116():return false
 assembling432=true
 speech112.dismiss()
 assembly_hint_alpha432=hint288.modulate.a
 hint288.modulate.a=0.
 memory_ui116.modulate.a=0.
 palm432.begin()
 return true

func close_journal432() -> void:
 if journal432.craft_fx.busy():return
 journal432.hide()
 hint288.modulate.a=journal_hint_alpha432
 combat_paused=false
 hero.controls_enabled=true
 fire_needs_release=Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)

func craft_journal432(id:String) -> void:
 if not journal432.visible or not journal432.ready_to_craft(id):return
 var result:int=memory_kit116.make_recipe(id,memory_save116)
 if result==ERR_UNAVAILABLE:
  journal432.feedback.text="材料还不够，看看右页的配方。"
  journal432.highlight_material()
  return
 if result!=OK:
  journal432.feedback.text="暂时没能存下这段记忆，再试一下。"
  return
 show_journal_craft432(id)

func preview_journal_craft432(id:String) -> void:
 if journal432.visible and journal432.ready_to_craft(id):
  show_journal_craft432(id)

func show_journal_craft432(id:String) -> void:
 journal432.craft_result(palm432.craft_marble(id))

func say_tin432(words:String) -> void:
 speech112.say_across_table(words,workshop_shed432.lens)

func card_catalog273() -> Array:
 var cards:=super.card_catalog273()
 for i in cards.size():
  if cards[i].id in ["snack","forest_fireboy"]:cards[i]=memory_kit116.card(cards[i].id)
 return cards

func close_memory116(commit: bool,trial:=false) -> bool:
 var previous: Array=memory_kit116.tin_layers
 if assembling432:speech112.dismiss()
 if assembling432 and commit:memory_kit116.tin_layers=palm432.layers
 if not super.close_memory116(commit,trial):
  memory_kit116.tin_layers=previous
  return false
 if assembling432:
  assembling432=false
  hint288.modulate.a=assembly_hint_alpha432
  memory_ui116.modulate.a=1.
 return true
