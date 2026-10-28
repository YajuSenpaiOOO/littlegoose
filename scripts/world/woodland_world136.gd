extends "res://scripts/world/woodland_world135.gd"
const HILL136=preload("res://scripts/world/park_layout136.gd")
var hill_ready136 := false
var hill_visited136 := false
var vista136: Sprite3D
var hill_removed_trees136 := 0
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 136 · 山路转阶 / 望海纸坪")
func _build_lab_floor() -> void:
 super._build_lab_floor();meadow=preload("res://scripts/world/world_surface136.gd").new()
func _park_script99() -> Script: return preload("res://scripts/art/paper_hill136.gd")
func _build_woodland() -> void:
 super._build_woodland()
 var keep: Array[Dictionary]=[]
 for tree in trees:
  var p: Vector2=Vector2(tree.root.position.x,tree.root.position.z)-Vector2(meadow.landmarks.grove)
  var view_corridor := p.x< -20. and p.x> -34. and p.y> -10. and p.y<7.
  if HILL136.clear136(p) or view_corridor: tree.root.free();hill_removed_trees136+=1
  else: keep.append(tree)
 trees.assign(keep)
func _grass_growth92(at: Vector2) -> float:
 if meadow!=null and not meadow.landmarks.is_empty():
  var p: Vector2=at-Vector2(meadow.landmarks.grove)
  if HILL136.stair136(p).x<1.45: return 0.
  if HILL136.radius136(p)<1.: return .18
 return super._grass_growth92(at)
func floor_height(at: Vector2) -> float:
 var h := super.floor_height(at)
 if meadow!=null and is_instance_valid(park99):
  var p: Vector2=at-Vector2(meadow.landmarks.grove)
  if HILL136.stair136(p).x<1.65: h=maxf(h,park99.support102(at))
 return h
func _step_actor102(actor: CharacterBody3D,delta: float) -> void:
 super._step_actor102(actor,delta)
 if not is_instance_valid(park99): return
 var at := Vector2(actor.position.x,actor.position.z)
 if HILL136.stair136(at-Vector2(meadow.landmarks.grove)).x>1.55: return
 var direction := Vector2(actor.velocity.x,actor.velocity.z)
 if actor==hero: direction+=hero.movement_input()*hero.movement_speed()
 if direction.length()<.1: return
 var ahead := at+direction.normalized()*.24
 var support: float=park99.support102(ahead)
 var rise := support-actor.position.y
 if rise>.008 and rise<.30 and actor.velocity.y<=.5:
  actor.position.y=support+.012;actor.velocity.y=0.;assisted_steps102+=1
func _ready() -> void:
 super._ready()
 while not is_instance_valid(drops120): await get_tree().physics_frame
 # Later decoration passes can add props after the tree pass. Clear only the
 # reserved summit and stair footprint; keep the existing lower forest intact.
 for rock in forest87.rocks87:
  if HILL136.clear136(rock.at-Vector2(meadow.landmarks.grove)):
   rock.body.collision_layer=0;rock.visual.hide();rock.shadow.hide()
 for plant in forest87.plants87:
  if is_instance_valid(plant) and HILL136.clear136(Vector2(plant.position.x,plant.position.z)-Vector2(meadow.landmarks.grove)): plant.hide()
 vista136=Sprite3D.new();vista136.name="DistantCoast136";vista136.texture=load("res://assets/paper_hill136/coast.png")
 vista136.pixel_size=.070;vista136.billboard=BaseMaterial3D.BILLBOARD_ENABLED
 vista136.no_depth_test=false;vista136.shaded=false;vista136.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 add_child(vista136)
 var g: Vector2=meadow.landmarks.grove
 vista136.position=Vector3(g.x-47.,-5.,g.y-48.)
 vista136.extra_cull_margin=10.;vista136.hide()
 hill_ready136=true;_title35()
 if "--hill136" in OS.get_cmdline_user_args():
  _teleport15(g+Vector2(-7.8,1.8));encounter_hud.announce("山顶的小纸坪","沿石阶上山，经过转弯的小缓台；F4直接试纸怪。",4.)
 print("PAPER_HILL136_READY treads=",park99.hill_treads136," cleared_trees=",hill_removed_trees136)
func _physics_process(delta: float) -> void:
 super._physics_process(delta)
 if not hill_ready136: return
 var p: Vector2=Vector2(hero.position.x,hero.position.z)-Vector2(meadow.landmarks.grove)
 vista136.visible=p.x< -9. and p.y< -4. and p.y> -29.
 if not hill_visited136 and (not active114 or not paper_trial129) and HILL136.radius136(p)<1.12:
  hill_visited136=true;paper_trial129=true;start_combat(false)
func start_combat(reposition := true) -> void:
 if not paper_trial129:
  # The inherited grove proximity trigger reaches the foot of the old stairs.
  # Leave that access route quiet; explicit F5 still invites the Tuantuan fight.
  if not reposition and is_instance_valid(hero):
   var p: Vector2=Vector2(hero.position.x,hero.position.z)-Vector2(meadow.landmarks.grove)
   if p.x< -6.2 and p.y<3.5: return
  super.start_combat(reposition);return
 super.start_combat(false)
 if reposition:
  _teleport15(Vector2(meadow.landmarks.grove)+HILL136.CENTER+Vector2(2.,3.5))
 if hill_ready136: hill_visited136=true
 encounter_hud.announce("山顶作业纸 · %d张"%paper_count131,"海风把纸页吹到了山顶。1—4试搭配，F6六/十张，F5团团，F3回院。",3.)
func _spawn_wave110(index: int) -> void:
 if not paper_trial129: super._spawn_wave110(index);return
 for actor in reuse119:
  if is_instance_valid(actor): actor.queue_free()
 reuse119.clear();clear_standby119()
 for actor in enemies:
  if is_instance_valid(actor): remove_child(actor);actor.queue_free()
 enemies.clear();round_index=0;between_left=0.;_clear_combat_shots();packs114=1;created120=paper_count131
 var center: Vector2=Vector2(meadow.landmarks.grove)+HILL136.CENTER
 for i in paper_count131:
  var angle := TAU*float(i)/float(paper_count131)
  var at := center+Vector2(cos(angle)*3.2,sin(angle)*3.7)
  var actor := make_actor119(i,at);actor.home=center;enemies.append(actor);actor.play119()
 rebuild_cells110();target114=null;aim_tick114=-1
