extends "res://scripts/room/home_yard413.gd"
var paint414: Image
var stone_count414:=0
var windows414: Array=[]
var relief414:=0
func swatch413(index: int,tint: Color=Color.WHITE) -> StandardMaterial3D:
 if paint414==null:paint414=Image.load_from_file("res://assets/house414/material-atlas.png")
 var half:=Vector2(paint414.get_size())*.5
 var region:=Rect2i(Vector2(index%2,index/2)*half+Vector2.ONE*4.,half-Vector2.ONE*8.)
 var ink:=StandardMaterial3D.new();ink.albedo_texture=ImageTexture.create_from_image(paint414.get_region(region))
 ink.albedo_color=[Color(.98,.96,.92),Color(.93,.98,1.02),Color(.96,.98,1.),Color(.95,.98,1.)][index]
 # Shutters are deliberately grey green; preserve the callers' distinct tint.
 if index==2 and tint.g>tint.r*1.1:ink.albedo_color=tint
 ink.roughness=1.;ink.metallic_specular=0.;ink.cull_mode=BaseMaterial3D.CULL_DISABLED
 return ink
func box413(at: Vector3,size: Vector3,mat: Material,parent: Node3D=null) -> MeshInstance3D:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var h:=Vector2(size.x,size.y)*.5;var c:=minf(size.x,size.y)*.13
 var outline: Array[Vector2]=[Vector2(-h.x+c,-h.y),Vector2(h.x-c,-h.y),Vector2(h.x,-h.y+c),Vector2(h.x,h.y-c),Vector2(h.x-c,h.y),Vector2(-h.x+c,h.y),Vector2(-h.x,h.y-c),Vector2(-h.x,-h.y+c)]
 for i in outline.size():
  var a:=Vector3(outline[i].x,outline[i].y,size.z*.5);var b:=Vector3(outline[(i+1)%outline.size()].x,outline[(i+1)%outline.size()].y,size.z*.5)
  quad414(st,[Vector3(0,0,size.z*.5),a,b],size)
  quad414(st,[Vector3(0,0,-size.z*.5),b-Vector3(0,0,size.z),a-Vector3(0,0,size.z)],size)
  quad414(st,[a,a-Vector3(0,0,size.z),b-Vector3(0,0,size.z),b],size)
 st.generate_normals();return kit.shape(facade403 if parent==null else parent,st.commit(),at,mat)
func quad414(st: SurfaceTool,points: Array,size: Vector3) -> void:
 for i in ([0,1,2] if points.size()==3 else [0,1,2,0,2,3]):
  var p: Vector3=points[i];st.set_uv(Vector2(p.x/maxf(size.x,.001)+.5,p.y/maxf(size.y,.001)+.5));st.add_vertex(p)
func build_house404(room: Node3D) -> void:
 super.build_house404(room)
 facade403.name="LayeredCottage414"
 # Replace the small regular plinth bricks with substantial staggered stones.
 for node in facade403.get_children():
  if node is MeshInstance3D and node.position.y<.7 and node.position.z>3.1 and node.position.z<3.2:node.hide()
 foundation414()
 timber414()
 door_hood414()
 for ink in door_inks404:
  if ink.get_shader_parameter("use_paint")==true:
   ink.set_shader_parameter("paint",wood413.albedo_texture);ink.set_shader_parameter("region",Vector4(0,0,1,1));ink.set_shader_parameter("tint",Color(.98,.95,.90))
 print("HOME414_LAYERS stones=",stone_count414," windows=",windows414.size()," relief=",relief414)
func foundation414() -> void:
 var mortar:=swatch413(3);mortar.albedo_color=Color(.57,.60,.57)
 for side in [-1.,1.]:box413(Vector3(side*4.05,.47,3.35),Vector3(5.25,.92,.65),mortar)
 for side in [-1.,1.]:
  for row in 2:
   for i in 5:
    var x: float=side*(1.94+i*1.02+(.25 if row==1 else 0.))
    var at:=Vector3(x,.24+row*.46,3.40+float((i+row)%3)*.035)
    var size:=Vector3(.98+float(i%2)*.08,.44+float((i+row)%2)*.06,.88)
    var stone:=stone414(at,size);stone.rotation.z=side*(float(i%3)-1.)*.025;stone_count414+=1
    kit.collider(self,at,size*.94)
  for row in 2:
   for i in 7:
    var at:=Vector3(side*6.60,.24+row*.46,2.74-i*1.04)
    var size:=Vector3(.76,.44+float(i%2)*.04,1.0)
    stone414(at,size);kit.collider(self,at,size*.94);stone_count414+=1
 for row in 2:
  for i in 12:
   var at:=Vector3(-5.75+i*1.045,.24+row*.46,-4.84)
   var size:=Vector3(1.02,.44+float(i%2)*.04,.78)
   stone414(at,size);kit.collider(self,at,size*.94);stone_count414+=1
 # A visibly deeper cap separates stone weight from the plaster wall above.
 for side in [-1.,1.]:box413(Vector3(side*4.02,.99,3.40),Vector3(5.36,.14,.82),stone413)
func stone414(at: Vector3,size: Vector3) -> MeshInstance3D:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var h:=Vector2(size.x,size.y)*.5;var c:=minf(size.x,size.y)*.22
 var outline: Array[Vector2]=[Vector2(-h.x+c,-h.y),Vector2(h.x-c,-h.y),Vector2(h.x,-h.y+c),Vector2(h.x,h.y-c),Vector2(h.x-c,h.y),Vector2(-h.x+c,h.y),Vector2(-h.x,h.y-c),Vector2(-h.x,-h.y+c)]
 for i in outline.size():
  var j: int=(i+1)%outline.size()
  var a:=Vector3(outline[i].x*.86,outline[i].y*.82,size.z*.5)
  var b:=Vector3(outline[j].x*.86,outline[j].y*.82,size.z*.5)
  quad414(st,[Vector3(0,0,size.z*.5),a,b],size)
  var c0:=Vector3(outline[i].x,outline[i].y,size.z*.21)
  var d:=Vector3(outline[j].x,outline[j].y,size.z*.21)
  quad414(st,[a,c0,d,b],size)
  quad414(st,[c0,Vector3(c0.x,c0.y,-size.z*.5),Vector3(d.x,d.y,-size.z*.5),d],size)
 st.generate_normals();return kit.shape(facade403,st.commit(),at,stone413)
func timber414() -> void:
 var edge:=swatch413(0);edge.albedo_color=Color(1.12,1.06,.97)
 for side in [-1.,1.]:
  for x in [side*1.43,side*6.34]:
   box413(Vector3(x,2.18,3.42),Vector3(.38,2.54,.54),wood413)
   box413(Vector3(x,1.10,3.45),Vector3(.53,.22,.65),edge)
   box413(Vector3(x,3.37,3.45),Vector3(.62,.27,.70),edge)
  # Curved knee brackets provide real infill volumes under the main lintel.
  var points: Array[Vector2]=[]
  for i in 17:
   var t: float=float(i)/16.
   points.append(Vector2(side*(6.25-1.13*t*t),2.79+.72*t))
  curve414(points,.22,.40,3.63,wood413)
 box413(Vector3(0,3.59,3.46),Vector3(13.28,.34,.76),wood413)
 box413(Vector3(0,3.80,3.56),Vector3(13.40,.11,.88),edge)
 for side in [-1.,1.]:
  for i in 4:
   var x: float=side*(2.10+i*1.02)
   carving414(Vector3(x,3.59,3.855),.65)
func curve414(points: Array[Vector2],width: float,depth: float,z: float,mat: Material) -> MeshInstance3D:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES);var rings: Array=[]
 for i in points.size():
  var axis: Vector2=(points[mini(i+1,points.size()-1)]-points[maxi(0,i-1)]).normalized()
  var n:=Vector2(-axis.y,axis.x)*width*.5;var p:=points[i]
  rings.append([Vector3(p.x+n.x,p.y+n.y,z+depth*.5),Vector3(p.x-n.x,p.y-n.y,z+depth*.5),Vector3(p.x-n.x,p.y-n.y,z-depth*.5),Vector3(p.x+n.x,p.y+n.y,z-depth*.5)])
 for i in range(points.size()-1):
  for face in 4:quad404(st,[rings[i][face],rings[i][(face+1)%4],rings[i+1][(face+1)%4],rings[i+1][face]])
 st.generate_normals();return kit.shape(facade403,st.commit(),Vector3.ZERO,mat)
func carving414(at: Vector3,size: float) -> void:
 var ink:=swatch413(0);ink.albedo_color=Color(1.23,1.16,1.02)
 beam413(at+Vector3(-.30,0,0)*size,at+Vector3(.30,0,0)*size,.018,ink)
 for side in [-1.,1.]:
  for i in 2:
   var p:=at+Vector3(side*(.10+i*.13),.045,0)*size
   var leaf: MeshInstance3D=kit.ellipsoid(facade403,p,Vector3(.15,.055,.025)*size,"a99a76")
   leaf.rotation.z=side*.45;relief414+=1
func roof413() -> void:
 super.roof413()
 var roof: MultiMeshInstance3D=facade403.get_node("ChunkySlateRoof413")
 for i in roof.multimesh.instance_count:
  var pose:=roof.multimesh.get_instance_transform(i);var col:=i%11;var row: int=(i/11)%9
  pose.origin.z=-5.0+col*.92+float(row%2)*.10;roof.multimesh.set_instance_transform(i,pose)
 var underside:=swatch413(0);underside.albedo_color=Color(.67,.67,.64)
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for side in [-1.,1.]:quad404(st,[Vector3(0,8.09,4.74),Vector3(side*7.10,3.23,4.74),Vector3(side*7.10,3.23,-5.53),Vector3(0,8.09,-5.53)])
 st.generate_normals();kit.shape(facade403,st.commit(),Vector3.ZERO,underside)
 var edge:=swatch413(0);edge.albedo_color=Color(1.18,1.10,.99)
 for side in [-1.,1.]:
  beam413(Vector3(side*7.10,3.25,4.53),Vector3(0,8.28,4.53),.48,wood413)
  beam413(Vector3(side*7.10,3.35,4.76),Vector3(0,8.38,4.76),.11,edge)
  box413(Vector3(side*6.96,3.27,-.36),Vector3(.42,.38,10.1),wood413)
  # Individual rafter tails make the overhang read as construction.
  for i in 10:box413(Vector3(side*6.96,3.08,-4.6+i*.94),Vector3(.72,.18,.16),edge)
func window413(at: Vector3,width: float,height: float) -> void:
 var back:=at;back.z+=.06
 var front: float=at.z+.68
 windows414.append({"back":back.z,"glass":front-.25,"front":front})
 arch_face413(facade403,back,width+.54,height+.49,wood413)
 var inner:=outline414(width,height);var outer:=outline414(width+.36,height+.36)
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in outer.size():
  var j: int=(i+1)%outer.size()
  var a:=Vector3(outer[i].x,outer[i].y,front-at.z);var b:=Vector3(outer[j].x,outer[j].y,front-at.z)
  var c:=Vector3(inner[j].x,inner[j].y,front-at.z-.25);var d:=Vector3(inner[i].x,inner[i].y,front-at.z-.25)
  quad404(st,[a,b,c,d]);quad404(st,[a,Vector3(a.x,a.y,.06),Vector3(b.x,b.y,.06),b])
 st.generate_normals();kit.shape(facade403,st.commit(),at,wood413)
 var glass: StandardMaterial3D=kit.material("d8b67d").duplicate();glass.cull_mode=BaseMaterial3D.CULL_DISABLED;glass.emission_enabled=true;glass.emission=Color("e7c58a");glass.emission_energy_multiplier=.14;glow404.append(glass)
 var glint:=at;glint.z=front-.255
 arch_face413(facade403,glint,width,height,glass)
 box413(glint+Vector3(0,0,.045),Vector3(.10,height,.10),wood413)
 box413(glint+Vector3(0,-height*.15,.045),Vector3(width,.10,.10),wood413)
 var shutter:=swatch413(2,Color(.46,.53,.39))
 for side in [-1.,1.]:
  var p:=Vector3(at.x+side*(width*.5+.43),at.y-.10,front+.02)
  var panel:=box413(p,Vector3(.62,height*.88,.18),shutter);panel.rotation.y=side*deg_to_rad(10.)
  for y in [-height*.27,height*.27]:box413(p+Vector3(0,y,.13),Vector3(.68,.085,.07),wood413)
  for i in 3:box413(p+Vector3(-.19+i*.19,0,.11),Vector3(.020,height*.84,.035),kit.material("66705a"))
  # Curved corbels under the projecting sill.
  var points: Array[Vector2]=[]
  for i in 13:
   var t:=float(i)/12.
   points.append(Vector2(at.x+side*(width*.41-.20*sin(t*PI)),at.y-height*.5-.18-.48*t))
  curve414(points,.12,.32,front-.06,wood413)
 var sill:=Vector3(at.x,at.y-height*.5-.08,front-.10)
 box413(sill,Vector3(width+1.0,.17,1.04),wood413)
 box413(sill+Vector3(0,-.19,.25),Vector3(width+.64,.32,.58),wood413)
 carving414(sill+Vector3(0,-.17,.55),.85)
 for i in 7:
  var p:=sill+Vector3(-width*.46+i*width*.92/6.,.17+float(i%3)*.045,.34)
  flower413(p,.95 if width<2. else 1.12)
 var light:=OmniLight3D.new();light.position=glint+Vector3(0,0,.60);light.light_color=Color("ffdcab");light.light_energy=.14;light.omni_range=2.5;facade403.add_child(light)
func outline414(width: float,height: float) -> Array[Vector2]:
 var r:=width*.5;var base:=height*.5-r
 var result: Array[Vector2]=[Vector2(-r,-height*.5),Vector2(r,-height*.5),Vector2(r,base)]
 for i in range(1,25):
  var a:=PI*float(i)/24.;result.append(Vector2(cos(a)*r,base+sin(a)*r))
 return result
func door_hood414() -> void:
 var points: Array[Vector2]=[]
 for i in 25:
  var x: float=-1.75+3.5*i/24.;points.append(Vector2(x,3.07+.52*(1.-pow(x/1.75,2.))))
 curve414(points,.26,.86,3.82,wood413)
 var edge:=swatch413(0);edge.albedo_color=Color(1.18,1.11,1.0)
 for i in points.size():points[i].y+=.15
 curve414(points,.075,1.02,3.89,edge)
 carving414(Vector3(0,3.59,4.26),.75)
 # Keep the traversable opening untouched; the hood is entirely overhead.
 var lamp: StandardMaterial3D=kit.material("e2bf86").duplicate();lamp.emission_enabled=true;lamp.emission=Color("eacb91");lamp.emission_energy_multiplier=.4
 box413(Vector3(0,3.09,4.01),Vector3(.23,.34,.23),lamp)
