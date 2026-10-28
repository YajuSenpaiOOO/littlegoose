extends "res://scripts/world/forest192_capture.gd"
class Walker199:
 extends "res://scripts/combat/hero192.gd"
 var command := Vector2.ZERO
 func movement_input() -> Vector2: return command if controls_enabled else Vector2.ZERO
class Trial199:
 extends "res://scripts/world/woodland_world199.gd"
 func _hero_script() -> Script: return Walker199
func world_script192() -> Script: return Trial199
func result_prefix192() -> String: return "forest199"
func extra_checks192() -> void:
 var rig: Node=sample.relations199
 verify(rig.cards.size()==10,"all eight forest lamps plus hammock tree and cat share the upright depth adapter")
 verify(rig.sight_trees199.size()>0 and rig.sight_trees199.size()<60,"regional path corridor removes a bounded set of foreground trees")
 var no_invisible_colliders := true
 for tree in rig.sight_trees199:
  for collision in tree.root.find_children("*","CollisionObject3D",true,false): no_invisible_colliders=no_invisible_colliders and collision.collision_layer==0
 verify(no_invisible_colliders,"sight corridor does not leave invisible solid trunks")
 var post: Sprite3D=rig.cards[0].sprite
 for gap in [.65,-.65]:
  sample._teleport15(Vector2(post.global_position.x,post.global_position.z+gap));await hour(12.);await picture("lamp_"+("front" if gap>0. else "behind"))
 var art: Node3D=sample.forest188
 for gap in [1.1,-1.1]:
  var at: Vector3=rig.root_feet199[0]
  sample._teleport15(Vector2(at.x,at.z+gap));await settle(100);await picture("root_"+("front" if gap>0. else "behind"))
 var root: StaticBody3D=art.trunk_bodies194[0]
 var shape: CylinderShape3D=root.get_child(0).shape
 verify(shape.radius>.4 and root.global_position.distance_to(rig.root_feet199[0]+Vector3.UP*.5)<.001,"paint-derived trunk feet and expanded physical footprints agree")
 var query := PhysicsRayQueryParameters3D.create(root.global_position+Vector3(0,0,1.2),root.global_position-Vector3(0,0,1.2),2)
 var hit: Dictionary=sample.get_world_3d().direct_space_state.intersect_ray(query)
 verify(not hit.is_empty() and hit.collider==root,"real physics ray meets the calibrated hammock trunk")
 sample._teleport15(Vector2(-4.7,6.));await hour(12.)
 var pair: Dictionary=rig.shadow_pairs[0]
 var ink: ShaderMaterial=pair.visual.material_override
 var saved: float=ink.get_shader_parameter("fade")
 ink.set_shader_parameter("fade",.1);rig._process(0.)
 verify(float(pair.shadow.material_override.get_shader_parameter("fade"))<.02,"hidden tree also fades its independent native shadow caster")
 ink.set_shader_parameter("fade",saved)
 sample._teleport15(art.PLAN.CENTER+Vector2(23.,3.));await settle(100);await picture("route_start")
 sample.hero.set_physics_process(true);sample.hero.controls_enabled=true
 var route: Array[Vector2]=[]
 for p in [Vector2(18.,3.),Vector2(14.,7.),Vector2(10.,8.),Vector2(6.,6.5)]: route.append(art.PLAN.CENTER+p)
 verify(await walk(sample,route),"player traverses cleared entrance corridor to central forest")
 sample.hero.command=Vector2.ZERO
 metrics.sight_tree_count=rig.sight_trees199.size();metrics.depth_cards=rig.cards.size()
