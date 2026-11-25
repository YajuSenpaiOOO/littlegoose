extends "res://scripts/room/home_yard411.gd"
var paint413: Texture2D
var wood413: StandardMaterial3D
var plaster413: StandardMaterial3D
var stone413: StandardMaterial3D
var slate413: StandardMaterial3D
var inside_roof413: Node3D
var tiles413:=0
func swatch413(index: int,tint: Color=Color.WHITE) -> StandardMaterial3D:
 var half:=paint413.get_size()*.5
 # Standard 3D material sampling does not apply AtlasTexture's 2D UV remap.
 # Extract a runtime swatch so every mesh receives only its intended quadrant.
 var region:=Rect2i(Vector2(index%2,index/2)*half+Vector2.ONE*4.,half-Vector2.ONE*8.)
 var swatch:=ImageTexture.create_from_image(paint413.get_image().get_region(region))
 var ink:=StandardMaterial3D.new();ink.albedo_texture=swatch;ink.albedo_color=tint
 ink.roughness=1.;ink.metallic_specular=0.;ink.cull_mode=BaseMaterial3D.CULL_DISABLED
 return ink
func box413(at: Vector3,size: Vector3,mat: Material,parent: Node3D=null) -> MeshInstance3D:
 return part404(facade403 if parent==null else parent,at,size,mat)
func beam413(a: Vector3,b: Vector3,width: float,mat: Material,parent: Node3D=null) -> MeshInstance3D:
 var n:=box413((a+b)*.5,Vector3(width,a.distance_to(b),width*.8),mat,parent)
 n.rotation.z=-atan2(b.x-a.x,b.y-a.y);return n
func roof_height413(x: float) -> float:return 8.15-absf(x)*.685
func build_house404(room: Node3D) -> void:
 # Reuse the independently hinged physical leaf; replace the complete old shell.
 super.build_house404(room)
 facade403.free();facade403=Node3D.new();facade403.name="CottageC413";add_child(facade403);glow404.clear()
 paint413=ImageTexture.create_from_image(Image.load_from_file("res://assets/house413/material-atlas.png"))
 wood413=swatch413(0,Color(.70,.69,.66));slate413=swatch413(1,Color(.88,.94,1.))
 plaster413=swatch413(2,Color(.94,.98,1.));stone413=swatch413(3,Color(.92,.98,1.))
 for side in [-1.,1.]:
  box413(Vector3(side*3.80,1.78,2.98),Vector3(5.45,3.56,.20),plaster413)
  box413(Vector3(side*6.51,1.8,-.93),Vector3(.18,3.6,7.76),plaster413)
 box413(Vector3(0,1.8,-4.76),Vector3(13.1,3.6,.18),plaster413)
 var gable:=SurfaceTool.new();gable.begin(Mesh.PRIMITIVE_TRIANGLES)
 for z in [3.09,-4.86]:quad404(gable,[Vector3(-6.6,3.56,z),Vector3(6.6,3.56,z),Vector3(0,8.15,z)])
 # Fill above the same true arched entrance without a rectangle over the hole.
 for i in 32:
  var x0: float=-1.075+2.15*float(i)/32.;var x1: float=-1.075+2.15*float(i+1)/32.
  var y0:=1.82+sqrt(maxf(0.,1.075*1.075-x0*x0));var y1:=1.82+sqrt(maxf(0.,1.075*1.075-x1*x1))
  quad404(gable,[Vector3(x0,y0,3.09),Vector3(x1,y1,3.09),Vector3(x1,3.56,3.09),Vector3(x0,3.56,3.09)])
 gable.generate_normals();kit.shape(facade403,gable.commit(),Vector3.ZERO,plaster413)
 for side in [-1.,1.]:
  for x in [side*1.28,side*6.40]:box413(Vector3(x,1.80,3.18),Vector3(.28,3.6,.30),wood413)
  box413(Vector3(side*3.84,.72,3.20),Vector3(5.05,.20,.26),wood413)
  for row in 2:
   for i in 6:
    var x: float=side*(1.68+i*.86)
    box413(Vector3(x,.18+row*.34,3.17),Vector3(.82,.32,.32),swatch413(3,Color(1.,.98-float(i%3)*.025,.91)))
  beam413(Vector3(side*6.88,3.46,3.31),Vector3(0,8.24,3.31),.46,wood413)
  # Triangular knee braces join the main storey beam to the posts.
  beam413(Vector3(side*6.32,2.94,3.30),Vector3(side*5.43,3.54,3.30),.23,wood413)
 box413(Vector3(0,3.59,3.23),Vector3(13.15,.31,.34),wood413)
 for x in [-2.08,2.08]:box413(Vector3(x,4.71,3.22),Vector3(.23,2.0,.26),wood413)
 box413(Vector3(0,6.80,3.23),Vector3(3.13,.20,.25),wood413)
 build_arch413()
 roof413()
 window413(Vector3(-3.72,1.93,3.23),1.65,1.62)
 window413(Vector3(3.72,1.93,3.23),1.65,1.62)
 window413(Vector3(0,5.35,3.25),2.55,2.20)
 wing413()
 chimney413()
 vine413(Vector3(5.93,.65,3.48),3.4)
 plaque413()
 var feather:=SurfaceTool.new();feather.begin(Mesh.PRIMITIVE_TRIANGLES)
 var outline: Array[Vector3]=[Vector3(-.34,7.05,3.37),Vector3(-.18,7.36,3.37),Vector3(.32,7.52,3.37),Vector3(.23,7.20,3.37),Vector3(-.05,7.02,3.37)]
 for i in outline.size():quad404(feather,[Vector3(0,7.25,3.37),outline[i],outline[(i+1)%outline.size()]])
 feather.generate_normals();var ivory: StandardMaterial3D=kit.material("efdbad");ivory.cull_mode=BaseMaterial3D.CULL_DISABLED
 kit.shape(facade403,feather.commit(),Vector3.ZERO,ivory)
 beam413(Vector3(-.37,6.98,3.40),Vector3(.27,7.44,3.40),.025,wood413)
 build_inside413()
 # Warm real light and a small native lantern at the entrance.
 var light:=OmniLight3D.new();light.position=Vector3(0,3.0,3.65);light.light_color=Color("ffd29a");light.light_energy=.28;light.omni_range=2.5;facade403.add_child(light)
 var glow: StandardMaterial3D=kit.material("f4ce80").duplicate();glow.emission_enabled=true;glow.emission=Color("ffc767");glow.emission_energy_multiplier=.5
 box413(Vector3(0,3.03,3.56),Vector3(.23,.36,.20),glow)
 for y in [2.82,3.24]:box413(Vector3(0,y,3.56),Vector3(.31,.07,.29),kit.material("4c4840"))
 print("HOME413_SHELL tiles=",tiles413," yaw=",rotation.y)
func build_arch413() -> void:
 for side in [-1.,1.]:
  for i in 5:box413(Vector3(side*1.20,.19+i*.36,3.31),Vector3(.30,.34,.40),stone413)
 for i in 13:
  var a:=PI*float(i)/13.;var b:=PI*float(i+1)/13.
  var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES);var points: Array[Vector3]=[]
  for z in [3.10,3.53]:
   for pair in [Vector2(a,1.075),Vector2(b,1.075),Vector2(b,1.39),Vector2(a,1.39)]:points.append(Vector3(cos(pair.x)*pair.y,1.82+sin(pair.x)*pair.y,z))
  for face in [[0,1,2,3],[4,7,6,5],[0,4,5,1],[1,5,6,2],[2,6,7,3],[3,7,4,0]]:quad404(st,[points[face[0]],points[face[1]],points[face[2]],points[face[3]]])
  st.generate_normals();kit.shape(facade403,st.commit(),Vector3.ZERO,stone413)
func tile_mesh413() -> ArrayMesh:
 var outline: Array[Vector2]=[Vector2(-.46,-.44),Vector2(.46,-.44),Vector2(.46,.29),Vector2(.33,.45),Vector2(-.33,.45),Vector2(-.46,.29)]
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in outline.size():
  var a:=Vector3(outline[i].x,.055,outline[i].y);var b:=Vector3(outline[(i+1)%outline.size()].x,.055,outline[(i+1)%outline.size()].y)
  for p in [Vector3(0,.055,0),a,b]:st.set_uv(Vector2(p.x/.92+.5,p.z/.9+.5));st.set_color(Color.WHITE);st.add_vertex(p)
  for p in [a,a-Vector3.UP*.11,b,b,a-Vector3.UP*.11,b-Vector3.UP*.11]:st.set_uv(Vector2(p.x/.92+.5,p.z/.9+.5));st.set_color(Color(.70,.72,.76));st.add_vertex(p)
 st.generate_normals();return st.commit()
func roof413() -> void:
 var roof:=MultiMeshInstance3D.new();roof.name="ChunkySlateRoof413";facade403.add_child(roof)
 var mm:=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.use_colors=true;mm.mesh=tile_mesh413();mm.instance_count=2*9*11
 var ink: StandardMaterial3D=slate413.duplicate();ink.vertex_color_use_as_albedo=true;roof.material_override=ink;roof.multimesh=mm
 var k:=0
 for side in [-1.,1.]:
  for row in 9:
   for col in 11:
    var x: float=side*(.25+row*.78);var z: float=-4.70+col*.80+float(row%2)*.10
    var pose:=Transform3D(Basis.from_euler(Vector3(0,0,-side*atan(.685))).scaled(Vector3.ONE*1.25),Vector3(x,roof_height413(x)+.06+float(8-row)*.018,z))
    mm.set_instance_transform(k,pose)
    var shade: float=.90+float((row*11+col*7)%7)*.025;mm.set_instance_color(k,Color(shade,shade,shade));k+=1
 tiles413=k
 for z in [-5.10,3.52]:
  for side in [-1.,1.]:beam413(Vector3(side*7.02,3.36,z),Vector3(0,8.24,z),.30,wood413)
 for side in [-1.,1.]:box413(Vector3(side*6.85,3.44,-.78),Vector3(.30,.28,8.80),wood413)
 box413(Vector3(0,8.27,-.78),Vector3(.31,.20,8.8),slate413)
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for side in [-1.,1.]:quad404(st,[Vector3(0,8.10,3.65),Vector3(side*7.08,3.25,3.65),Vector3(side*7.08,3.25,-5.36),Vector3(0,8.10,-5.36)])
 st.generate_normals();kit.shape(facade403,st.commit(),Vector3.ZERO,slate413)
func arch_face413(parent: Node3D,at: Vector3,width: float,height: float,mat: Material) -> MeshInstance3D:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var radius:=width*.5;var base:=height*.5-radius
 var points: Array[Vector3]=[Vector3(-radius,-height*.5,0),Vector3(radius,-height*.5,0),Vector3(radius,base,0)]
 for i in range(1,25):
  var a:=PI*float(i)/24.;points.append(Vector3(cos(a)*radius,base+sin(a)*radius,0))
 for i in points.size():quad404(st,[Vector3.ZERO,points[i],points[(i+1)%points.size()]])
 st.generate_normals();return kit.shape(parent,st.commit(),at,mat)
func window413(at: Vector3,width: float,height: float) -> void:
 arch_face413(facade403,at,width+.26,height+.23,wood413)
 var glass: StandardMaterial3D=kit.material("f5c673").duplicate();glass.cull_mode=BaseMaterial3D.CULL_DISABLED;glass.emission_enabled=true;glass.emission=Color("ffd78f");glass.emission_energy_multiplier=.20;glow404.append(glass)
 arch_face413(facade403,at+Vector3(0,0,.03),width,height,glass)
 box413(at+Vector3(0,0,.09),Vector3(.085,height-.06,.10),wood413)
 box413(at+Vector3(0,-height*.15,.09),Vector3(width,.075,.10),wood413)
 var shutter: StandardMaterial3D=swatch413(2,Color(.47,.57,.33))
 for side in [-1.,1.]:
  var point:=at+Vector3(side*(width*.5+.34),-.09,.08)
  box413(point,Vector3(.49,height*.84,.13),shutter)
  for i in 3:box413(point+Vector3(-.16+i*.16,0,.075),Vector3(.018,height*.82,.018),kit.material("556245"))
  for y in [-height*.25,height*.25]:box413(point+Vector3(0,y,.11),Vector3(.52,.075,.05),shutter)
  var curtain:=SurfaceTool.new();curtain.begin(Mesh.PRIMITIVE_TRIANGLES)
  quad404(curtain,[Vector3(side*width*.48,height*.15,.07),Vector3(side*width*.48,-height*.45,.07),Vector3(side*width*.23,-height*.15,.07)])
  var cloth: StandardMaterial3D=kit.material("fff0cf");cloth.cull_mode=BaseMaterial3D.CULL_DISABLED
  curtain.generate_normals();kit.shape(facade403,curtain.commit(),at,cloth)
 var box_at:=at+Vector3(0,-height*.5-.15,.22)
 box413(box_at,Vector3(width+.34,.30,.45),wood413)
 for i in 7:
  var x: float=-width*.46+i*width*.92/6.;var p:=box_at+Vector3(x,.24+float(i%3)*.05,.13)
  flower413(p,.85 if width<2. else 1.)
 var light:=OmniLight3D.new();light.position=at+Vector3(0,0,.45);light.light_color=Color("ffdc9b");light.light_energy=.16;light.omni_range=2.3;facade403.add_child(light)
func flower413(at: Vector3,size: float) -> void:
 kit.ellipsoid(facade403,at+Vector3(-.09,0,-.04),Vector3(.28,.12,.12)*size,"6e8847")
 kit.ellipsoid(facade403,at+Vector3(.09,-.05,0),Vector3(.25,.13,.11)*size,"84924c")
 for i in 5:
  var a:=TAU*i/5.
  kit.ellipsoid(facade403,at+Vector3(cos(a)*.078,sin(a)*.078,.04)*size,Vector3(.13,.085,.035)*size,"fff4ce")
 kit.ellipsoid(facade403,at+Vector3(0,0,.072)*size,Vector3(.085,.085,.042)*size,"e1b34f")
func vine413(at: Vector3,height: float) -> void:
 var green: StandardMaterial3D=kit.material("6a7d3f")
 for i in 15:
  var p:=at+Vector3(sin(i*.8)*.17,i*height/15.,.04)
  beam413(p,p+Vector3(.04,height/15.,0),.025,green)
  for side in [-1.,1.]:
   var leaf: MeshInstance3D=kit.ellipsoid(facade403,p+Vector3(side*.14,.04,.05),Vector3(.26,.13,.06),"819449" if i%3==0 else "657b3e")
   leaf.rotation.z=side*.5
func wing413() -> void:
 # A shallow right-hand cross-gable adds the C silhouette without turning house.
 var center:=Vector3(5.55,3.55,-1.55)
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for z in [-3.2,.1]:quad404(st,[Vector3(4.5,3.5,z),Vector3(6.7,3.5,z),Vector3(5.6,4.62,z)])
 st.generate_normals();kit.shape(facade403,st.commit(),Vector3.ZERO,plaster413)
 for side in [-1.,1.]:
  var roof:=SurfaceTool.new();roof.begin(Mesh.PRIMITIVE_TRIANGLES)
  quad404(roof,[Vector3(5.6,4.7,.32),Vector3(5.6+side*1.4,3.32,.32),Vector3(5.6+side*1.4,3.32,-3.42),Vector3(5.6,4.7,-3.42)])
  roof.generate_normals();kit.shape(facade403,roof.commit(),Vector3.ZERO,slate413)
  beam413(Vector3(5.6+side*1.4,3.32,.34),Vector3(5.6,4.7,.34),.22,wood413)
func chimney413() -> void:
 for row in 5:
  box413(Vector3(3.65,6.10+row*.35,-2.6),Vector3(.95,.33,.86),stone413)
 box413(Vector3(3.65,7.88,-2.6),Vector3(1.13,.23,1.04),stone413)
 for x in [3.38,3.92]:kit.cylinder(facade403,Vector3(x,8.18,-2.6),.15,.48,"a46540")
func plaque413() -> void:
 var ink:=ShaderMaterial.new();ink.shader=preload("res://scripts/room/door_cutaway404.gdshader");ink.set_shader_parameter("tint",Color("885a32"));door_inks404.append(ink)
 var plaque:=SphereMesh.new();plaque.radius=.5;plaque.height=1.
 var badge: MeshInstance3D=kit.shape(door404,plaque,Vector3(1.015,1.56,.17),ink);badge.scale=Vector3(1.02,.49,.09)
 for side in [-1.,1.]:
  var feather:=SurfaceTool.new();feather.begin(Mesh.PRIMITIVE_TRIANGLES)
  quad404(feather,[Vector3(1.015+side*.05,1.43,.226),Vector3(1.015+side*.31,1.59,.226),Vector3(1.015+side*.23,1.72,.226)])
  feather.generate_normals();var mark:=ShaderMaterial.new();mark.shader=ink.shader;mark.set_shader_parameter("tint",Color("f4dda7"));door_inks404.append(mark)
  kit.shape(door404,feather.commit(),Vector3.ZERO,mark)
func build_inside413() -> void:
 inside_roof413=Node3D.new();inside_roof413.name="MatchingPitchedInterior413";add_child(inside_roof413);inside_roof413.hide()
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for side in [-1.,1.]:
  quad404(st,[Vector3(0,8.00,2.60),Vector3(side*6.45,3.58,2.60),Vector3(side*6.45,3.58,-4.42),Vector3(0,8.00,-4.42)])
 quad404(st,[Vector3(-6.4,3.52,-4.43),Vector3(6.4,3.52,-4.43),Vector3(0,8.0,-4.43)])
 st.generate_normals();var mesh: MeshInstance3D=kit.shape(inside_roof413,st.commit(),Vector3.ZERO,plaster413);mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 for z in [-4.20,-.75,2.35]:
  for side in [-1.,1.]:beam413(Vector3(side*6.35,3.63,z),Vector3(0,8.02,z),.20,wood413,inside_roof413)
 box413(Vector3(0,3.62,-4.20),Vector3(12.85,.23,.25),wood413,inside_roof413)
 box413(Vector3(0,8.02,-.9),Vector3(.22,.25,6.9),wood413,inside_roof413)
