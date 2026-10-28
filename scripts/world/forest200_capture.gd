extends "res://scripts/world/forest192_capture.gd"
class Walker200:
 extends "res://scripts/combat/hero192.gd"
 var command := Vector2.ZERO
 func movement_input() -> Vector2: return command if controls_enabled else Vector2.ZERO
class Trial200:
 extends "res://scripts/world/woodland_world200.gd"
 func _hero_script() -> Script: return Walker200
func world_script192() -> Script: return Trial200
func result_prefix192() -> String: return "forest200"
func extra_checks192() -> void:
 var fade: RefCounted=sample.whole67;var rig: Node=sample.relations199
 verify(rig.sight_trees199.is_empty(),"199 static tree removal disabled while depth and root fixes remain")
 verify(rig.cards.size()==10,"forest lamp and hammock depth fixes preserved")
 sample._teleport15(sample.forest188.PLAN.CENTER+Vector2(18.,3.));await hour(12.);await settle(100)
 var opaque := 0;var active := 0;var solids := 0
 for tree in sample.trees:
  if tree.root.is_visible_in_tree(): opaque+=1
  for body in tree.root.find_children("*","CollisionObject3D",true,false):
   if body.collision_layer!=0: solids+=1
 for entry in fade.entries.values():
  if entry.opacity<.5: active+=1
 verify(opaque>500 and solids>500,"ordinary tree nodes and physical trunks remain present")
 verify(active>0,"forest approach exercises actual dynamic tree fading")
 await picture("approach")
 var saved_layers := {}
 for body in sample.find_children("*","CollisionObject3D",true,false): saved_layers[body.get_instance_id()]=body.collision_layer
 sample.hero.velocity=Vector3(0,0,2.);await settle(35);await picture("south")
 sample.hero.velocity=Vector3.ZERO;await settle(15);await picture("stop")
 var stable := true
 for body in sample.find_children("*","CollisionObject3D",true,false):
  if saved_layers.has(body.get_instance_id()): stable=stable and body.collision_layer==saved_layers[body.get_instance_id()]
 verify(stable,"movement and fade scans never change physical collision layers")
 var theme := 0
 for entry in fade.entries.values():
  if entry.get("extra200",false): theme+=1
 verify(theme>10,"theme perimeter trees join the same occlusion scan")
 # A real rendered billboard fixture catches CPU-vs-render-plane mismatch.
 var probe := Sprite3D.new();var image := Image.create(2,2,false,Image.FORMAT_RGBA8);image.fill(Color.WHITE)
 probe.texture=ImageTexture.create_from_image(image);probe.pixel_size=1.;probe.billboard=BaseMaterial3D.BILLBOARD_ENABLED
 sample.add_child(probe);probe.global_position=sample.hero.global_position+sample.camera.global_basis.z*2.+Vector3.UP
 var centre: Vector2=sample.camera.unproject_position(probe.global_position)
 verify(fade.hit200(probe,centre,100.),"rendered billboard plane and alpha hit agree")
 verify(not fade.hit200(probe,centre,.01),"foreground test rejects hits outside requested camera depth")
 var ink := ShaderMaterial.new();ink.shader=preload("res://scripts/art/forest_cutout186.gdshader");ink.set_shader_parameter("paint",probe.texture);probe.material_override=ink
 probe.pixel_size=20.;probe.global_position=sample.camera.global_position-sample.camera.global_basis.z*3.
 sample.trees.append({"visual":probe});fade._scan()
 verify(fade.entries[probe.get_instance_id()].near76 and fade.entries[probe.get_instance_id()].target,"full-screen near canopy independently triggers fade instead of waiting for trunk overlap")
 sample.trees.pop_back();fade.entries.erase(probe.get_instance_id())
 probe.queue_free()
 sample.hero.set_physics_process(true);sample.hero.controls_enabled=true;sample.hero.velocity=Vector3.ZERO
 sample._teleport15(sample.forest188.PLAN.CENTER+Vector2(33.,-3.));await settle(30)
 var route: Array[Vector2]=[]
 for p in [Vector2(28.,-3.),Vector2(23.,3.),Vector2(18.,3.),Vector2(14.,7.),Vector2(10.,8.),Vector2(6.,6.5)]: route.append(sample.forest188.PLAN.CENTER+p)
 verify(await walk(sample,route),"restored physical trees leave the actual entrance route walkable")
 sample.hero.command=Vector2.ZERO
 metrics.visible_tree_nodes=opaque;metrics.solid_trunks=solids;metrics.faded_trees=active;metrics.theme_tree_entries=theme
