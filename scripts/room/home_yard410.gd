extends "res://scripts/room/home_yard404.gd"
var walls410: Array=[]
func house_scale410() -> Vector3:return Vector3.ONE*.68
func build403(room: Node3D) -> void:
 build_house404(room)
 # The original continuous lower timber crossed the open doorway visually.
 for node in facade403.get_children():
  if node is MeshInstance3D and node.mesh is BoxMesh and is_equal_approx(node.position.y,.88) and node.mesh.size.x>13.:
   node.hide()
   for side in [-1.,1.]:part404(facade403,Vector3(side*3.825,.88,3.075),Vector3(5.45,.17,.20),node.material_override)
 scale=house_scale410()
 position.z=2.43-2.88*scale.z
 door404.sync_to_physics=false
 for side in [-1.,1.]:
  walls410.append(room.collider(self,Vector3(side*3.8,1.78,2.88),Vector3(5.45,3.56,.20)))
  walls410.append(room.collider(self,Vector3(side*6.51,1.8,-.93),Vector3(.16,3.6,7.76)))
 walls410.append(room.collider(self,Vector3(0,1.8,-4.76),Vector3(13.1,3.6,.18)))
 # A continuous physical sill supports the actor between the map ramp and wood.
 room.collider(self,Vector3(0,-.08,2.9),Vector3(2.1,.16,.7))
 # Bridge the old yard's raised terrain edge with a visible shallow stone ramp.
 # Coordinates below are host-space, converted into the scaled house space.
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for p in [Vector3(-.72,.008,2.20),Vector3(-.72,-.107,6.20),Vector3(.72,.008,2.20),Vector3(.72,.008,2.20),Vector3(-.72,-.107,6.20),Vector3(.72,-.107,6.20)]:
  st.set_normal(Vector3.UP);st.set_uv(Vector2(p.x,p.z));st.add_vertex((p-position)/scale)
 var ramp: Mesh=st.commit()
 var ink: StandardMaterial3D=room.material("aaa796").duplicate();ink.albedo_texture=preload("res://assets/garden45/slate.png");ink.cull_mode=BaseMaterial3D.CULL_DISABLED
 room.shape(self,ramp,Vector3.ZERO,ink).cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var body:=StaticBody3D.new();add_child(body)
 var collision:=CollisionShape3D.new();collision.shape=ramp.create_trimesh_shape();collision.shape.backface_collision=true;body.add_child(collision)
