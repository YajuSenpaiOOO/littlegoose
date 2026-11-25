extends "res://scripts/room/cottage425.gd"

var step_bodies: Array[StaticBody3D]=[]
var wood_colliders: Array[StaticBody3D]=[]

func build_entry() -> void:
 super.build_entry()
 # Restore the original stone blocks, with a vertical riser and a flat tread.
 var old:=terrace.get_child(terrace.get_child_count()-1)
 old.free()
 stairs=null
 for row in 2:
  var top:=-.11 if row==0 else 0.
  var depth:=.58 if row==0 else 1.22
  var center_z:=4.07 if row==0 else 3.41
  for column in 5:
   block(terrace,Vector3((column-2)*.48,(top-.224)*.5,center_z),Vector3(.467,top+.224,depth),stone)
  # One continuous shape across the mortar lines. Overlap the upper block
  # with the sill rather than leaving a crack at the room-floor edge.
  var node:=block(terrace,Vector3(0,(top-.224)*.5,center_z),Vector3(2.40,top+.224,depth),stone,true)
  node.hide()
  step_bodies.append(node.get_child(0))

func stair_top(z: float) -> float:
 if z<=4.02:return 0.
 if z<=4.36:return -.11
 return -.22

func _ready() -> void:
 super._ready()
 # Match projecting posts, stone sockets, window boxes, and low trim to
 # their own mesh extents. Roof beams retain their overhead clearance.
 for node in shell.find_children("*","MeshInstance3D",true,false):
  if not node.mesh is BoxMesh or not node.get_children().is_empty():continue
  if pivot.is_ancestor_of(node):continue
  var at: Vector3=to_local(node.global_position)
  var size: Vector3=node.mesh.size
  var front_detail: bool=at.z>2.15 and absf(at.x)>1.14
  if not front_detail or at.y-size.y*.5>1.65 or size.x<.12 or size.z<.14:continue
  if node.material_override!=wood and node.material_override!=stone:continue
  node.create_trimesh_collision()
  var body: StaticBody3D=node.get_child(0)
  wood_colliders.append(body)

func try_step(actor: CharacterBody3D,delta: float,requested: Vector2=Vector2.ZERO) -> bool:
 var motion:=Vector3(actor.velocity.x,0,actor.velocity.z)*delta
 if requested!=Vector2.ZERO:motion=Vector3(requested.x,0,requested.y)*2.4*delta
 var p:=to_local(actor.global_position)
 if absf(p.x)>.99 or p.z<3.6 or p.z>4.67 or motion.z>=-.002:return false
 motion=motion.limit_length(.12)
 var collision:=KinematicCollision3D.new()
 if not actor.test_move(actor.global_transform,motion,collision):return false
 if not collision.get_collider() in step_bodies:return false
 # Look beyond the capsule's nose so the landing probe sees the top of
 # the block instead of the vertical riser. Cast the body at tread height.
 var landing:=actor.global_position+motion.normalized()*.285
 var query:=PhysicsRayQueryParameters3D.create(landing+Vector3.UP*.16,landing-Vector3.UP*.055,1)
 var hit:=get_world_3d().direct_space_state.intersect_ray(query)
 if not hit.get("collider") in step_bodies:return false
 var lift: float=hit.position.y-actor.global_position.y+.002
 if lift<.04 or lift>.145:return false
 var up:=Vector3.UP*lift
 if actor.test_move(actor.global_transform,up):return false
 var raised:=actor.global_transform.translated(up)
 if actor.test_move(raised,motion):return false
 actor.global_position+=motion+up
 return true
