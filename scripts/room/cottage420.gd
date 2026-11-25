extends Node3D
## A-plan exterior. X is east, positive Z is the entry/front.

const HALL := Rect2(-3.0,-3.8,6.0,7.0)
const LEFT := Rect2(-6.15,-2.55,3.15,4.65)
const RIGHT := Rect2(3.0,-2.55,3.15,4.65)
const MAIN_EAVE := 3.35
const MAIN_RIDGE := 6.85
const WING_EAVE := 2.85
const WING_RIDGE := 4.15
const FRONT := 3.2

var wood: StandardMaterial3D
var plaster: StandardMaterial3D
var stone: StandardMaterial3D
var slate: StandardMaterial3D
var shutter: StandardMaterial3D
var mat_cache: Dictionary={}
var rng := RandomNumberGenerator.new()
var shell: Node3D
var roof: Node3D
var terrace: Node3D

func _ready() -> void:
 rng.seed=420
 var atlas:=Image.load_from_file("res://assets/house414/material-atlas.png")
 plaster=paint(atlas,2,Color("f1e3c6"))
 slate=paint(atlas,1,Color("a8aabe"))
 wood=paint(atlas,0,Color("a1836d"))
 stone=paint(atlas,3,Color("c4beb1"))
 shutter=paint(atlas,0,Color("82a786"))
 shell=group("WallsAndTimber")
 roof=group("CrossGableRoof")
 terrace=group("ThresholdAndPlanting")
 build_walls()
 build_roofs()
 build_entry()
 build_planting()

func group(label: String) -> Node3D:
 var node:=Node3D.new()
 node.name=label
 add_child(node)
 return node

func color(hex: String) -> StandardMaterial3D:
 if not mat_cache.has(hex):
  var ink:=StandardMaterial3D.new()
  ink.albedo_color=Color(hex)
  ink.roughness=1.
  ink.metallic_specular=.05
  mat_cache[hex]=ink
 return mat_cache[hex]

func paint(atlas: Image,index: int,tint: Color) -> StandardMaterial3D:
 var w:=atlas.get_width()/2
 var h:=atlas.get_height()/2
 var image:=atlas.get_region(Rect2i(index%2*w,index/2*h,w,h))
 image.generate_mipmaps()
 var ink:=StandardMaterial3D.new()
 ink.albedo_texture=ImageTexture.create_from_image(image)
 ink.albedo_color=tint
 ink.roughness=1.
 ink.cull_mode=BaseMaterial3D.CULL_DISABLED
 return ink

func mesh_at(parent: Node3D,mesh: Mesh,at: Vector3,ink: Material) -> MeshInstance3D:
 var node:=MeshInstance3D.new()
 node.mesh=mesh
 node.material_override=ink
 node.position=at
 parent.add_child(node)
 return node

func block(parent: Node3D,at: Vector3,size: Vector3,ink: Material,solid:=false) -> MeshInstance3D:
 var mesh:=BoxMesh.new()
 mesh.size=size
 var node:=mesh_at(parent,mesh,at,ink)
 if solid:
  node.create_trimesh_collision()
 return node

func beam(parent: Node3D,a: Vector3,b: Vector3,width: float,depth: float,ink: Material) -> void:
 var direction:=b-a
 var node:=block(parent,(a+b)*.5,Vector3(width,direction.length()+.012,depth),ink)
 node.basis=Basis(Quaternion(Vector3.UP,direction.normalized())).orthonormalized()

func polygon(parent: Node3D,points: PackedVector2Array,z: float,ink: Material) -> void:
 var st:=SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var triangles:=Geometry2D.triangulate_polygon(points)
 triangles.reverse()
 for i in triangles:
  var pt:=points[i]
  st.set_normal(Vector3.BACK)
  st.set_uv(pt*.35)
  st.add_vertex(Vector3(pt.x,pt.y,z))
 mesh_at(parent,st.commit(),Vector3.ZERO,ink)

func base_course(x0: float,x1: float,z: float) -> void:
 block(shell,Vector3((x0+x1)*.5,.29,z),Vector3(x1-x0,.58,.38),color("655d51"))
 for row in 2:
  var count:=ceili((x1-x0)/.65)+row
  var span:=(x1-x0)/float(count)
  for i in count:
   var chunk:=block(shell,Vector3(x0+(i+.5)*span,.15+row*.28,z+.13),Vector3(span-.025,.25,.27),stone)
   chunk.rotation.z=rng.randf_range(-.033,.033)

func post(x: float,z: float,height: float,width: float) -> void:
 block(shell,Vector3(x,.31,z),Vector3(width+.18,.62,.50),stone)
 block(shell,Vector3(x,(height+.62)*.5,z),Vector3(width,height-.62,.38),wood)
 block(shell,Vector3(x,height-.13,z+.025),Vector3(width+.15,.24,.40),wood)

func post_on(parent: Node3D,x: float,height: float) -> void:
 block(parent,Vector3(x,.3,.18),Vector3(.39,.60,.27),stone)
 block(parent,Vector3(x,(height+.60)*.5,.15),Vector3(.25,height-.60,.26),wood)

func brace(start: Vector3,side: float,length: float,rise: float) -> void:
 var last:=start
 for i in range(1,13):
  var t:=float(i)/12.
  var point:=start+Vector3(side*length*t*t,rise*t,0)
  beam(shell,last,point,.205,.22,wood)
  last=point

func build_walls() -> void:
 for side in [-1.,1.]:
  var x: float=side*4.575
  block(shell,Vector3(x,WING_EAVE*.5,-2.55),Vector3(3.15,WING_EAVE,.24),plaster,true)
  block(shell,Vector3(side*6.15,WING_EAVE*.5,-.225),Vector3(.24,WING_EAVE,4.65),plaster,true)
  for z in [-3.175,2.65]:
   block(shell,Vector3(side*3.0,MAIN_EAVE*.5,z),Vector3(.24,MAIN_EAVE,1.2),plaster,true)
  block(shell,Vector3(side*3.,3.26,-.225),Vector3(.24,1.19,4.66),plaster,true)
  var side_wall:=Node3D.new()
  shell.add_child(side_wall)
  side_wall.position=Vector3(side*6.15,0,-.225)
  side_wall.rotation.y=side*PI*.5
  for edge in [-2.20,2.20]:
   post_on(side_wall,edge,2.83)
  block(side_wall,Vector3(0,.29,.17),Vector3(4.65,.58,.20),stone)
  block(side_wall,Vector3(0,2.76,.14),Vector3(4.68,.24,.21),wood)
  window(side_wall,Vector3(0,1.52,.105),.88,1.16,.27)
  # Recessed window aperture framed by four pieces of wall.
  for data in [[x-.99,1.17,WING_EAVE,WING_EAVE*.5],[x+.99,1.17,WING_EAVE,WING_EAVE*.5],[x,.81,.93,.465],[x,.81,.78,2.46]]:
   block(shell,Vector3(data[0],data[3],2.1),Vector3(data[1],data[2],.24),plaster,true)
  window(shell,Vector3(x,1.55,2.13),.82,1.19,.30)
  base_course(x-1.57,x+1.57,2.17)
  post(side*6.02,2.23,2.83,.26)
  post(side*3.16,2.23,2.83,.26)
  block(shell,Vector3(x,2.75,2.22),Vector3(3.18,.26,.33),wood)
  brace(Vector3(side*6.02,2.05,2.36),-side,.62,.65)
  brace(Vector3(side*3.16,2.05,2.36),side,.54,.65)
  block(shell,Vector3(side*1.95,MAIN_EAVE*.5,FRONT),Vector3(2.10,MAIN_EAVE,.25),plaster,true)
  base_course(minf(side*.91,side*3),maxf(side*.91,side*3),FRONT+.07)
  post(side*2.90,FRONT+.19,MAIN_EAVE,.34)
  brace(Vector3(side*2.90,2.13,FRONT+.32),-side,1.21,1.14)
 for side in [-1.,1.]:
  block(shell,Vector3(side*2.01,MAIN_EAVE*.5,-3.8),Vector3(1.98,MAIN_EAVE,.25),plaster,true)
 block(shell,Vector3(0,.575,-3.8),Vector3(2.05,1.15,.25),plaster,true)
 block(shell,Vector3(0,2.99,-3.8),Vector3(2.05,.72,.25),plaster,true)
 var rear:=Node3D.new()
 shell.add_child(rear)
 rear.position.z=-3.80
 rear.rotation.y=PI
 for x in [-2.89,2.89]:
  post_on(rear,x,MAIN_EAVE)
 block(rear,Vector3(0,.29,.16),Vector3(6.05,.58,.20),stone)
 block(rear,Vector3(0,3.29,.16),Vector3(6.09,.24,.23),wood)
 window(rear,Vector3(0,1.89,.14),2.05,1.47,.36)
 block(shell,Vector3(0,3.27,FRONT+.17),Vector3(6.1,.31,.40),wood)
 polygon(shell,PackedVector2Array([Vector2(-3,3.31),Vector2(3,3.31),Vector2(0,6.85)]),FRONT,plaster)
 polygon(shell,PackedVector2Array([Vector2(-3,3.35),Vector2(3,3.35),Vector2(0,6.85)]),-3.8,plaster)
 polygon(shell,PackedVector2Array([Vector2(-1.70,4.85),Vector2(1.70,4.85),Vector2(0,6.85)]),FRONT+.035,wood)
 block(shell,Vector3(0,4.84,FRONT+.15),Vector3(3.52,.18,.26),wood)
 window(shell,Vector3(0,4.02,FRONT+.08),1.42,1.27,.43)
 # A small feather badge in the boarded gable.
 for i in 6:
  var center:=Vector3((i-2.5)*.106,5.38+(i-2.5)*.055,FRONT+.10)
  var plume:=oval(shell,center,Vector3(.28,.083,.03),color("dccba5"))
  plume.rotation.z=.55
 beam(shell,Vector3(-.35,5.18,FRONT+.14),Vector3(.31,5.52,FRONT+.14),.034,.025,color("e0cda2"))

func arch_points(width: float,height: float) -> PackedVector2Array:
 var r:=width*.5
 var pts:=PackedVector2Array([Vector2(-r,0),Vector2(r,0)])
 for i in 19:
  var a:=PI*float(i)/18.
  pts.append(Vector2(cos(a)*r,height-r+sin(a)*r))
 return pts

func window(parent: Node3D,at: Vector3,width: float,height: float,leaf: float) -> void:
 var node:=Node3D.new()
 parent.add_child(node)
 node.position=at-Vector3.UP*height*.5
 polygon(node,arch_points(width+.24,height+.13),.13,wood)
 var glass:=color("d49d5e").duplicate() as StandardMaterial3D
 glass.emission_enabled=true
 glass.emission=Color("f6bd68")
 glass.emission_energy_multiplier=.36
 glass.cull_mode=BaseMaterial3D.CULL_DISABLED
 glass.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
 glass.albedo_color=Color("e1ac64")
 polygon(node,arch_points(width,height),.15,glass)
 var cloth:=color("ffe0a5").duplicate() as StandardMaterial3D
 cloth.cull_mode=BaseMaterial3D.CULL_DISABLED
 for side in [-1.,1.]:
  var edge: float=side*width*.46
  var middle: float=side*width*.19
  polygon(node,PackedVector2Array([Vector2(edge,height*.66),Vector2(middle,height*.89),Vector2(edge*.69,height*.41),Vector2(edge,height*.30)]),.157,cloth)
 for side in [-1.,1.]:
  var x: float=side*(width*.5+leaf*.5+.09)
  var panel:=block(node,Vector3(x,height*.46,.135),Vector3(leaf,height*.87,.105),shutter)
  panel.rotation.y=side*.13
  for y in [.20,.68]:
   block(node,Vector3(x,height*y,.205),Vector3(leaf+.03,.067,.052),shutter)
   for peg in [-1.,1.]:
    oval(node,Vector3(x+peg*leaf*.29,height*y,.238),Vector3(.044,.044,.023),color("474840"))
 block(node,Vector3(0,height*.47,.207),Vector3(.068,height*.92,.10),wood)
 block(node,Vector3(0,height*.46,.205),Vector3(width,.061,.09),wood)
 block(node,Vector3(0,-.055,.22),Vector3(width+.26,.14,.36),wood)
 block(node,Vector3(0,-.20,.28),Vector3(width+.31,.23,.35),wood)
 for i in 8:
  flowers(node,Vector3(lerpf(-width*.50,width*.50,float(i)/7.),-.08,.44),.66)
 var light:=OmniLight3D.new()
 light.position=Vector3(0,height*.55,.51)
 light.light_color=Color("ffd39b")
 light.light_energy=.16
 light.omni_range=1.9
 node.add_child(light)

func roof_height(x: float,half: float,eave: float,ridge: float) -> float:
 var t:=absf(x)/half
 return lerpf(ridge,eave,t)+sin(t*PI)*.20

func build_roofs() -> void:
 gabled_roof(roof,3.57,MAIN_EAVE-.09,MAIN_RIDGE,-4.14,3.77,false)
 for side in [-1.,1.]:
  var wing:=Node3D.new()
  roof.add_child(wing)
  wing.position=Vector3(side*4.60,0,-.225)
  wing.rotation.y=PI*.5
  gabled_roof(wing,2.69,WING_EAVE,WING_RIDGE,-1.91,1.91,true)
  # Close the outer end under its crosswise roof ridge.
  var end: float=-side*1.55
  polygon(wing,PackedVector2Array([Vector2(-2.325,2.84),Vector2(2.325,2.84),Vector2(0,4.15)]),end,plaster)
  beam(wing,Vector3(-2.40,2.87,end-side*.09),Vector3(2.40,2.87,end-side*.09),.20,.22,wood)

func gabled_roof(parent: Node3D,half: float,eave: float,ridge: float,back: float,front: float,small: bool) -> void:
 var rows:=ceili(half/.44)
 var cols:=ceili((front-back)/.53)
 var run:=(front-back)/float(cols)
 var tile:=BoxMesh.new()
 tile.size=Vector3(1,1,1)
 var batch:=MultiMesh.new()
 batch.transform_format=MultiMesh.TRANSFORM_3D
 batch.use_colors=true
 batch.mesh=tile
 batch.instance_count=2*rows*cols
 var batch_node:=MultiMeshInstance3D.new()
 batch_node.multimesh=batch
 batch_node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var ink:=slate.duplicate() as StandardMaterial3D
 ink.vertex_color_use_as_albedo=true
 batch_node.material_override=ink
 parent.add_child(batch_node)
 var index:=0
 for side in [-1.,1.]:
  for row in rows:
   var a: float=side*half*row/rows
   var b: float=side*half*(row+1)/rows
   var ya:=roof_height(a,half,eave,ridge)
   var yb:=roof_height(b,half,eave,ridge)
   var slope:=Vector2(b-a,yb-ya)
   var angle:=atan2(slope.y*side,slope.x*side)
   var base:=block(parent,Vector3((a+b)*.5,(ya+yb)*.5-.139,(front+back)*.5),Vector3(slope.length()+.04,.16,front-back),slate)
   base.rotation.z=angle
   for col in cols:
    var z:=back+(col+.5)*run
    var size_z:=run-.018
    if row%2==1:
     z+=run*.16 if col<cols-1 else run*.08
     if col==0 or col==cols-1:size_z-=run*.16
    var form:=Basis.from_euler(Vector3(0,0,angle+side*.052)).scaled_local(Vector3(slope.length()+.035,.105,size_z))
    batch.set_instance_transform(index,Transform3D(form,Vector3((a+b)*.5,(ya+yb)*.5+.018,z)))
    var shade:=rng.randf_range(.84,1.18)
    batch.set_instance_color(index,Color(shade,shade,shade))
    index+=1
   for z in ([front,back] if small else [front+.04,back-.04]):
    beam(parent,Vector3(a,ya-.07,z),Vector3(b,yb-.07,z),.22,.25,wood)
  block(parent,Vector3(side*(half-.06),eave-.14,(front+back)*.5),Vector3(.26,.27,front-back+.05),wood)
 for i in cols:
  var cap:=CylinderMesh.new()
  cap.height=run-.018
  cap.top_radius=.19
  cap.bottom_radius=.19
  cap.radial_segments=8
  var node:=mesh_at(parent,cap,Vector3(0,ridge+.04,back+(i+.5)*run),slate)
  node.rotation.x=PI*.5

func build_entry() -> void:
 var door_mat:=wood.duplicate() as StandardMaterial3D
 door_mat.albedo_color=Color("896044")
 var infill:=PackedVector2Array([Vector2(-.90,3.35),Vector2(-.90,1.75)])
 for i in 21:
  var a:=PI*(1.-float(i)/20.)
  infill.append(Vector2(cos(a)*.90,1.76+sin(a)*.90))
 infill.append(Vector2(.90,3.35))
 polygon(shell,infill,FRONT,plaster)
 polygon(shell,arch_points(1.82,2.66),FRONT+.11,door_mat)
 for side in [-1.,1.]:
  for i in 5:
   block(shell,Vector3(side*1.05,.17+i*.345,FRONT+.19),Vector3(.28,.323,.34),stone)
 for i in 12:
  var pts:=PackedVector2Array()
  var a:=PI*(float(i)+.035)/12.
  var b:=PI*(float(i)+.965)/12.
  for point in [Vector2(a,.91),Vector2(b,.91),Vector2(b,1.19),Vector2(a,1.19)]:
   pts.append(Vector2(cos(point.x)*point.y,1.725+sin(point.x)*point.y))
  polygon(shell,pts,FRONT+.38,stone)
  beam(shell,Vector3(cos(a)*1.05,1.725+sin(a)*1.05,FRONT+.25),Vector3(cos(b)*1.05,1.725+sin(b)*1.05,FRONT+.25),.25,.23,stone)
 for i in range(-3,4):
  var x:=float(i)*.228
  beam(shell,Vector3(x,.07,FRONT+.121),Vector3(x,1.75+sqrt(.91*.91-x*x)*.95,FRONT+.121),.022,.012,color("594432"))
 for y in [.34,1.48]:
  block(shell,Vector3(-.39,y,FRONT+.16),Vector3(.91,.095,.062),color("454947"))
 oval(shell,Vector3(.52,1.05,FRONT+.19),Vector3(.16,.19,.095),color("454947"))
 for i in 2:
  for j in 5:
   block(terrace,Vector3((j-2)*.48,.08+i*.12,FRONT+.87-i*.34),Vector3(.466,.16+i*.065,.58),stone,true)
 var lantern:=Vector3(0,2.79,FRONT+.60)
 beam(shell,lantern+Vector3.UP*.14,lantern+Vector3(0,.28,-.45),.052,.064,color("494039"))
 var ember:=color("ffd17e").duplicate() as StandardMaterial3D
 ember.emission_enabled=true
 ember.emission=Color("ffbc58")
 block(shell,lantern,Vector3(.22,.32,.19),ember)
 for y in [-.18,.18]:
  block(shell,lantern+Vector3.UP*y,Vector3(.31,.10,.27),color("494039"))
 for x in [-.119,.119]:
  block(shell,lantern+Vector3(x,0,.093),Vector3(.03,.39,.035),color("494039"))
 var lamp:=OmniLight3D.new()
 lamp.position=lantern+Vector3.BACK*.18
 lamp.light_color=Color("ffc675")
 lamp.omni_range=3.0
 lamp.light_energy=.9
 shell.add_child(lamp)

func oval(parent: Node3D,at: Vector3,size: Vector3,ink: Material) -> MeshInstance3D:
 var mesh:=SphereMesh.new()
 mesh.radial_segments=8
 mesh.rings=5
 var node:=mesh_at(parent,mesh,at,ink)
 node.scale=size
 return node

func flowers(parent: Node3D,at: Vector3,size: float) -> void:
 var stem:=at+Vector3(rng.randf_range(-.08,.08),rng.randf_range(.10,.25),0)*size
 oval(parent,at+Vector3.UP*.05,Vector3(.34,.18,.22)*size,color("536b36"))
 for i in 5:
  var a:=TAU*i/5.
  oval(parent,stem+Vector3(cos(a)*.068,sin(a)*.068,.025)*size,Vector3(.10,.086,.052)*size,color("f7e9cc"))
 oval(parent,stem+Vector3.BACK*.048*size,Vector3(.068,.067,.037)*size,color("d7a342"))

func build_planting() -> void:
 for side in [-1.,1.]:
  var at:=Vector3(side*1.79,.30,FRONT+.67)
  var pot:=CylinderMesh.new()
  pot.height=.60
  pot.top_radius=.33
  pot.bottom_radius=.22
  pot.radial_segments=12
  mesh_at(terrace,pot,at,color("ac835c"))
  for i in 7:
   flowers(terrace,at+Vector3(sin(i*2.4)*.23,.30,cos(i*2.4)*.14),1.08)
  for i in 12:
   var x: float=side*(3.3+i*.25)
   flowers(terrace,Vector3(x,.04,2.46+rng.randf_range(.02,.35)),rng.randf_range(.66,1.1))
  for i in 14:
   var p:=Vector3(side*(2.81+sin(i*.81)*.14),.64+i*.16,FRONT+.42)
   var leaf:=oval(shell,p,Vector3(.30,.13,.065),color("647841"))
   leaf.rotation.z=side*(.42 if i%2 else -.44)
