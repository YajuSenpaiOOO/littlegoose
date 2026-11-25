extends "res://scripts/room/home_yard403.gd"
signal door_settled404
var door404: AnimatableBody3D
var opened404:=false
var door_moving404:=false
var door_tween404: Tween
var glow404: Array[StandardMaterial3D]=[]
var door_inks404: Array[ShaderMaterial]=[]
func build403(room: Node3D) -> void:
 super.build403(room)
 # Replace only the 403 blockout facade. The yard, room and real doorway stay put.
 facade403.free()
 build_house404(room)
func build_house404(room: Node3D) -> void:
 kit=room
 facade403=Node3D.new();facade403.name="CottageCutaway404";add_child(facade403)
 var wood:=StandardMaterial3D.new();wood.roughness=1.;wood.albedo_color=Color("b29c7e")
 var paint:=AtlasTexture.new();paint.atlas=preload("res://assets/room395/wood-atlas.png");paint.region=Rect2(8,8,610,610);paint.filter_clip=true;wood.albedo_texture=paint
 var plaster: StandardMaterial3D=kit.material("dfd2b4");var stone: StandardMaterial3D=kit.material("a4aa9e")
 plaster.cull_mode=BaseMaterial3D.CULL_DISABLED
 # Front masonry has a physical door-shaped opening, not a painted black rectangle.
 for side in [-1.,1.]:
  part404(facade403,Vector3(side*3.8,1.78,2.88),Vector3(5.45,3.56,.20),plaster)
  part404(facade403,Vector3(side*6.51,1.8,-.93),Vector3(.16,3.6,7.76),plaster)
  for x in [side*1.13,side*3.8,side*6.42]:part404(facade403,Vector3(x,1.8,3.035),Vector3(.17,3.6,.16),wood)
  # Varied large masonry blocks at the foot, with quiet colour rather than noisy detail.
  for row in 2:
   for i in 5:
    var x: float=side*(1.64+float(i)*1.05)
    part404(facade403,Vector3(x,.22+float(row)*.41,3.015),Vector3(1.0,.39,.16),stone)
 part404(facade403,Vector3(0,1.8,-4.76),Vector3(13.1,3.6,.18),plaster)
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 32:
  var x0: float=-1.075+2.15*float(i)/32.;var x1: float=-1.075+2.15*float(i+1)/32.
  var a:=Vector3(x0,1.82+sqrt(maxf(0.,1.075*1.075-x0*x0)),2.995)
  var b:=Vector3(x1,1.82+sqrt(maxf(0.,1.075*1.075-x1*x1)),2.995)
  quad404(st,[a,b,Vector3(x1,3.56,2.995),Vector3(x0,3.56,2.995)])
 quad404(st,[Vector3(-6.5,3.56,2.995),Vector3(6.5,3.56,2.995),Vector3(0,6.96,2.995)])
 st.generate_normals();kit.shape(facade403,st.commit(),Vector3.ZERO,plaster)
 for y in [.88,3.55]:part404(facade403,Vector3(0,y,3.075),Vector3(13.1,.17,.20),wood)
 for side in [-1.,1.]:
  beam404(Vector3(side*6.7,3.55,3.10),Vector3(0,7.02,3.10),.22,wood)
  beam404(Vector3(side*3.8,3.62,3.08),Vector3(side*1.9,5.67,3.08),.14,wood)
 part404(facade403,Vector3(0,5.0,3.07),Vector3(.18,2.8,.18),wood)
 # Native arch stones and independent hinged door.
 for side in [-1.,1.]:
  for i in 5:part404(facade403,Vector3(side*1.19,.19+float(i)*.36,3.08),Vector3(.25,.34,.32),kit.material("c9c4ad"))
 for i in 13:
  var a: float=PI*float(i)/13.;var b: float=PI*float(i+1)/13.
  var ring:=SurfaceTool.new();ring.begin(Mesh.PRIMITIVE_TRIANGLES)
  var points: Array[Vector3]=[]
  for z in [2.91,3.25]:
   for item in [Vector2(a,1.075),Vector2(b,1.075),Vector2(b,1.33),Vector2(a,1.33)]:points.append(Vector3(cos(item.x)*item.y,1.82+sin(item.x)*item.y,z))
  for face in [[0,1,2,3],[4,7,6,5],[0,4,5,1],[1,5,6,2],[2,6,7,3],[3,7,4,0]]:quad404(ring,[points[face[0]],points[face[1]],points[face[2]],points[face[3]]])
  ring.generate_normals();var arch_mat: StandardMaterial3D=kit.material("d1c9ac" if i%2==0 else "beb9a3");arch_mat.cull_mode=BaseMaterial3D.CULL_DISABLED
  kit.shape(facade403,ring.commit(),Vector3.ZERO,arch_mat)
 roof404(wood)
 window404(Vector3(-3.65,1.95,3.10),1.35,wood)
 window404(Vector3(3.65,1.95,3.10),1.35,wood)
 window404(Vector3(0,4.92,3.10),1.28,wood)
 door404=AnimatableBody3D.new();door404.name="HingedDoor404";door404.position=Vector3(-1.015,.025,2.88);door404.collision_layer=1;door404.collision_mask=0;add_child(door404)
 var leaf:=SurfaceTool.new();leaf.begin(Mesh.PRIMITIVE_TRIANGLES)
 var outline: Array[Vector2]=[Vector2(0,0),Vector2(2.03,0),Vector2(2.03,1.82)]
 for i in range(1,33):
  var a: float=PI*float(i)/32.;outline.append(Vector2(1.015+cos(a)*1.015,1.82+sin(a)*1.015))
 var center:=Vector2(1.015,1.25)
 for i in outline.size():
  var a: Vector2=outline[i];var b: Vector2=outline[(i+1)%outline.size()]
  for z in [-.065,.065]:quad404(leaf,[Vector3(center.x,center.y,z),Vector3(a.x,a.y,z),Vector3(b.x,b.y,z)])
  quad404(leaf,[Vector3(a.x,a.y,-.065),Vector3(b.x,b.y,-.065),Vector3(b.x,b.y,.065),Vector3(a.x,a.y,.065)])
 leaf.generate_normals();var door_wood: StandardMaterial3D=wood.duplicate();door_wood.cull_mode=BaseMaterial3D.CULL_DISABLED
 kit.shape(door404,leaf.commit(),Vector3.ZERO,door_wood)
 var shape:=CollisionShape3D.new();var volume:=BoxShape3D.new();volume.size=Vector3(2.03,2.80,.13);shape.shape=volume;shape.position=Vector3(1.015,1.40,0);door404.add_child(shape)
 for y in [.52,1.94]:part404(door404,Vector3(1.015,y,.095),Vector3(1.85,.095,.05),kit.material("4c535b"))
 for x in [.4,.8,1.2,1.6]:
  var h: float=1.82+sqrt(maxf(0.,1.015*1.015-(x-1.015)*(x-1.015)))
  part404(door404,Vector3(x,h*.5,.068),Vector3(.016,h-.03,.01),kit.material("776149"))
 var handle:=TorusMesh.new();handle.inner_radius=.075;handle.outer_radius=.11
 var h=kit.shape(door404,handle,Vector3(1.68,1.23,.15),kit.material("4c535b"));h.rotation_degrees.x=90.
 for node in door404.find_children("*","MeshInstance3D",true,false):
  var old: StandardMaterial3D=node.material_override
  var ink:=ShaderMaterial.new();ink.shader=preload("res://scripts/room/door_cutaway404.gdshader");ink.set_shader_parameter("tint",old.albedo_color)
  if old.albedo_texture!=null:
   ink.set_shader_parameter("use_paint",true)
   if old.albedo_texture is AtlasTexture:
    var atlas: AtlasTexture=old.albedo_texture;var bounds: Rect2=atlas.region
    ink.set_shader_parameter("paint",atlas.atlas);ink.set_shader_parameter("region",Vector4(bounds.position.x/atlas.atlas.get_width(),bounds.position.y/atlas.atlas.get_height(),bounds.size.x/atlas.atlas.get_width(),bounds.size.y/atlas.atlas.get_height()))
   else:ink.set_shader_parameter("paint",old.albedo_texture)
  node.material_override=ink;door_inks404.append(ink)
func part404(parent: Node3D,at: Vector3,size: Vector3,mat: Material) -> MeshInstance3D:
 var mesh:=BoxMesh.new();mesh.size=size;return kit.shape(parent,mesh,at,mat)
func quad404(st: SurfaceTool,points: Array) -> void:
 for index in ([0,1,2] if points.size()==3 else [0,1,2,0,2,3]):
  var p: Vector3=points[index];st.set_uv(Vector2(p.x,p.y)*.3);st.add_vertex(p)
func beam404(a: Vector3,b: Vector3,width: float,mat: Material) -> void:
 var n:=part404(facade403,(a+b)*.5,Vector3(width,a.distance_to(b),width),mat);n.rotation.z=-atan2(b.x-a.x,b.y-a.y)
func roof404(wood: Material) -> void:
 var tiles:=MultiMeshInstance3D.new();tiles.name="SlateRoofTiles404";facade403.add_child(tiles)
 var mm:=MultiMesh.new();mm.transform_format=MultiMesh.TRANSFORM_3D;mm.use_colors=true
 var tile:=BoxMesh.new();tile.size=Vector3(.80,.07,.71)
 var material:=StandardMaterial3D.new();material.albedo_color=Color("758391");material.albedo_texture=preload("res://assets/garden45/slate.png");material.vertex_color_use_as_albedo=true;material.roughness=1.;tile.material=material
 mm.mesh=tile;mm.instance_count=240;tiles.multimesh=mm
 var k:=0
 for side in [-1.,1.]:
  for i in 10:
   for j in 12:
    var x: float=side*(float(i)+.5)*.68;var y: float=7.06-absf(x)*(.51)+float(10-i)*.012
    mm.set_instance_transform(k,Transform3D(Basis.from_euler(Vector3(0,0,-side*atan(.51))),Vector3(x,y,-4.85+float(j)*.72)))
    var shade: float=.90+float((i*7+j*3)%5)*.025;mm.set_instance_color(k,Color(shade,shade,shade));k+=1
 for side in [-1.,1.]:part404(facade403,Vector3(side*6.8,3.57,-.85),Vector3(.16,.20,8.55),wood)
 var base:=SurfaceTool.new();base.begin(Mesh.PRIMITIVE_TRIANGLES)
 for side in [-1.,1.]:quad404(base,[Vector3(0,6.98,3.5),Vector3(side*7.0,3.41,3.5),Vector3(side*7.0,3.41,-5.25),Vector3(0,6.98,-5.25)])
 base.generate_normals();var under: StandardMaterial3D=kit.material("63717b").duplicate();under.cull_mode=BaseMaterial3D.CULL_DISABLED;kit.shape(facade403,base.commit(),Vector3.ZERO,under)
 part404(facade403,Vector3(0,7.12,-.85),Vector3(.20,.16,8.55),kit.material("657581"))
 part404(facade403,Vector3(3.8,5.8,-2.7),Vector3(.9,1.9,.85),kit.material("a8ada1"))
 part404(facade403,Vector3(3.8,6.79,-2.7),Vector3(1.06,.18,1.01),kit.material("cbc5ad"))
 for x in [3.59,4.01]:kit.cylinder(facade403,Vector3(x,7.02,-2.7),.13,.40,"a36b49")
func window404(at: Vector3,width: float,wood: Material) -> void:
 var glass:=StandardMaterial3D.new();glass.albedo_color=Color("b9ad7c");glass.emission_enabled=true;glass.emission=Color("efb868");glass.emission_energy_multiplier=.18;glass.roughness=.6;glow404.append(glass)
 part404(facade403,at,Vector3(width,1.35,.09),wood)
 part404(facade403,at+Vector3(0,0,.06),Vector3(width-.15,1.18,.05),glass)
 for size in [Vector3(.07,1.18,.07),Vector3(width-.15,.07,.07)]:part404(facade403,at+Vector3(0,0,.10),size,wood)
 for side in [-1.,1.]:
  part404(facade403,at+Vector3(side*(width*.5+.20),0,.01),Vector3(.34,1.35,.11),kit.material("879077"))
  for dy in [-.43,.43]:part404(facade403,at+Vector3(side*(width*.5+.20),dy,.09),Vector3(.37,.07,.04),wood)
 part404(facade403,at+Vector3(0,-.85,.15),Vector3(width+.15,.28,.36),wood)
 flower403(at+Vector3(0,-.70,.26),"pink",.55)
 get_child(get_child_count()-1).reparent(facade403)
 var light:=OmniLight3D.new();light.position=at+Vector3(0,0,.45);light.light_color=Color("ffd6a0");light.light_energy=.20;light.omni_range=1.8;facade403.add_child(light)
func set_open404(value: bool) -> void:
 if value==opened404:return
 opened404=value;door_moving404=true
 if is_instance_valid(door_tween404):door_tween404.kill()
 door_tween404=create_tween();door_tween404.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS);door_tween404.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
 door_tween404.tween_property(door404,"rotation:y",deg_to_rad(104.) if value else 0.,.42)
 door_tween404.tween_callback(func():door_moving404=false;door_settled404.emit())
