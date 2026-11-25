extends "res://scripts/room/cottage427.gd"

var stone_palette: Array[StandardMaterial3D]=[]
var stone_blocks:=0
var ceramics: Array[MeshInstance3D]=[]

func apply_facade427() -> void:
 # The broad original plaster is the quiet backdrop in design A.
 pass

func stone_tint(index: int) -> StandardMaterial3D:
 if stone_palette.is_empty():
  for tint in ["bdb5a3","afa797","c6bead","aaa694","b1ad97"]:
   var ink:=stone.duplicate() as StandardMaterial3D
   ink.albedo_color=Color(tint)
   stone_palette.append(ink)
 return stone_palette[posmod(index,stone_palette.size())]

func base_course(x0: float,x1: float,z: float) -> void:
 block(shell,Vector3((x0+x1)*.5,.29,z),Vector3(x1-x0,.58,.35),color("746a5c"))
 for row in 2:
  var count:=ceili((x1-x0)/.73)+row
  var span:=(x1-x0)/count
  for i in count:
   var center:=x0+(i+.5)*span
   var at:=Vector3(center,.153+row*.279,z+.115)
   var depth:=.224+.013*sin(i*3.8+row)
   bevel_block(at,Vector3(span-.023,.268,depth),stone_tint(i+row*2+int(absf(center))))
   stone_blocks+=1

func bevel_block(at: Vector3,size: Vector3,ink: Material) -> void:
 var st:=SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var h:=Vector2(size.x,size.y)*.5
 var bevel:=.038
 var rim: Array[Vector2]=[
  Vector2(-h.x+bevel,-h.y),Vector2(h.x-bevel,-h.y),Vector2(h.x,-h.y+bevel),Vector2(h.x,h.y-bevel),
  Vector2(h.x-bevel,h.y),Vector2(-h.x+bevel,h.y),Vector2(-h.x,h.y-bevel),Vector2(-h.x,-h.y+bevel)
 ]
 for i in rim.size():
  var j: int=(i+1)%rim.size()
  var a:=Vector3(rim[i].x*.90,rim[i].y*.77,size.z*.52)
  var b:=Vector3(rim[j].x*.90,rim[j].y*.77,size.z*.52)
  var c:=Vector3(rim[i].x,rim[i].y,size.z*.32)
  var d:=Vector3(rim[j].x,rim[j].y,size.z*.32)
  stone_face(st,Vector3(0,0,a.z),b,a,size)
  stone_face(st,a,b,d,size)
  stone_face(st,a,d,c,size)
  var back_c:=Vector3(c.x,c.y,-size.z*.55)
  var back_d:=Vector3(d.x,d.y,-size.z*.55)
  stone_face(st,c,d,back_d,size)
  stone_face(st,c,back_d,back_c,size)
 st.generate_normals()
 mesh_at(shell,st.commit(),at,ink)

func stone_face(st: SurfaceTool,a: Vector3,b: Vector3,c: Vector3,size: Vector3) -> void:
 for v in [a,b,c]:
  st.set_uv(Vector2(v.x,v.y)/Vector2(size.x,size.y)+Vector2(.5,.5))
  st.add_vertex(v)

func window(parent: Node3D,at: Vector3,width: float,height: float,leaf: float) -> void:
 shutter.albedo_color=Color("a5b293")
 super.window(parent,at,width,height,leaf)

func flower_card(parent: Node3D,_source: Texture2D,at: Vector3,height: float,_ground: bool) -> void:
 # Large readable heads and leaves in a frieze. The 427 cards were
 # finely rendered at source and read as speckles at this camera scale.
 bouquet(parent,at,height*.91,3)

func leaf_piece(parent: Node3D,at: Vector3,heading: float,length: float,tint: String) -> void:
 var leaf:=oval(parent,at,Vector3(length,.37*length,.16*length),color(tint))
 leaf.rotation.z=heading

func bouquet(parent: Node3D,at: Vector3,size: float,count: int) -> void:
 for i in 5:
  var a:=lerpf(-1.22,1.25,i/4.)
  var where:=at+Vector3(sin(a)*size*.37,.06+cos(a)*size*.24,.025*(i%2))
  leaf_piece(parent,where,PI*.5-a,size*.68,["647937","728747","81944d"][i%3])
 for i in count:
  var a: float=(i-(count-1)*.5)*.67
  var head:=at+Vector3(sin(a)*size*.53,size*(.51+(i%2)*.21),.059+.014*(i%2))
  daisy(parent,head,size*(.68+.09*(i%2)))

func daisy(parent: Node3D,at: Vector3,size: float) -> void:
 for i in 5:
  var a:=TAU*i/5.
  var petal:=oval(parent,at+Vector3(cos(a)*size*.147,sin(a)*size*.125,0),Vector3(.225,.138,.089)*size,color("f2e3bc" if i<2 else "fff0ca"))
  petal.rotation.z=a
 oval(parent,at+Vector3.BACK*size*.07,Vector3(.149,.14,.115)*size,color("d5a648"))

func build_planting() -> void:
 for side in [-1.,1.]:
  var at:=Vector3(side*1.85,-.218,FRONT+.67)
  planter(at,side)
  if side<0.:
   bouquet(terrace,at+Vector3(-.11,.54,.035),.55,3)
   bouquet(terrace,at+Vector3(.19,.53,.11),.38,2)
  else:
   for i in 9:
    var a:=lerpf(-1.44,1.22,i/8.)
    var pos:=at+Vector3(sin(a)*.37,.53+cos(a)*(.28+.08*(i%3)),.04*cos(i*2.))
    leaf_piece(terrace,pos,PI*.5-a,.36+.035*(i%3),["71854a","91a361","536e3b"][i%3])
  var cluster_at:=Vector3(side*5.78,-.155,2.53)
  bouquet(terrace,cluster_at,.46,3 if side<0. else 2)
  var shadow:=PlaneMesh.new()
  shadow.size=Vector2(.78,.44)
  var ink:=ShaderMaterial.new()
  ink.shader=preload("res://scripts/art/foot_contact16.gdshader")
  mesh_at(terrace,shadow,Vector3(cluster_at.x,-.208,cluster_at.z),ink).cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var ivy:=Node3D.new()
 ivy.position=Vector3(2.39,3.25,FRONT+.50)
 shell.add_child(ivy)
 for i in 12:
  var t:=i/11.
  var p:=Vector3(-.58*t+.15*sin(t*5.5),-.83*t,.03)
  for side in [-1.,1.]:
   leaf_piece(ivy,p+Vector3(side*.082,.017,.04),side*.71-.48,.20-.048*t,["596b36","738549","849451"][i%3])

func planter(at: Vector3,side: float) -> void:
 var clay:=stone.duplicate() as StandardMaterial3D
 clay.albedo_color=Color("ad8764" if side<0. else "c7b597")
 var profile: Array[Vector2]=[Vector2(.165,0),Vector2(.23,.06),Vector2(.30,.18),Vector2(.30,.31),Vector2(.265,.45),Vector2(.271,.49)]
 var st:=SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for row in profile.size()-1:
  for slice in 28:
   var a:=TAU*slice/28.
   var b:=TAU*(slice+1)/28.
   var lo:=profile[row]
   var up:=profile[row+1]
   for pair in [Vector2(a,row),Vector2(b,row),Vector2(b,row+1),Vector2(a,row),Vector2(b,row+1),Vector2(a,row+1)]:
    var section:=lo if int(pair.y)==row else up
    st.set_uv(Vector2(pair.x/TAU,section.y/.50))
    st.add_vertex(Vector3(cos(pair.x)*section.x,section.y,sin(pair.x)*section.x))
 st.generate_normals()
 var crock:=mesh_at(terrace,st.commit(),at,clay)
 ceramics.append(crock)
 var footprint:=CylinderMesh.new()
 footprint.height=.48
 footprint.top_radius=.28
 footprint.bottom_radius=.20
 var blocker:=mesh_at(terrace,footprint,at+Vector3.UP*.24,clay)
 blocker.create_trimesh_collision()
 blocker.hide()
 var trim:=color("8f745c" if side<0. else "a18b68")
 for row in [Vector2(.275,.479),Vector2(.277,.428)]:
  var hoop:=TorusMesh.new()
  hoop.inner_radius=row.x-.024
  hoop.outer_radius=row.x+.012
  hoop.rings=28
  hoop.ring_segments=8
  mesh_at(terrace,hoop,at+Vector3.UP*row.y,trim)
 var soil:=CylinderMesh.new()
 soil.height=.017
 soil.top_radius=.249
 soil.bottom_radius=.249
 soil.radial_segments=24
 mesh_at(terrace,soil,at+Vector3.UP*.478,color("69583a"))
