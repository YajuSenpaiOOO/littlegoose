extends "res://scripts/world/woodland_world136.gd"
var hill_ready139 := false
var coast139: Node3D
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 139 · 基于136 / 局部扩坪 / 封底石阶")
func _build_lab_floor() -> void:
 super._build_lab_floor();meadow=preload("res://scripts/world/world_surface139.gd").new()
func _park_script99() -> Script: return preload("res://scripts/art/paper_hill139.gd")
func _step_actor102(actor: CharacterBody3D,delta: float) -> void:
 var p: Vector2=Vector2(actor.position.x,actor.position.z)-Vector2(meadow.landmarks.grove)
 if is_instance_valid(park99) and park99.stair_piece139(p): return
 super._step_actor102(actor,delta)
func _ready() -> void:
 super._ready()
 while not hill_ready136: await get_tree().physics_frame
 vista136.hide()
 # Open only the small west-edge window used by the local extension. Bounds,
 # chunk origins, the station and all other terrain remain identical to 136.
 var bounds: Rect2=meadow.world_bounds;var g: Vector2=meadow.landmarks.grove
 for node in get_children():
  if node is MeshInstance3D and node.mesh is BoxMesh and not node.visible and absf(node.position.x-bounds.position.x)<.02:
   var size: Vector3=node.mesh.size
   if size.x<.31 and is_equal_approx(size.y,16.): node.queue_free()
 var north := g.y-26.;var south := g.y-5.;var west := bounds.position.x-5.2
 _box(Vector3(bounds.position.x,5.,(bounds.position.y+north)*.5),Vector3(.3,16.,north-bounds.position.y),Color.TRANSPARENT,true,false)
 _box(Vector3(bounds.position.x,5.,(south+bounds.end.y)*.5),Vector3(.3,16.,bounds.end.y-south),Color.TRANSPARENT,true,false)
 _box(Vector3(west,5.,(north+south)*.5),Vector3(.3,16.,south-north),Color.TRANSPARENT,true,false)
 for z in [north,south]: _box(Vector3((west+bounds.position.x)*.5,5.,z),Vector3(5.2,16.,.3),Color.TRANSPARENT,true,false)
 for lamp in lamps106.lamps106:
  var p: Vector2=Vector2(lamp.root.position.x,lamp.root.position.z)-g
  if p.distance_to(PARK99.DECK+Vector2(-1.3,-.5))<.3:
   var at: Vector2=g+PARK99.DECK+Vector2(1.9,-.5);lamp.root.position=Vector3(at.x,floor_height(at),at.y)
 coast139=preload("res://scripts/art/coastal_vista139.gd").new();coast139.world=self;add_child(coast139)
 hill_ready139=true;_title35()
 if "--hill139" in OS.get_cmdline_user_args(): _teleport15(g+Vector2(-7.8,1.8))
 print("PAPER_HILL139_READY closed_bases=",park99.closed_bases139," bounds=",meadow.world_bounds)
func _physics_process(delta: float) -> void:
 super._physics_process(delta)
 if is_instance_valid(vista136): vista136.hide()
