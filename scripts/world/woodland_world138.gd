extends "res://scripts/world/woodland_world135.gd"
const HILL138=preload("res://scripts/world/park_layout137.gd")
var hill_ready138 := false
var hill_visited138 := false
var coast138: Node3D
var trimmed138 := 0
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 138 · 山体树林恢复 / 整幅海景")
func _park_script99() -> Script: return preload("res://scripts/art/paper_hill137.gd")
func _navigation_script72() -> Script: return preload("res://scripts/combat/woodland_navigation137.gd")
func _build_lab_floor() -> void:
 super._build_lab_floor()
 for node in get_children():
  if node is MeshInstance3D and node.mesh is BoxMesh and not node.visible:
   var size: Vector3=node.mesh.size
   if is_equal_approx(size.y,16.) and (size.x<.31 or size.z<.31): node.free()
 meadow=preload("res://scripts/world/world_surface138.gd").new()
 var bounds: Rect2=meadow.world_bounds
 for x in [bounds.position.x,bounds.end.x]: _box(Vector3(x,5.,bounds.get_center().y),Vector3(.3,16.,bounds.size.y),Color.TRANSPARENT,true,false)
 for z in [bounds.position.y,bounds.end.y]: _box(Vector3(bounds.get_center().x,5.,z),Vector3(bounds.size.x,16.,.3),Color.TRANSPARENT,true,false)
func reserved138(p: Vector2) -> bool:
 return HILL138.stair137(p).x<1.8 or ((p-HILL138.CENTER)/Vector2(4.1,3.6)).length()<1.
func _build_woodland() -> void:
 # Preserve the original forest's sampling region and authored tree placements.
 var expanded: Rect2=meadow.world_bounds
 meadow.world_bounds=meadow.original_bounds138
 super._build_woodland()
 meadow.world_bounds=expanded
 var keep: Array[Dictionary]=[]
 for tree in trees:
  var p: Vector2=Vector2(tree.root.position.x,tree.root.position.z)-Vector2(meadow.landmarks.grove)
  if reserved138(p): tree.root.free();trimmed138+=1
  else: keep.append(tree)
 trees.assign(keep)
func _grass_growth92(at: Vector2) -> float:
 if meadow!=null and not meadow.landmarks.is_empty():
  var p: Vector2=at-Vector2(meadow.landmarks.grove)
  if HILL138.stair137(p).x<1.5: return 0.
  if at.x<meadow.original_bounds138.position.x and meadow.height_at(at.x,at.y,true)<-6.: return 0.
  if ((p-HILL138.CENTER)/Vector2(5.5,4.8)).length()<1.: return .20
 return super._grass_growth92(at)
func _step_actor102(_actor: CharacterBody3D,_delta: float) -> void: pass
func _ready() -> void:
 super._ready()
 while not is_instance_valid(drops120): await get_tree().physics_frame
 for lamp in lamps106.lamps106:
  var p: Vector2=Vector2(lamp.root.position.x,lamp.root.position.z)-Vector2(meadow.landmarks.grove)
  if p.distance_to(PARK99.DECK+Vector2(-1.3,-.5))<.3:
   var moved: Vector2=Vector2(meadow.landmarks.grove)+PARK99.DECK+Vector2(1.9,-.5)
   lamp.root.position=Vector3(moved.x,floor_height(moved),moved.y)
 for rock in forest87.rocks87:
  if reserved138(rock.at-Vector2(meadow.landmarks.grove)):
   rock.body.collision_layer=0;rock.visual.hide();rock.shadow.hide()
 for plant in forest87.plants87:
  if is_instance_valid(plant) and reserved138(Vector2(plant.position.x,plant.position.z)-Vector2(meadow.landmarks.grove)): plant.hide()
 coast138=preload("res://scripts/art/coastal_vista138.gd").new();coast138.world=self;add_child(coast138)
 hill_ready138=true;_title35()
 if "--hill138" in OS.get_cmdline_user_args(): _teleport15(Vector2(meadow.landmarks.grove)+Vector2(-7.8,1.8))
 print("PAPER_HILL138_READY trees=",trees.size()," trimmed=",trimmed138)
func _physics_process(delta: float) -> void:
 super._physics_process(delta)
 if not hill_ready138: return
 var p: Vector2=Vector2(hero.position.x,hero.position.z)-Vector2(meadow.landmarks.grove)
 if not hill_visited138 and (not active114 or not paper_trial129) and ((p-HILL138.CENTER)/Vector2(8.,7.)).length()<1.:
  hill_visited138=true;paper_trial129=true;start_combat(false)
func start_combat(reposition := true) -> void:
 if not paper_trial129:
  if not reposition and is_instance_valid(hero):
   var p: Vector2=Vector2(hero.position.x,hero.position.z)-Vector2(meadow.landmarks.grove)
   if p.x< -6.2 and p.y<3.5: return
  super.start_combat(reposition);return
 super.start_combat(false)
 if reposition: _teleport15(Vector2(meadow.landmarks.grove)+HILL138.CENTER+Vector2(2.,4.))
 if hill_ready138: hill_visited138=true
 encounter_hud.announce("山顶作业纸 · %d张"%paper_count131,"1—4试搭配 · F6六/十张 · F5团团 · F3回院",3.)
func _spawn_wave110(index: int) -> void:
 if not paper_trial129: super._spawn_wave110(index);return
 for actor in reuse119:
  if is_instance_valid(actor): actor.queue_free()
 reuse119.clear();clear_standby119()
 for actor in enemies:
  if is_instance_valid(actor): remove_child(actor);actor.queue_free()
 enemies.clear();round_index=0;between_left=0.;_clear_combat_shots();packs114=1;created120=paper_count131
 var center: Vector2=Vector2(meadow.landmarks.grove)+HILL138.CENTER
 for i in paper_count131:
  var angle := TAU*float(i)/float(paper_count131)
  var at := center+Vector2(cos(angle)*4.0,sin(angle)*4.6)
  var actor := make_actor119(i,at);actor.home=center;enemies.append(actor);actor.play119()
 rebuild_cells110();target114=null;aim_tick114=-1
