extends "res://scripts/world/paper_hill144_probe.gd"
class Current145:
 extends "res://scripts/world/woodland_world145.gd"
 func _hero_script() -> Script: return Walker143
 func fire_input_held() -> bool: return false
 func hurt_player(_damage: float,_at: Vector2) -> void: pass
func shot145(s: Node3D,p: Vector2,tag: String) -> void:
 s.hero.wish=Vector2.ZERO;s._teleport15(p);await settle72(35)
 var picture := await snapshot();picture.save_png("res://docs/captures/world_restart/paper_hill145_%s.png"%tag)
func run() -> void:
 root.size=Vector2i(1600,1000)
 var s := Current145.new();s.memory_save116="user://hill145_probe_tmp.cfg";root.add_child(s)
 while not s.hill_ready145: await physics_frame
 s.hill_visited136=true;s.hero.controls_enabled=true;s.combat_paused=false;disable_enemies(s);await settle72(5)
 var g: Vector2=s.meadow.landmarks.grove
 verify(s.hill_plants142.shrub_bodies143.is_empty(),"soft summit fronds no longer create blocking bodies")
 var fern: MultiMeshInstance3D;var contact := Vector2.ZERO
 for batch in s.hill_plants142.batches107:
  if not batch.material_override.shader.code.contains("reactive94"): continue
  for i in batch.multimesh.instance_count:
   var pose: Transform3D=batch.multimesh.get_instance_transform(i)
   if pose.basis.y.length()<.1 or s.picnic144.in_cloth144(pose.origin): continue
   contact=Vector2(pose.origin.x,pose.origin.z);fern=batch;break
  if fern!=null: break
 s._teleport15(contact-Vector2(.8,0));await settle72(5)
 verify(await walk139(s,contact+Vector2(.8,0)),"actual movement passes straight through a summit fern cluster")
 s._teleport15(contact+Vector2(.3,0));await settle72(5)
 verify(fern.material_override.get_shader_parameter("field94")==true and fern.material_override.get_shader_parameter("reactive94")==true and Vector3(fern.material_override.get_shader_parameter("walker")).distance_to(s.hero.global_position)<.15,"fronds receive live player position and retain the shared push and recovery shader")
 await shot145(s,contact+Vector2(.3,0),"brush")
 s.time55.preview_at(12.);s.time55.visual_hour=12.;s.time55.apply_look()
 await settle72(8)
 var registry: Node=s.prop_shadows145;var present := true;var single := true
 for sprite in [s.picnic144.basket144,s.picnic144.floor_lamp144,s.picnic144.branch_lamp144]:
  present=present and registry.registered145.has(sprite.get_instance_id())
  var count := 0
  for projector in get_nodes_in_group("painted_prop_projectors"):
   if projector.visual==sprite: count+=1
  single=single and count==1
 verify(present and single,"basket, ground lamp and pole lamp each register exactly one projected silhouette")
 var shadow: MeshInstance3D=registry.registered145[s.picnic144.basket144.get_instance_id()]
 var raised := 0
 var vertices: PackedVector3Array=shadow.mesh.surface_get_arrays(0)[Mesh.ARRAY_VERTEX]
 for point in vertices:
  var at: Vector3=shadow.to_global(point)
  if s.picnic144.in_cloth144(at,0.):
   if at.y-s.floor_height(Vector2(at.x,at.z))>.06: raised+=1
 verify(raised>10,"basket shadow receiver sits above the blanket instead of under it")
 var extra: Sprite3D=s.forest87._sprite87(s.picnic144.basket144.texture,g+Vector2(-19.,-27.),.3,"AutomaticShadowProbe145")
 var id := extra.get_instance_id();await settle72(4)
 verify(registry.registered145.has(id),"new solid props from the standard factory acquire shadows without manual projector wiring")
 extra.queue_free();await settle72(4)
 verify(not registry.registered145.has(id),"temporary prop removal also removes its registered silhouette")
 var normal_distance: float=s.camera_distance;s.camera_distance=10.
 await shot145(s,g+s.picnic144.PICNIC144+Vector2(-1.8,1.45),"picnic_shadow")
 await shot145(s,g+s.picnic144.ENTRY144+Vector2(.8,1.3),"pole_shadow")
 s.time55.preview_at(16.);s.time55.visual_hour=16.;s.time55.apply_look()
 await shot145(s,g+s.picnic144.PICNIC144+Vector2(-1.8,1.45),"picnic_afternoon")
 s.camera_distance=normal_distance
 await shot145(s,g+Vector2(-31,-17),"coast_afternoon")
 var preview: Sprite3D=preload("res://scripts/art/paper_scraps145.gd").sprite145(.55)
 s.add_child(preview);preview.position=s.picnic144.point144(s.picnic144.PICNIC144+Vector2(-.8,.5),.07)
 verify(preview.texture!=null and preview.alpha_scissor_threshold>.8,"paper material art loads with a crisp transparent in-game silhouette")
 s.time55.preview_at(12.);s.time55.visual_hour=12.;s.time55.apply_look();s.camera_distance=8.
 await shot145(s,g+s.picnic144.PICNIC144+Vector2(-1.7,1.45),"paper_art_preview")
 preview.queue_free()
 FileAccess.open("res://docs/paper-hill145-validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"cloth_shadow_vertices":raised,"registered_solid_props":registry.registered145.size()},"\t"))
 DirAccess.remove_absolute(ProjectSettings.globalize_path(s.memory_save116));print("PAPER_HILL145_DONE ",JSON.stringify({"checks":checks,"failures":failures}));quit(0 if failures.is_empty() else 1)
