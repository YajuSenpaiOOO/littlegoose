extends "res://scripts/world/woodland_world136.gd"
const HILL137=preload("res://scripts/world/park_layout137.gd")
var hill_ready137 := false
var hill_visited137 := false
var coast137: Node3D
var cliff_guard137: StaticBody3D
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 137 · 海岬草坪 / 分层远景 / 缓坡石阶")
func _park_script99() -> Script: return preload("res://scripts/art/paper_hill137.gd")
func _rock_surfaces_script91() -> Script: return preload("res://scripts/art/rock_surfaces137.gd")
func _navigation_script72() -> Script: return preload("res://scripts/combat/woodland_navigation137.gd")
func _build_lab_floor() -> void:
 super._build_lab_floor()
 # Rebuild all four invisible boundary walls for the expanded geography.
 for node in get_children():
  if node is MeshInstance3D and node.mesh is BoxMesh and not node.visible:
   var size: Vector3=node.mesh.size
   if is_equal_approx(size.y,16.) and (size.x<.31 or size.z<.31): node.free()
 meadow=preload("res://scripts/world/world_surface137.gd").new()
 # The old track mesh continued invisibly behind the western mountain. Its
 # visible section begins at the actual tunnel mouth, beyond the new coast.
 meadow.rail_alignment73.x=meadow.portal_x73-.5
 var bounds: Rect2=meadow.world_bounds
 for x in [bounds.position.x,bounds.end.x]: _box(Vector3(x,5.,bounds.get_center().y),Vector3(.3,16.,bounds.size.y),Color.TRANSPARENT,true,false)
 for z in [bounds.position.y,bounds.end.y]: _box(Vector3(bounds.get_center().x,5.,z),Vector3(bounds.size.x,16.,.3),Color.TRANSPARENT,true,false)
func _build_woodland() -> void:
 super._build_woodland()
 var keep: Array[Dictionary]=[]
 for tree in trees:
  var p: Vector2=Vector2(tree.root.position.x,tree.root.position.z)-Vector2(meadow.landmarks.grove)
  var sight := p.x< -21. and p.x> -48. and p.y> -7. and p.y<8.
  var beyond_coast := p.x< -4. and p.y< -28.5
  if HILL137.clear137(p) or sight or beyond_coast or tree.root.position.y< -6.: tree.root.free();hill_removed_trees136+=1
  else: keep.append(tree)
 trees.assign(keep)
func _grass_growth92(at: Vector2) -> float:
 if meadow!=null and not meadow.landmarks.is_empty():
  var p: Vector2=at-Vector2(meadow.landmarks.grove)
  if meadow.height_at(at.x,at.y,true)<-6.: return 0.
  if HILL137.stair137(p).x<1.5: return 0.
  if HILL137.edge137(p)<-1.5: return .20
 return super._grass_growth92(at)
func _step_actor102(_actor: CharacterBody3D,_delta: float) -> void:
 # Entry and hill stairs now use continuous terrain collision, like the station.
 pass
func _ready() -> void:
 hill_visited136=true
 super._ready()
 while not hill_ready136: await get_tree().physics_frame
 vista136.hide()
 for lamp in lamps106.lamps106:
  var at: Vector2=Vector2(lamp.root.position.x,lamp.root.position.z)-Vector2(meadow.landmarks.grove)
  if at.distance_to(PARK99.DECK+Vector2(-1.3,-.5))<.3:
   var moved: Vector2=Vector2(meadow.landmarks.grove)+PARK99.DECK+Vector2(1.9,-.5)
   lamp.root.position=Vector3(moved.x,floor_height(moved),moved.y)
 for rock in forest87.rocks87:
  if HILL137.clear137(rock.at-Vector2(meadow.landmarks.grove)):
   rock.body.collision_layer=0;rock.visual.hide();rock.shadow.hide()
 for plant in forest87.plants87:
  if is_instance_valid(plant) and HILL137.clear137(Vector2(plant.position.x,plant.position.z)-Vector2(meadow.landmarks.grove)): plant.hide()
 coast137=preload("res://scripts/art/coastal_vista137.gd").new();coast137.world=self;add_child(coast137)
 _cliff_guard137()
 hill_ready137=true;_title35()
 if "--hill137" in OS.get_cmdline_user_args():
  _teleport15(Vector2(meadow.landmarks.grove)+Vector2(-7.8,1.8))
  encounter_hud.announce("通向海岬的小路","石阶下方是连续缓坡；沿转弯上山，F4可直达纸怪。",4.)
 print("PAPER_HILL137_READY ramp_treads=",park99.ramp_treads137," bounds=",meadow.world_bounds)
func _cliff_guard137() -> void:
 # The old rectangular map wall is gone. A narrow contour guard keeps casual
 # exploration on the grassy cliff lip and leaves the actual stair entrance open.
 cliff_guard137=StaticBody3D.new();cliff_guard137.name="GrassyCliffBoundary137";cliff_guard137.collision_layer=2;cliff_guard137.collision_mask=0
 var g: Vector2=meadow.landmarks.grove;cliff_guard137.position=Vector3(g.x,0.,g.y);add_child(cliff_guard137)
 var ring := PackedVector2Array()
 for i in 97:
  var direction := Vector2.from_angle(TAU*float(i%96)/96.)
  var low := 0.;var high := 24.
  for iteration in 16:
   var middle := (low+high)*.5
   if HILL137.edge137(HILL137.CENTER+direction*middle)<-.10: low=middle
   else: high=middle
  ring.append(HILL137.CENTER+direction*low)
 for i in 96:
  var a := ring[i];var b := ring[i+1];var midpoint := (a+b)*.5
  if HILL137.stair137(midpoint).x<2.4: continue
  var shape := BoxShape3D.new();shape.size=Vector3(a.distance_to(b)+.08,4.,.20)
  var collider := CollisionShape3D.new();collider.shape=shape;collider.position=Vector3(midpoint.x,HILL137.LEVEL+.9,midpoint.y)
  collider.rotation.y=atan2(-(b-a).y,(b-a).x);cliff_guard137.add_child(collider)
func _physics_process(delta: float) -> void:
 super._physics_process(delta)
 if is_instance_valid(vista136): vista136.hide()
 if not hill_ready137: return
 var p: Vector2=Vector2(hero.position.x,hero.position.z)-Vector2(meadow.landmarks.grove)
 if not hill_visited137 and (not active114 or not paper_trial129) and HILL137.edge137(p)<-1.8 and p.x< -18.:
  hill_visited137=true;paper_trial129=true;start_combat(false)
func start_combat(reposition := true) -> void:
 if not paper_trial129: super.start_combat(reposition);return
 super.start_combat(false)
 if reposition: _teleport15(Vector2(meadow.landmarks.grove)+HILL137.CENTER+Vector2(2.,4.))
 if hill_ready137: hill_visited137=true
func _spawn_wave110(index: int) -> void:
 if not paper_trial129: super._spawn_wave110(index);return
 for actor in reuse119:
  if is_instance_valid(actor): actor.queue_free()
 reuse119.clear();clear_standby119()
 for actor in enemies:
  if is_instance_valid(actor): remove_child(actor);actor.queue_free()
 enemies.clear();round_index=0;between_left=0.;_clear_combat_shots();packs114=1;created120=paper_count131
 var center: Vector2=Vector2(meadow.landmarks.grove)+HILL137.CENTER
 for i in paper_count131:
  var angle := TAU*float(i)/float(paper_count131)
  var at := center+Vector2(cos(angle)*4.6,sin(angle)*5.3)
  var actor := make_actor119(i,at);actor.home=center;enemies.append(actor);actor.play119()
 rebuild_cells110();target114=null;aim_tick114=-1
