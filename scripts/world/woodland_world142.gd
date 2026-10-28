extends "res://scripts/world/woodland_world141.gd"
const PLAN142=preload("res://scripts/world/hill_layout142.gd")
var hill_ready142 := false
var hill_plants142: Node3D
var relocated_trees142 := 0
var stair_tree_clear142 := 0
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 142 · 山树分区 / 泥土观景口 / 草甸疏密")
func _build_lab_floor() -> void:
 super._build_lab_floor();meadow=preload("res://scripts/world/world_surface142.gd").new()
func _hero_script() -> Script: return preload("res://scripts/combat/hero142.gd")
func _park_script99() -> Script: return preload("res://scripts/art/paper_hill142.gd")
func _rock_surfaces_script91() -> Script: return preload("res://scripts/art/rock_surfaces142.gd")
func tree_bad142(p: Vector2) -> bool:
 if p.x> -5. or p.x< -36. or p.y>3. or p.y< -37.: return false
 var old_stair := PARK99.to_stair99(p)
 return (HILL136.stair136(p).x<3.0) or (absf(old_stair.x-PARK99.STAIR_X)<2.7 and old_stair.y>PARK99.STAIR_TOP-.6 and old_stair.y<PARK99.STAIR_FOOT+.7) or PLAN142.west_radius(p)<1.3 or (p-Vector2(-17.4,-22.2)).length()<4.5
func _build_woodland() -> void:
 super._build_woodland()
 var g: Vector2=meadow.landmarks.grove;var keep: Array[Dictionary]=[]
 for tree in trees:
  var p := Vector2(tree.root.position.x,tree.root.position.z)-g
  if tree.root.has_meta("hill_border141") or tree_bad142(p):
   tree.root.free();stair_tree_clear142+=1
  else: keep.append(tree)
 trees.assign(keep)
 for spec in PLAN142.GROVES:
  _add_route_tree(g+Vector2(spec.x,spec.y),spec.z);trees[-1].root.set_meta("grove142",true);relocated_trees142+=1
func _refresh_planting() -> void:
 super._refresh_planting()
 var g: Vector2=meadow.landmarks.grove
 for batch in grass_batches:
  for i in batch.points.size():
   var origin: Vector3=batch.points[i].origin;var p := Vector2(origin.x,origin.z)-g
   if HILL140.radius140(p)>1.06: continue
   var pose: Transform3D=batch.node.multimesh.get_instance_transform(i)
   var field := .5+.5*sin(p.x*.73+p.y*.41)*sin(p.y*.57-p.x*.21)
   var grow := lerpf(.25,1.15,smoothstep(.28,.78,field))
   grow*=smoothstep(.35,1.1,PLAN142.path_distance(p))*smoothstep(.65,1.2,PLAN142.view_radius(p))
   pose.basis=pose.basis.scaled(Vector3.ONE*grow) if grow>.12 else Basis(Vector3.ZERO,Vector3.ZERO,Vector3.ZERO)
   batch.node.multimesh.set_instance_transform(i,pose)
func _ready() -> void:
 super._ready()
 while not hill_ready141: await get_tree().physics_frame
 hill_plants142=_hill_plants_script142().new();hill_plants142.world=self;add_child(hill_plants142)
 hill_ready142=true;_title35()
 if "--hill142" in OS.get_cmdline_user_args(): _teleport15(Vector2(meadow.landmarks.grove)+Vector2(-7.8,1.8))
 print("PAPER_HILL142_READY trees=",relocated_trees142," cleared=",stair_tree_clear142," pockets=",hill_plants142.clusters142," ferns=",hill_plants142.fern_count107)

func _hill_plants_script142() -> Script: return preload("res://scripts/art/hill_plants142.gd")
