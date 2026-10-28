extends "res://scripts/world/woodland_world140.gd"
const VIEW141 := Vector2(-25.7,-28.3)
var hill_ready141 := false
var coast141: Node3D
var view_weight141 := 0.
var camera_lift141 := 0.
var camera_basis141 := Basis.IDENTITY
var camera_basis_ready141 := false
var border_trees141 := 0
var cliff_stops141: StaticBody3D
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 141 · 山树围坪 / 苔石观景口 / 世界远海")
func _build_lab_floor() -> void:
 super._build_lab_floor();meadow=preload("res://scripts/world/world_surface141.gd").new()
func _park_script99() -> Script: return preload("res://scripts/art/paper_hill141.gd")
func _rock_surfaces_script91() -> Script: return preload("res://scripts/art/rock_surfaces141.gd")
func _build_woodland() -> void:
 super._build_woodland()
 var g: Vector2=meadow.landmarks.grove
 for spec in [Vector3(-30.5,-9.5,5.1),Vector3(-18.,-10.5,5.3),Vector3(-15.0,-13.0,5.8),Vector3(-15.3,-20.5,5.3),Vector3(-20.1,-28.4,4.6),Vector3(-19.0,-35.0,6.2)]:
  var at := g+Vector2(spec.x,spec.y);var nearby := false
  for tree in trees:
   if Vector2(tree.root.position.x,tree.root.position.z).distance_to(at)<1.9: nearby=true;break
  if not nearby:
   _add_route_tree(at,spec.z);trees[-1].root.set_meta("hill_border141",true);border_trees141+=1
func _grass_growth92(at: Vector2) -> float:
 var growth := super._grass_growth92(at)
 if meadow==null or meadow.landmarks.is_empty(): return growth
 var p: Vector2=at-Vector2(meadow.landmarks.grove)
 var view_radius := ((p-VIEW141)/Vector2(2.9,2.4)).length()
 return growth*smoothstep(.55,1.2,view_radius)
func _refresh_planting() -> void:
 super._refresh_planting()
 # The generic grove grass pass ends before the distant summit. Apply the
 # lookout clearing to these batches explicitly, with a soft mossy border.
 var g: Vector2=meadow.landmarks.grove
 for batch in grass_batches:
  for i in batch.points.size():
   var position3: Vector3=batch.points[i].origin
   var p := Vector2(position3.x,position3.z)-g
   var radius := ((p-VIEW141)/Vector2(2.9,2.4)).length()
   if radius>1.2: continue
   var pose: Transform3D=batch.node.multimesh.get_instance_transform(i)
   var grow := smoothstep(.65,1.2,radius)
   pose.basis=pose.basis.scaled(Vector3.ONE*grow) if grow>.08 else Basis(Vector3.ZERO,Vector3.ZERO,Vector3.ZERO)
   batch.node.multimesh.set_instance_transform(i,pose)
func _update_camera(delta: float,snap := false) -> void:
 if is_instance_valid(camera):
  camera.position.y-=camera_lift141
  if camera_basis_ready141: camera.basis=camera_basis141
 var target := 0.
 if is_instance_valid(hero) and meadow!=null and not meadow.landmarks.is_empty():
  var p: Vector2=Vector2(hero.position.x,hero.position.z)-Vector2(meadow.landmarks.grove)
  target=1.-smoothstep(1.8,5.,p.distance_to(VIEW141))
  # Do not pull the view away from a nearby enemy or an active shot.
  if fire_input_held(): target=0.
  for enemy in enemies:
   if is_instance_valid(enemy) and not enemy.dead and Vector2(enemy.position.x-hero.position.x,enemy.position.z-hero.position.z).length()<5.: target=0.;break
 view_weight141=target if snap else move_toward(view_weight141,target,delta*.38)
 var saved := camera_distance;camera_distance*=1.+.12*view_weight141
 super._update_camera(delta,snap);camera_distance=saved
 if not is_instance_valid(camera): return
 camera_basis141=camera.basis;camera_basis_ready141=true
 camera_lift141=.55*view_weight141;camera.position.y+=camera_lift141
 camera.basis=camera_basis141.rotated(Vector3.RIGHT,deg_to_rad(4.5)*view_weight141)
func _ready() -> void:
 super._ready()
 while not hill_ready140: await get_tree().physics_frame
 coast140.process_mode=Node.PROCESS_MODE_DISABLED;coast140.hide()
 coast141=preload("res://scripts/art/coastal_vista141.gd").new();coast141.world=self;add_child(coast141)
 # 140 relied on its enclosing fence to keep the trimmed, unused terrain out
 # of reach. With decorative rail gaps, the actual cliff contour must stop
 # walking as well; no new barrier crosses the meadow or the scenic opening.
 cliff_stops141=StaticBody3D.new();cliff_stops141.name="CliffEdgeStops141";cliff_stops141.collision_layer=2;cliff_stops141.collision_mask=0;add_child(cliff_stops141)
 var g: Vector2=meadow.landmarks.grove
 for i in coast_edge140.coastline140().size()-1:
  var a: Vector2=g+coast_edge140.coastline140()[i];var b: Vector2=g+coast_edge140.coastline140()[i+1]
  var parts := maxi(1,ceili(a.distance_to(b)/.75))
  for j in parts:
   var left := a.lerp(b,float(j)/parts);var right := a.lerp(b,float(j+1)/parts);var mid := (left+right)*.5
   var shape := BoxShape3D.new();shape.size=Vector3(.18,3.2,left.distance_to(right)+.22)
   var collider := CollisionShape3D.new();collider.shape=shape;collider.position=Vector3(mid.x,floor_height(mid)+1.1,mid.y)
   collider.rotation.y=atan2((right-left).x,(right-left).y);cliff_stops141.add_child(collider)
 hill_ready141=true;_title35()
 if "--hill141" in OS.get_cmdline_user_args(): _teleport15(Vector2(meadow.landmarks.grove)+Vector2(-7.8,1.8))
 print("PAPER_HILL141_READY rail_posts=",park99.fence_posts140," rail_spans=",park99.fence_spans140," border_trees=",border_trees141)
