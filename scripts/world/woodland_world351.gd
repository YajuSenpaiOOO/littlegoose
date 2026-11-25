extends "res://scripts/world/woodland_world349.gd"
const PLAN350=[
 {"name":"小蜘蛛探头","normal":4,"elite":[]},
 {"name":"蜘蛛与喷棉机关","normal":5,"elite":["pig"]},
 {"name":"丝球与小网垫","normal":5,"elite":[]},
 {"name":"绕开猪猪喷道","normal":5,"elite":["pig"]},
 {"name":"玩偶小队收尾","normal":4,"elite":["pig"]}]
var ready350:=false
var atmosphere351: Array[Node3D]=[]
var atmosphere_clock351:=7.
var atmosphere_serial351:=0
func clear_pads350() -> void:
 for pad in pads172.duplicate():remove_pad172(pad)
func release_silk171(actor: CharacterBody3D,direction: Vector2) -> void:
 super.release_silk171(actor,direction)
 if not silk171.is_empty():silk171[-1].touch110=1.
func plan347() -> Array:return PLAN350
func _title35() -> void:DisplayServer.window_set_title("小白鹅 · 350 · 姐姐林间普通战")
func _ready() -> void:
 await super._ready()
 ready350=true
 restart301()
 hint288.text="351 蛛丝入退场 / 猪猪棉絮\n小蜘蛛＋可拆猪猪机关 · C装配 / F7重试"
func restart301() -> void:
 clear_atmosphere351()
 clear_pads350();clear_silk171()
 super.restart301()
 if not ready350:return
 context202=true;navigation=forest_navigation202;spider_trial170=true
 var cell: Vector2i=navigation.nearest(arena220)
 centre301=navigation.origin+Vector2(cell)*navigation.CELL
 meadow.landmarks.grove=centre301
 _teleport15(centre301+Vector2(0,2.))
func queue_batch347() -> void:
 batch347+=1;batch_age347=0.
 var row: Dictionary=plan347()[batch347]
 for i in int(row.normal):jobs347.append({"type":"normal","due":float(i)*.65})
 for kind in row.elite:jobs347.append({"type":kind,"due":2.5})
 log347("batch",{"name":row.name})
func normal_cap347(elite_count: int) -> int:return 3 if elite_count>0 else 4
func elite_gate347() -> int:return 3
func entry_point347() -> Vector2:
 var offsets=[Vector2(-4,-2),Vector2(4,-1),Vector2(-3,4),Vector2(4,4)]
 var wish: Vector2=centre301+offsets[serial347%offsets.size()]
 return navigation.origin+Vector2(navigation.nearest(wish))*navigation.CELL
func spawn347(kind: String) -> CharacterBody3D:
 var actor: CharacterBody3D=preload("res://scripts/combat/spider351.gd").new() if kind=="normal" else preload("res://scripts/combat/pig351.gd").new()
 actor.battle=self;actor.poses=combat_poses;actor.textures=combat_textures
 actor.role110=serial347%3;actor.home=centre301;actor.touch110=1.
 actor.max_hp110=7. if kind=="normal" else 12.;actor.hp=actor.max_hp110
 actor.set_meta("elite347",kind!="normal");actor.set_meta("batch347",batch347);actor.set_meta("kind347",kind)
 var at:=entry_point347();actor.position=Vector3(at.x,floor_height(at)+.04,at.y)
 add_child(actor)
 if kind=="normal":actor.mode119="playing"
 actors347.append(actor);enemies.append(actor);serial347+=1
 _add_actor_shadow(actor,actor.visual);actor.reset_physics_interpolation();rebuild_cells110()
 log347("entry",{"type":"spider" if kind=="normal" else "pig"})
 return actor
func boss_step314(delta: float) -> void:
 if ready350:
  director347(delta)
  if active114:tick_atmosphere351(delta)
func on_legacy_contact(actor: CharacterBody3D,at: Vector3,direction: Vector3,juice: bool) -> void:
 if ready350 and actors347.has(actor):
  feedback_count+=1
  if is_instance_valid(fluff203):fluff203.burst(at,direction,actor.dead)
  if not cup_contact_active:notify_hit()
  return
 super.on_legacy_contact(actor,at,direction,juice)
func ordinary_record_folder347() -> String:return "user://sister_encounter_records"
func finish251(victory: bool) -> void:
 super.finish251(victory)
 if ready350:
  clear_pads350();clear_silk171();clear_atmosphere351()
  result347=result347.replace("纸怪","林间玩偶")
func return_to_yard351() -> void:
 finish251(false)
 ready350=false;ready347=false;ready301=false
 _leave_encounter();home116()
func _input(event: InputEvent) -> void:
 if ready350 and event is InputEventKey and event.pressed and not event.echo and not console226.visible:
  if event.physical_keycode>=KEY_1 and event.physical_keycode<=KEY_9:get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_F4:auto114=not auto114;get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_F3:
   return_to_yard351();get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_F7:restart301();get_viewport().set_input_as_handled();return
  if event.physical_keycode==KEY_F6:combat_paused=not combat_paused;hero.controls_enabled=not combat_paused;get_viewport().set_input_as_handled();return
 super._input(event)
func report_stats226() -> Dictionary:
 var report:=super.report_stats226();report.runtime_preview=351;report.erase("crowd348")
 if report.has("ordinary347"):report.ordinary347.result=str(report.ordinary347.result).replace("纸怪","林间玩偶")
 report.plush350={"spiders":23,"pigs":3,"reward":"none"}
 return report
func _process(delta: float) -> void:
 super._process(delta)
 if ready350:
  guide206.text="351 蛛丝入退场 / 猪猪棉絮 · %d / 5段 · 击败%d\n%s · 蜘蛛%d / 猪猪%d\nC装配 / F7重试 / F6暂停"%[batch347+1,kills347,plan347()[maxi(0,batch347)].name,live347().size(),live347(true).size()]
  guide206.text+="\n"+result347
  encounter_hud.header.text="姐姐的林间玩偶 · "+loadout_name226

func clear_atmosphere351() -> void:
 for actor in atmosphere351:
  if is_instance_valid(actor):actor.queue_free()
 atmosphere351.clear();atmosphere_clock351=7.
func tick_atmosphere351(delta: float) -> void:
 atmosphere351=atmosphere351.filter(func(actor):return is_instance_valid(actor))
 atmosphere_clock351-=delta
 if atmosphere_clock351>0. or atmosphere351.size()>=2:return
 atmosphere_clock351=13.+float(atmosphere_serial351%3)*2.
 var actor=preload("res://scripts/combat/spider351.gd").new()
 actor.battle=self;actor.poses=combat_poses;actor.textures=combat_textures
 actor.ambient351=true;actor.ambient_scale351=.45;actor.role110=atmosphere_serial351
 var far: bool=atmosphere_serial351%3!=2
 var screen:=get_viewport().get_visible_rect().size
 # Far silhouettes above the forest; occasional near-edge swing stays away from the player/HUD centre.
 var pixel:=Vector2(screen.x*((.58 if atmosphere_serial351%2==0 else .73) if far else (.10 if atmosphere_serial351%2==0 else .90)),screen.y*.28 if far else screen.y*.48)
 var depth: float=(hero.global_position-camera.global_position).dot(-camera.global_basis.z)+(-2. if far else -5.)
 actor.position=camera.project_position(pixel,depth)-Vector3.UP*2.
 if not far:actor.ambient_scale351=.65
 add_child(actor);atmosphere351.append(actor);atmosphere_serial351+=1
