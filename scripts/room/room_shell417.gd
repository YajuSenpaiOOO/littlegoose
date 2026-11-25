extends "res://scripts/room/room_shell409.gd"
var arches417: Array=[]
func move417(id: String,at: Vector2,approach: Vector2) -> void:
 var row:=item356(id)
 if row.is_empty():return
 row.root.position.x=at.x;row.root.position.z=at.y;row.at=at;row.approach=approach
func build_furniture() -> void:
 super.build_furniture()
 foreground402.hide()
 for body in blockers402:body.collision_layer=0
 move417("bed",Vector2(-4.42,-1.50),Vector2(-3.5,.55))
 move417("bedside",Vector2(-5.35,-3.37),Vector2(-4.8,-2.8))
 move417("wardrobe",Vector2(4.55,-2.5),Vector2(3.35,-2.2))
 move417("wash",Vector2(5.0,.05),Vector2(3.65,.05))
 move417("desk",Vector2(-.40,-3.0),Vector2(-.40,-1.8))
 move417("desk_chair",Vector2(-.40,-1.85),Vector2(-.4,-1.2))
 move417("tea",Vector2(0,.35),Vector2(0,1.65))
 move417("tea_chair",Vector2(-1.35,.35),Vector2(-1.4,1.0))
 move417("goose_stool",Vector2(1.35,.35),Vector2(1.4,1.0))
 for row in furniture394:row.sprite.material_override.set_shader_parameter("foot394",row.sprite.global_position)
 var floor_mesh:=SurfaceTool.new();floor_mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
 for area in [Rect2(-3.0,-3.96,6.0,6.39),Rect2(-5.9,-3.68,2.9,5.23),Rect2(3.0,-3.68,2.9,5.23)]:
  var a:=Vector3(area.position.x,0,area.position.y);var b:=Vector3(area.end.x,0,area.position.y);var c:=Vector3(area.end.x,0,area.end.y);var d:=Vector3(area.position.x,0,area.end.y)
  for p in [a,b,c,a,c,d]:floor_mesh.set_normal(Vector3.UP);floor_mesh.set_uv(Vector2((p.x+5.9)/11.8,(p.z+3.96)/6.39));floor_mesh.add_vertex(p)
 floor391.mesh=floor_mesh.commit();floor391.position=Vector3(0,.005,0);floor391.scale=Vector3.ONE
 for saved in shell_state402:
  if saved.has("mesh") and saved.node.position.y<0 and saved.mesh.size.x>11.:saved.node.hide()
 box(self,Vector3(0,-.18,-.765),Vector3(6.0,.34,6.39),"73513b")
 for side in [-1.,1.]:
  box(self,Vector3(side*4.45,-.18,-1.065),Vector3(2.9,.34,5.23),"73513b")
  collider(self,Vector3(side*4.45,1.7,-3.72),Vector3(2.9,3.4,.15))
 for side in [-1.,1.]:
  var trim:=preload("res://scripts/room/timber_frame399.gd").new();add_child(trim);trim.position=Vector3(side*3.0,0,-.65);trim.rotation.y=PI*.5
  var cut:=Shader.new()
  cut.code=trim.wood399.shader.code.replace("void fragment(){","varying vec3 cut417;\nvoid vertex(){cut417=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}\nvoid fragment(){if(cut417.z>.35 && cut417.y>.75)discard;")
  trim.wood399.shader=cut
  var points: Array[Vector2]=[]
  for i in 33:
   var u: float=-1.65+3.3*i/32.;points.append(Vector2(u,3.25+.52*(1.-pow(u/1.65,2.))))
  trim.beam399(points,.24,.30,0,"OpenSideArch417");arches417.append(trim)
  for z in [-2.3,1.0]:
   trim.block399(Vector3(-z-.65,1.62,0),Vector3(.24,3.24,.30),"ArchPost417")
   collider(self,Vector3(side*3.0,1.62,z),Vector3(.30,3.24,.24))
  # Low fronts show the dollhouse boundary without hiding the furnished alcoves.
  box(self,Vector3(side*4.5,.32,1.55),Vector3(2.8,.64,.18),"d8c8a5")
  box(self,Vector3(side*4.5,.67,1.55),Vector3(2.9,.10,.25),"72573d")
func build_hourglass() -> void:
 super.build_hourglass()
 var row:=item356("hourglass")
 if not row.is_empty():
  row.root.hide()
  for body in row.root.find_children("*","CollisionObject3D",true,false):body.collision_layer=0
  footprints.erase(row)
