extends "res://scripts/world/woodland_world139.gd"
const HILL140=preload("res://scripts/world/park_layout140.gd")
var hill_ready140 := false
var coast140: Node3D
var cleared140 := 0
var hill_camera140 := 0.
var coast_edge140: Node3D
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 140 · 层次纸坪 / 环崖木栏 / 远海天际")
func _build_lab_floor() -> void:
 super._build_lab_floor();meadow=preload("res://scripts/world/world_surface140.gd").new()
func _park_script99() -> Script: return preload("res://scripts/art/paper_hill140.gd")
func _build_woodland() -> void:
 super._build_woodland()
 var keep: Array[Dictionary]=[]
 for tree in trees:
  var p: Vector2=Vector2(tree.root.position.x,tree.root.position.z)-Vector2(meadow.landmarks.grove)
  if HILL140.radius140(p)<.99: tree.root.free();cleared140+=1
  else: keep.append(tree)
 trees.assign(keep)
func _grass_growth92(at: Vector2) -> float:
 if meadow!=null and not meadow.landmarks.is_empty():
  var p: Vector2=at-Vector2(meadow.landmarks.grove)
  if HILL136.stair136(p).x<1.45: return 0.
  var radius := HILL140.radius140(p)
  if radius<.72: return .13
  if radius<1.: return .48
 return super._grass_growth92(at)
func _update_camera(delta: float,snap := false) -> void:
 var target := 0.
 if is_instance_valid(hero) and meadow!=null and not meadow.landmarks.is_empty():
  var p: Vector2=Vector2(hero.position.x,hero.position.z)-Vector2(meadow.landmarks.grove)
  target=1.-smoothstep(.8,1.45,HILL140.radius140(p))
 hill_camera140=target if snap else move_toward(hill_camera140,target,delta*.7)
 var saved := camera_distance;camera_distance*=1.+.17*hill_camera140
 super._update_camera(delta,snap);camera_distance=saved
func _ready() -> void:
 super._ready()
 while not hill_ready139: await get_tree().physics_frame
 coast139.process_mode=Node.PROCESS_MODE_DISABLED;coast139.hide()
 # Clear only the newly designated playable meadow, keep the lower forest.
 for rock in forest87.rocks87:
  if HILL140.radius140(rock.at-Vector2(meadow.landmarks.grove))<.96:
   rock.body.collision_layer=0;rock.visual.hide();rock.shadow.hide()
 for plant in forest87.plants87:
  if is_instance_valid(plant) and HILL140.radius140(Vector2(plant.position.x,plant.position.z)-Vector2(meadow.landmarks.grove))<.96: plant.hide()
 coast140=preload("res://scripts/art/coastal_vista140.gd").new();coast140.world=self;add_child(coast140)
 coast_edge140=_coastal_edge_script140().new();coast_edge140.world=self;add_child(coast_edge140)
 hill_ready140=true;_title35()
 if "--hill140" in OS.get_cmdline_user_args(): _teleport15(Vector2(meadow.landmarks.grove)+Vector2(-7.8,1.8))
 print("PAPER_HILL140_READY posts=",park99.fence_posts140," spans=",park99.fence_spans140," cleared_local_trees=",cleared140)
func _spawn_wave110(index: int) -> void:
 super._spawn_wave110(index)
 if not paper_trial129: return
 var center: Vector2=Vector2(meadow.landmarks.grove)+HILL140.CENTER
 for i in enemies.size():
  var angle := TAU*float(i)/float(enemies.size())
  var at := center+Vector2(cos(angle)*4.8,sin(angle)*6.5)
  var actor: CharacterBody3D=enemies[i]
  actor.home=center;actor.position=Vector3(at.x,floor_height(at),at.y);actor.reset_physics_interpolation()
 rebuild_cells110()

func _coastal_edge_script140() -> Script: return preload("res://scripts/art/coastal_edge140.gd")
