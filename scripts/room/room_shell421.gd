extends "res://scripts/room/room_shell400.gd"

const HOUSE := preload("res://scripts/room/cottage420.gd")

func build_shell() -> void:
 super.build_shell()
 var previous:=get_children()
 var source:=SurfaceTool.new()
 source.begin(Mesh.PRIMITIVE_TRIANGLES)
 for area in [HOUSE.HALL,HOUSE.LEFT,HOUSE.RIGHT]:
  for corner in [Vector2.ZERO,Vector2.RIGHT,Vector2.ONE,Vector2.ZERO,Vector2.ONE,Vector2.DOWN]:
   var point: Vector2=area.position+area.size*corner
   source.set_normal(Vector3.UP)
   source.set_uv(Vector2((point.x+6.15)/12.3,(point.y+3.8)/7.))
   source.add_vertex(Vector3(point.x,.006,point.y))
  collider(self,Vector3(area.get_center().x,-.14,area.get_center().y),Vector3(area.size.x,.28,area.size.y))
 floor391.mesh=source.commit()
 rug391.position.z=.16
 painted_rug_mesh391.size=Vector2(4.30,2.65)
 for node in previous:
  if node in [floor391,rug391,dressing393,garden393]:continue
  if node is Node3D:node.hide()
  if node is CollisionObject3D:node.collision_layer=0
  for body in node.find_children("*","CollisionObject3D",true,false):body.collision_layer=0
 # The curtain sits against the inside face of the real rear aperture.
 dressing393.position=Vector3(0,1.93,-3.605)
 dressing393.scale=Vector3.ONE*.67
 garden393.position=Vector3(0,1.87,-3.72)
 garden393.scale=Vector3(.65,.68,1.)
 for side in [-1.,1.]:
  var arch:=preload("res://scripts/room/timber_frame399.gd").new()
  arch.position=Vector3(side*3.,0,-.2)
  arch.rotation.y=PI*.5
  add_child(arch)
  var points: Array[Vector2]=[]
  for i in 25:
   var u:=lerpf(-1.82,1.82,i/24.)
   points.append(Vector2(u,2.30+.46*(1.-pow(u/1.82,2))))
  arch.beam399(points,.20,.26,0,"AlcoveArch421")
  for u in [-1.82,1.82]:
   arch.block399(Vector3(u,1.15,0),Vector3(.20,2.30,.26),"AlcovePost421")
   collider(self,Vector3(side*3.,1.15,-.2-u),Vector3(.26,2.30,.20))

func build_furniture() -> void:
 super.build_furniture()
 for node in get_children():
  if not node is MeshInstance3D or node.position.z > -3.98 or node.position.y < 2.4:continue
  if node.position.x < -2.:
   node.position.z+=1.76
   node.position.y-=.32
  elif node.position.x < 1.:
   node.hide()
 place("bed",Vector2(-4.60,-.87),Vector2(-4.58,1.17))
 place("bedside",Vector2(-3.39,-2.00),Vector2(-3.15,-1.43))
 place("desk",Vector2(0,-3.00),Vector2(.80,-1.63))
 place("desk_chair",Vector2(0,-1.82),Vector2(.76,-1.45))
 place("wardrobe",Vector2(4.58,-1.74),Vector2(4.51,-.52))
 place("wash",Vector2(5.26,.34),Vector2(4.30,.79))
 place("tea",Vector2(0,-.03),Vector2(0,1.15))
 place("tea_chair",Vector2(-1.21,-.15),Vector2(-1.23,.65))
 place("goose_stool",Vector2(1.19,.08),Vector2(1.23,.73))
 for row in furniture394:
  row.sprite.material_override.set_shader_parameter("foot394",row.sprite.global_position)

func place(id: String,at: Vector2,approach: Vector2) -> void:
 var row:=item356(id)
 if row.is_empty():return
 row.root.position=Vector3(at.x,row.root.position.y,at.y)
 row.at=at
 row.approach=approach

func build_hourglass() -> void:
 super.build_hourglass()
 var row:=item356("hourglass")
 row.root.hide()
 for body in row.root.find_children("*","CollisionObject3D",true,false):body.collision_layer=0
 footprints.erase(row)
