extends "res://scripts/world/woodland_world142.gd"
var hill_ready143 := false
var breeze143: Node3D
var painted_rocks143 := 0
func _title35() -> void: DisplayServer.window_set_title("小白鹅 · 143 · 海岸收尾 / 苔石碰撞 / 海风")
func _park_script99() -> Script: return preload("res://scripts/art/paper_hill143.gd")
func _coastal_edge_script140() -> Script: return preload("res://scripts/art/coastal_edge143.gd")
func _hill_plants_script142() -> Script: return preload("res://scripts/art/hill_plants143.gd")
func _ready() -> void:
 super._ready()
 while not hill_ready142: await get_tree().physics_frame
 var g: Vector2=meadow.landmarks.grove
 var contacts := SurfaceTool.new();contacts.begin(Mesh.PRIMITIVE_TRIANGLES)
 # Trim the exposed old rail end; preserve the station and eastern track.
 for _pass in 3: rail72.rail_mesh72.mesh=coast_edge140.clipped140(rail72.rail_mesh72.mesh)
 var before: int=forest87.rocks87.size()
 for spec in [Vector4(-14.5,-28.5,1.15,0),Vector4(-12.6,-29.7,.95,2),Vector4(-15.,-30.,1.05,1),Vector4(-22.8,-29.4,1.3,2),Vector4(-29.2,-27.8,1.1,0)]:
  forest87._rock87(g+Vector2(spec.x,spec.y),spec.z,int(spec.w),contacts)
 painted_rocks143=forest87.rocks87.size()-before
 var contact_mesh := contacts.commit()
 if contact_mesh!=null:
  var node := MeshInstance3D.new();node.mesh=contact_mesh;node.material_override=forest87.contact_material87;node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;forest87.add_child(node)
 # Remove decoration roots on the newly trimmed, inaccessible northern buffer.
 for tree in trees:
  if coast_edge140.score140(tree.root.global_position)<.15: tree.root.hide()
 for rock in forest87.rocks87:
  if coast_edge140.score140(rock.visual.global_position)<.15: rock.visual.hide();rock.body.collision_layer=0;rock.shadow.enabled=false
 for plant in forest87.plants87:
  if coast_edge140.score140(plant.global_position)<.15: plant.hide()
 for batch in grass_batches:
  for i in batch.node.multimesh.instance_count:
   var pose: Transform3D=batch.node.multimesh.get_instance_transform(i)
   if coast_edge140.score140(batch.node.to_global(pose.origin))<.02:
    pose.basis=Basis(Vector3.ZERO,Vector3.ZERO,Vector3.ZERO);batch.node.multimesh.set_instance_transform(i,pose)
 breeze143=preload("res://scripts/art/coastal_breeze143.gd").new();breeze143.world=self;add_child(breeze143)
 hill_ready143=true;_title35()
 if "--hill143" in OS.get_cmdline_user_args(): _teleport15(g+Vector2(-7.8,1.8))
 print("PAPER_HILL143_READY painted_rocks=",painted_rocks143," shrub_colliders=",hill_plants142.shrub_bodies143.size())
