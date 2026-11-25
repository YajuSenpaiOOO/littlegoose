extends "res://scripts/room/home_yard414.gd"
var masses415:=0
func build_house404(room: Node3D) -> void:
 super.build_house404(room)
 facade403.free();facade403=Node3D.new();facade403.name="CottageMassing415";add_child(facade403)
 glow404.clear();windows414.clear();stone_count414=0
 # Keep the same usable room footprint; divide its exterior into two volumes.
 box413(Vector3(-3.82,2.10,3.0),Vector3(5.48,4.20,.22),plaster413)
 box413(Vector3(1.61,2.10,3.0),Vector3(1.10,4.20,.22),plaster413)
 box413(Vector3(-6.51,2.10,-.93),Vector3(.20,4.20,7.8),plaster413)
 box413(Vector3(6.51,1.85,-.63),Vector3(.20,3.70,8.4),plaster413)
 box413(Vector3(0,2.1,-4.76),Vector3(13.1,4.2,.20),plaster413)
 # Actual arch opening is preserved; the entrance sits off-centre on the main mass.
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 32:
  var a: float=-1.075+2.15*i/32.;var b: float=-1.075+2.15*(i+1)/32.
  quad404(st,[Vector3(a,1.82+sqrt(maxf(0.,1.075*1.075-a*a)),3.12),Vector3(b,1.82+sqrt(maxf(0.,1.075*1.075-b*b)),3.12),Vector3(b,4.2,3.12),Vector3(a,4.2,3.12)])
 st.generate_normals();kit.shape(facade403,st.commit(),Vector3.ZERO,plaster413)
 mass415(-2.20,9.0,4.2,6.8,3.15,-4.9)
 # Side room projects forward, with a distinct lower ridge and shorter wall.
 box413(Vector3(4.37,1.85,3.58),Vector3(4.50,3.70,.24),plaster413)
 kit.collider(self,Vector3(4.37,1.70,3.46),Vector3(4.50,3.40,.18))
 mass415(4.42,4.72,3.70,5.0,3.76,-4.85)
 for x in [-6.35,2.16,6.35]:box413(Vector3(x,2.10 if x<3. else 1.85,3.30 if x<3. else 3.90),Vector3(.32,4.20 if x<3. else 3.70,.45),wood413)
 box413(Vector3(-2.2,4.16,3.35),Vector3(9.0,.25,.45),wood413)
 box413(Vector3(4.42,3.68,3.94),Vector3(4.82,.24,.48),wood413)
 window413(Vector3(-3.84,2.12,3.18),1.88,1.85)
 window413(Vector3(4.38,1.98,3.77),2.0,1.80)
 window413(Vector3(-2.20,5.08,3.24),1.70,1.55)
 build_arch413();door_hood414()
 # A separate small entrance canopy gives the third, human-scale roof.
 canopy415()
 foundation414()
 for node in facade403.get_children():
  if node is Node3D and node.position.x>2.2 and node.position.y<1.1 and node.position.z>3.2 and node.position.z<3.85:node.position.z+=.60
 for body in get_children():
  if body is StaticBody3D and body.position.x>2.2 and body.position.y<1.1 and body.position.z>3.2 and body.position.z<3.85:body.position.z+=.60
 vine413(Vector3(6.17,.8,4.03),2.5)
 for row in 4:box413(Vector3(-4.3,5.88+row*.31,-2.6),Vector3(.86,.29,.86),stone413)
 box413(Vector3(-4.3,7.16,-2.6),Vector3(1.02,.20,1.02),stone413)
 for x in [-4.55,-4.05]:kit.cylinder(facade403,Vector3(x,7.40,-2.6),.14,.36,"966247")
 print("HOME415_MASSES ",masses415)
func mass415(center: float,width: float,eave: float,peak: float,front: float,back: float) -> void:
 masses415+=1
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for z in [front,back]:quad404(st,[Vector3(center-width*.5,eave,z),Vector3(center+width*.5,eave,z),Vector3(center,peak,z)])
 st.generate_normals();kit.shape(facade403,st.commit(),Vector3.ZERO,plaster413)
 var roof:=SurfaceTool.new();roof.begin(Mesh.PRIMITIVE_TRIANGLES)
 var half:=width*.5+.36;var slope: float=(peak-eave)/(width*.5)
 for side in [-1.,1.]:
  quad404(roof,[Vector3(center,peak,front+.75),Vector3(center+side*half,eave-.20,front+.75),Vector3(center+side*half,eave-.20,back-.35),Vector3(center,peak,back-.35)])
  beam413(Vector3(center+side*half,eave-.18,front+.78),Vector3(center,peak+.08,front+.78),.31,wood413)
 roof.generate_normals();kit.shape(facade403,roof.commit(),Vector3.ZERO,slate413)
 var mm:=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.use_colors=true;mm.mesh=tile_mesh413()
 var rows:=ceili(half/.65);var cols:=ceili((front-back+1.1)/.76);mm.instance_count=rows*cols*2
 var n:=MultiMeshInstance3D.new();n.multimesh=mm;var ink: StandardMaterial3D=slate413.duplicate();ink.vertex_color_use_as_albedo=true;n.material_override=ink;facade403.add_child(n)
 var k:=0
 for side in [-1.,1.]:
  for r in rows:
   for c in cols:
    var x: float=(r+.4)*half/rows
    mm.set_instance_transform(k,Transform3D(Basis.from_euler(Vector3(0,0,-side*atan(slope))).scaled(Vector3.ONE*1.16),Vector3(center+side*x,peak-x*slope+.10+(rows-r)*.012,back-.1+c*.76)))
    var shade: float=.90+float((r*3+c*7)%6)*.025;mm.set_instance_color(k,Color(shade,shade,shade));k+=1
func canopy415() -> void:
 masses415+=1
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for side in [-1.,1.]:
  quad404(st,[Vector3(0,3.95,4.65),Vector3(side*1.65,3.05,4.65),Vector3(side*1.65,3.05,3.1),Vector3(0,3.95,3.1)])
  beam413(Vector3(side*1.65,3.05,4.68),Vector3(0,3.98,4.68),.21,wood413)
 st.generate_normals();kit.shape(facade403,st.commit(),Vector3.ZERO,slate413)
