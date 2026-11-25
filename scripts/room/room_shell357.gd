extends "res://scripts/room/room_shell356.gd"
var solid357: Node3D
var use_solid357:=true
var atlas357: Texture2D
var surfaces357: Array[MeshInstance3D]=[]
func build_furniture() -> void:
 super.build_furniture()
 var row:=item356("wardrobe")
 solid357=Node3D.new();solid357.name="PaintedSolidWardrobe";row.root.add_child(solid357)
 # Geometry is aligned to the room, with actual top and side faces. Collision stays unchanged.
 textured_box357(Vector3(0.,1.36,0.),Vector3(1.42,2.12,1.12),Vector2i(0,1))
 textured_box357(Vector3(0.,.34,.58),Vector3(1.36,.36,.08),Vector2i(1,0))
 textured_box357(Vector3(0.,1.47,.58),Vector3(1.32,1.82,.08),Vector2i(0,0))
 for x in [-.59,.59]:
  for z in [-.45,.45]:textured_box357(Vector3(x,.13,z),Vector3(.16,.26,.16),Vector2i(0,1))
 for y in [.54,2.40]:textured_box357(Vector3(0.,y,0.),Vector3(1.5,.09,1.2),Vector2i(1,1))
 # Continuous cornice: no repeated strips or stepped arch seams across the top.
 textured_box357(Vector3(0.,2.49,0.),Vector3(1.5,.10,1.2),Vector2i(1,1))
 textured_box357(Vector3(0.,2.57,0.),Vector3(1.4,.06,1.12),Vector2i(1,1))
 set_art356(true)
func texture_material357(tile: Vector2i) -> StandardMaterial3D:
 var m:=StandardMaterial3D.new()
 if atlas357==null:atlas357=source356("res://assets/room357/wardrobe_atlas.png")
 m.albedo_texture=atlas357
 m.uv1_scale=Vector3(.496,.496,1.)
 m.uv1_offset=Vector3(float(tile.x)*.5+.002,float(tile.y)*.5+.002,0.)
 m.albedo_color=Color(.72,.72,.72,1.)
 m.cull_mode=BaseMaterial3D.CULL_DISABLED
 m.roughness=.9;m.metallic_specular=.15
 m.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
 return m
func textured_box357(at: Vector3,size: Vector3,tile: Vector2i) -> void:
 var mesh:=SurfaceTool.new();mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
 # Explicit per-face UVs: BoxMesh's packed UV layout cannot sample a whole atlas tile.
 for face in [[Vector3.RIGHT,Vector3.BACK,Vector3.UP],[Vector3.LEFT,Vector3.FORWARD,Vector3.UP],[Vector3.UP,Vector3.RIGHT,Vector3.FORWARD],[Vector3.DOWN,Vector3.RIGHT,Vector3.BACK],[Vector3.BACK,Vector3.RIGHT,Vector3.UP],[Vector3.FORWARD,Vector3.LEFT,Vector3.UP]]:
  var normal: Vector3=face[0];var u: Vector3=face[1];var v: Vector3=face[2]
  for index in [0,2,1,0,3,2]:
   var uv: Vector2=[Vector2(0,1),Vector2(1,1),Vector2(1,0),Vector2(0,0)][index]
   var vertex: Vector3=(normal+u*(uv.x*2.-1.)+v*(1.-uv.y*2.))*size*.5
   mesh.set_normal(normal);mesh.set_uv(uv);mesh.add_vertex(vertex)
 var n:=shape(solid357,mesh.commit(),at,texture_material357(tile));surfaces357.append(n)

func set_art356(value: bool) -> void:
 super.set_art356(value)
 if not is_instance_valid(solid357):return
 solid357.visible=value and use_solid357
 for row in cards356:
  if row.id=="wardrobe" and value:
   row.sprite.visible=not use_solid357;row.shadow.visible=not use_solid357
func toggle357() -> void:
 use_solid357=not use_solid357;set_art356(true)
