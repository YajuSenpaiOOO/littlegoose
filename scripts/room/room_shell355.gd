extends Node3D
var world: Node3D
var footprints: Array[Dictionary]=[]
var overlay: Node3D
var hour: Node3D
var upper_sand: MeshInstance3D
var lower_sand: MeshInstance3D
var stream: MeshInstance3D
var wardrobe_doors: Array[Node3D]=[]
var materials: Dictionary={}
func material(color: String) -> StandardMaterial3D:
 if materials.has(color):return materials[color]
 var m:=StandardMaterial3D.new();m.albedo_color=Color(color);m.roughness=.88
 materials[color]=m;return m
func shape(parent: Node3D,mesh: Mesh,at: Vector3,mat: Material) -> MeshInstance3D:
 var node:=MeshInstance3D.new();node.mesh=mesh;node.position=at;node.material_override=mat;parent.add_child(node);return node
func box(parent: Node3D,at: Vector3,size: Vector3,color: String) -> MeshInstance3D:
 var mesh:=BoxMesh.new();mesh.size=size;return shape(parent,mesh,at,material(color))
func cylinder(parent: Node3D,at: Vector3,radius: float,height: float,color: String,top: float=-1.) -> MeshInstance3D:
 var mesh:=CylinderMesh.new();mesh.top_radius=radius if top<0. else top;mesh.bottom_radius=radius;mesh.height=height;mesh.radial_segments=24
 return shape(parent,mesh,at,material(color))
func ellipsoid(parent: Node3D,at: Vector3,size: Vector3,color: String) -> MeshInstance3D:
 var mesh:=SphereMesh.new();mesh.radius=.5;mesh.height=1.;var n:=shape(parent,mesh,at,material(color));n.scale=size;return n
func collider(parent: Node3D,at: Vector3,size: Vector3) -> StaticBody3D:
 var body:=StaticBody3D.new();body.position=at;body.collision_layer=1;body.collision_mask=0
 var collision:=CollisionShape3D.new();var mesh:=BoxShape3D.new();mesh.size=size;collision.shape=mesh;body.add_child(collision);parent.add_child(body);return body
func prop(id: String,at: Vector2,size: Vector2,height: float,title: String,approach: Vector2) -> Node3D:
 var root:=Node3D.new();root.name=id;root.position=Vector3(at.x,0.,at.y);add_child(root)
 collider(root,Vector3(0.,height*.5,0.),Vector3(size.x,height,size.y))
 footprints.append({"id":id,"at":at,"size":size,"height":height,"root":root,"title":title,"approach":approach})
 return root
func lamp(parent: Node3D,at: Vector3) -> void:
 cylinder(parent,at+Vector3.UP*.03,.16,.06,"735035")
 cylinder(parent,at+Vector3.UP*.24,.025,.45,"b78a42")
 cylinder(parent,at+Vector3.UP*.53,.28,.30,"f0cf8d",.16)
 var light:=OmniLight3D.new();light.position=at+Vector3.UP*.48;light.light_color=Color("ffd394");light.light_energy=.55;light.omni_range=3.5;light.shadow_enabled=true;parent.add_child(light)
func _ready() -> void:
 build_shell();build_furniture();build_hourglass();build_overlay()
func build_shell() -> void:
 var floor_mat:=ShaderMaterial.new();floor_mat.shader=preload("res://scripts/room/floor355.gdshader");floor_mat.set_shader_parameter("wood",load("res://assets/garden45/wood.png"))
 var floor_mesh:=PlaneMesh.new();floor_mesh.size=Vector2(12.6,8.8)
 shape(self,floor_mesh,Vector3.ZERO,floor_mat)
 box(self,Vector3(0.,-.22,0.),Vector3(12.9,.42,9.1),"73513b")
 collider(self,Vector3(0.,-.15,0.),Vector3(12.9,.3,9.1))
 # Rear wall has an actual window opening; lower sill stops actors walking through it.
 for data in [[Vector3(-4.2,1.8,-4.5),Vector3(4.4,3.6,.22)],[Vector3(3.65,1.8,-4.5),Vector3(5.3,3.6,.22)],[Vector3(-.5,.6,-4.5),Vector3(3.,1.2,.22)],[Vector3(-.5,3.2,-4.5),Vector3(3.,.8,.22)]]:
  box(self,data[0],data[1],"dfc8a4");collider(self,data[0],data[1])
 for side in [-1.,1.]:
  # Tall walls only at the back; front half is permanently cut away visually.
  box(self,Vector3(side*6.4,1.8,-2.45),Vector3(.22,3.6,4.2),"dac19c")
  box(self,Vector3(side*6.4,.28,2.),Vector3(.22,.56,4.7),"b29673")
  collider(self,Vector3(side*6.4,1.7,0.),Vector3(.22,3.4,9.))
  box(self,Vector3(side*6.24,.12,0.),Vector3(.09,.24,8.8),"805a3c")
 for x in [-3.75,3.75]:
  box(self,Vector3(x,.19,4.5),Vector3(5.3,.38,.20),"96704c")
  collider(self,Vector3(x,1.3,4.5),Vector3(5.3,2.6,.2))
 box(self,Vector3(0.,-.12,5.25),Vector3(2.1,.24,1.5),"ad8055");collider(self,Vector3(0.,-.12,5.25),Vector3(2.1,.24,1.5))
 for x in [-1.12,1.12]:
  box(self,Vector3(x,.45,4.5),Vector3(.18,.9,.24),"8e6542")
  collider(self,Vector3(x,1.,5.25),Vector3(.16,2.,1.5))
 collider(self,Vector3(0.,.8,6.05),Vector3(2.4,1.6,.16))
 # Separate real beams/sill, not perspective baked into a background image.
 box(self,Vector3(0.,3.5,-4.25),Vector3(12.6,.22,.28),"795337")
 for x in [-6.1,-2.1,1.1,6.1]:box(self,Vector3(x,1.8,-4.27),Vector3(.16,3.6,.19),"87613f")
 box(self,Vector3(0.,.12,-4.3),Vector3(12.6,.24,.1),"805a3c")
 var view:=QuadMesh.new();view.size=Vector2(3.,1.6)
 var sky:=StandardMaterial3D.new();sky.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;sky.albedo_texture=load("res://assets/forest_region71/wooded_ridge.png");sky.albedo_color=Color(.78,.88,.77);sky.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
 var backdrop:=StandardMaterial3D.new();backdrop.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;backdrop.albedo_color=Color("bed6d1")
 shape(self,view,Vector3(-.5,2.,-4.65),backdrop)
 shape(self,view,Vector3(-.5,2.,-4.6),sky)
 for x in [-2.02,1.02,-.5]:box(self,Vector3(x,2.,-4.25),Vector3(.10,1.65,.15),"957044")
 for y in [1.18,2.,2.82]:box(self,Vector3(-.5,y,-4.25),Vector3(3.15,.1,.18),"957044")
 for x in [-1.84,.84]:
  box(self,Vector3(x,2.04,-4.10),Vector3(.48,1.65,.13),"8d9b75")
  box(self,Vector3(x,1.78,-4.01),Vector3(.53,.11,.16),"d9c28f")
 var rug:=PlaneMesh.new();rug.size=Vector2(4.5,2.65)
 var fabric:=ShaderMaterial.new();fabric.shader=preload("res://scripts/room/rug355.gdshader")
 shape(self,rug,Vector3(0.,.013,.55),fabric)
func build_furniture() -> void:
 var bed:=prop("bed",Vector2(-4.25,-2.6),Vector2(2.55,3.),.72,"小白鹅的床",Vector2(-4.2,-.55))
 box(bed,Vector3(0.,.30,0.),Vector3(2.55,.5,3.),"856449")
 box(bed,Vector3(0.,.64,.04),Vector3(2.4,.24,2.8),"e6ddc8")
 box(bed,Vector3(0.,.82,.4),Vector3(2.44,.15,1.95),"e7ddc2")
 box(bed,Vector3(0.,.92,.70),Vector3(2.45,.08,.7),"91a184")
 box(bed,Vector3(0.,1.08,-1.38),Vector3(2.6,1.5,.13),"a17c51")
 for x in [-1.25,1.25]:ellipsoid(bed,Vector3(x,1.86,-1.39),Vector3(.19,.19,.19),"b28c58")
 ellipsoid(bed,Vector3(0.,.88,-.85),Vector3(1.9,.25,.65),"f3ead5")
 for z in [-.05,.45,.95]:
  for x in [-.9,-.3,.3,.9]:box(bed,Vector3(x,.911,z),Vector3(.025,.013,.4),"d1bda1")
 var nest:=prop("nest",Vector2(-4.7,1.0),Vector2(1.65,1.45),.5,"小黑鹅的软窝",Vector2(-3.35,1.))
 cylinder(nest,Vector3(0.,.13,0.),.79,.26,"795c43")
 ellipsoid(nest,Vector3(0.,.36,0.),Vector3(1.4,.35,1.2),"8a6d85")
 ellipsoid(nest,Vector3(0.,.5,-.38),Vector3(.8,.16,.35),"e0cbbd")
 box(nest,Vector3(.22,.54,.22),Vector3(.85,.05,.55),"b79ab1")
 var desk:=prop("desk",Vector2(-.5,-3.55),Vector2(2.5,1.15),1.18,"书桌",Vector2(-.5,-1.35))
 box(desk,Vector3(0.,1.12,0.),Vector3(2.6,.16,1.2),"a87e50")
 for x in [-1.08,1.08]:
  for z in [-.43,.43]:box(desk,Vector3(x,.54,z),Vector3(.11,1.08,.11),"805b3b")
 box(desk,Vector3(.7,.93,.1),Vector3(.72,.29,.8),"96724c")
 cylinder(desk,Vector3(.7,.93,.515),.045,.035,"d0ad64").rotation_degrees.x=90.
 box(desk,Vector3(-.2,1.22,.10),Vector3(.65,.04,.43),"eee0ba")
 lamp(desk,Vector3(-.94,1.2,-.13))
 var chair:=prop("desk_chair",Vector2(-.5,-2.30),Vector2(.65,.65),.8,"书桌椅",Vector2(-.5,-1.35))
 box(chair,Vector3(0.,.58,0.),Vector3(.65,.14,.65),"8c6946")
 box(chair,Vector3(0.,.67,0.),Vector3(.60,.06,.6),"94a082")
 box(chair,Vector3(0.,.96,.29),Vector3(.66,.72,.09),"9f7a4f")
 for x in [-.25,.25]:
  for z in [-.25,.25]:box(chair,Vector3(x,.27,z),Vector3(.08,.54,.08),"89643f")
 var wardrobe:=prop("wardrobe",Vector2(2.15,-3.65),Vector2(1.5,1.22),2.55,"小衣柜",Vector2(2.15,-2.25))
 box(wardrobe,Vector3(0.,1.28,0.),Vector3(1.5,2.55,1.22),"8c6c4b")
 for x in [-.37,.37]:
  box(wardrobe,Vector3(x,1.34,.63),Vector3(.7,2.27,.055),"ac8b62")
  box(wardrobe,Vector3(x,1.36,.665),Vector3(.55,1.90,.025),"bca17a")
  cylinder(wardrobe,Vector3(signf(x)*.1,1.30,.71),.035,.035,"d7b45e").rotation_degrees.x=90.
 box(wardrobe,Vector3(0.,2.60,0.),Vector3(1.65,.16,1.3),"9c7850")
 # Books leave the wardrobe footprint clear: small wall shelves above the desk.
 for shelf in [Vector2(-4.2,2.48),Vector2(-.5,3.)]:
  var board:=box(self,Vector3(shelf.x,shelf.y,-4.08),Vector3(2.65,.08,.40),"946d47")
  if shelf.x< -2.:board.name="BedWallShelf355"
  for i in 8:
   var book:=box(self,Vector3(shelf.x-1.1+i*.27,shelf.y+.2,-4.10),Vector3(.16,.32+float(i%3)*.07,.26),["899977","b5967a","957681"][i%3])
   if shelf.x< -2.:book.name="BedWallBook355_%d"%i
 var wash:=prop("wash",Vector2(5.65,-.05),Vector2(1.0,1.55),1.03,"洗漱柜",Vector2(4.55,-.05))
 box(wash,Vector3(0.,.5,0.),Vector3(1.,1.,1.55),"9aa387")
 box(wash,Vector3(0.,1.04,0.),Vector3(1.10,.1,1.65),"d9c7a3")
 ellipsoid(wash,Vector3(-.08,1.12,-.12),Vector3(.72,.13,.85),"e9dfc7")
 for z in [-.42,.25]:box(wash,Vector3(-.53,.74,z),Vector3(.04,.44,.46),"b7bea4")
 var tea:=prop("tea",Vector2(3.8,1.9),Vector2(1.35,1.35),.95,"两个人的茶桌",Vector2(3.8,3.1))
 cylinder(tea,Vector3(0.,.94,0.),.78,.12,"b28e61")
 cylinder(tea,Vector3(0.,.47,0.),.12,.88,"8c6843")
 cylinder(tea,Vector3(0.,.06,0.),.48,.12,"967149")
 for data in [[Vector3(-.34,1.1,.1),.13],[Vector3(.35,1.07,.1),.085]]:
  cylinder(tea,data[0],data[1],float(data[1])*1.2,"f1e2c0")
  cylinder(tea,data[0]+Vector3.UP*float(data[1])*.61,float(data[1])*.77,.012,"78533a")
 for id in ["tea_chair","goose_stool"]:
  var small: bool=id=="goose_stool"
  var root:=prop(id,Vector2(5.15 if small else 2.6,1.9),Vector2(.58,.58),.35 if small else .6,"小凳子" if small else "茶桌椅",Vector2(3.8,3.1))
  cylinder(root,Vector3(0.,.32 if small else .58,0.),.32,.12,"8f7590" if small else "91a284")
  cylinder(root,Vector3(0.,.15 if small else .28,0.),.1,.3 if small else .55,"957049")
 # Two sets of belongings at the nest and bed, no extra collision for small dressing.
 cylinder(self,Vector3(-3.8,.08,1.8),.15,.16,"e5dbc6")
 cylinder(self,Vector3(-4.3,.045,1.9),.22,.07,"dcc59b")
 var side:=prop("bedside",Vector2(-5.8,-3.4),Vector2(.58,.68),.72,"床头灯",Vector2(-6.,-2.5))
 box(side,Vector3(0.,.36,0.),Vector3(.58,.72,.68),"a17f55");lamp(side,Vector3(0.,.72,0.))
func build_hourglass() -> void:
 hour=prop("hourglass",Vector2(4.55,-2.75),Vector2(1.4,1.4),2.18,"时光沙漏",Vector2(4.55,-1.35))
 cylinder(hour,Vector3(0.,.13,0.),.73,.26,"916d46")
 cylinder(hour,Vector3(0.,.31,0.),.57,.10,"c6a35b")
 cylinder(hour,Vector3(0.,2.08,0.),.57,.10,"cfb36c")
 for angle in [0.,PI*.5,PI,PI*1.5]:
  var at:=Vector3(cos(angle)*.51,1.2,sin(angle)*.51)
  cylinder(hour,at,.035,1.72,"d7bd78")
  ellipsoid(hour,at+Vector3.UP*.83,Vector3(.13,.13,.13),"e1c885")
 var profiles=[Vector2(.31,.41),Vector2(.39,.55),Vector2(.38,.72),Vector2(.28,.94),Vector2(.055,1.23),Vector2(.28,1.53),Vector2(.39,1.76),Vector2(.38,1.94),Vector2(.31,2.01)]
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for j in range(profiles.size()-1):
  for i in 48:
   var a:=TAU*float(i)/48.;var b:=TAU*float(i+1)/48.
   var p: Vector2=profiles[j];var q: Vector2=profiles[j+1]
   for v in [Vector3(cos(a)*p.x,p.y,sin(a)*p.x),Vector3(cos(b)*p.x,p.y,sin(b)*p.x),Vector3(cos(b)*q.x,q.y,sin(b)*q.x),Vector3(cos(a)*p.x,p.y,sin(a)*p.x),Vector3(cos(b)*q.x,q.y,sin(b)*q.x),Vector3(cos(a)*q.x,q.y,sin(a)*q.x)]:st.add_vertex(v)
 st.generate_normals()
 var glass:=StandardMaterial3D.new();glass.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;glass.albedo_color=Color(.72,.87,.91,.16);glass.cull_mode=BaseMaterial3D.CULL_DISABLED;glass.roughness=.13
 var g:=shape(hour,st.commit(),Vector3.ZERO,glass);g.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 upper_sand=cylinder(hour,Vector3(0.,1.57,0.),.04,.48,"e4bd62",.29)
 lower_sand=cylinder(hour,Vector3(0.,.62,0.),.30,.32,"e4bd62",.015)
 stream=cylinder(hour,Vector3(0.,1.12,0.),.009,.64,"f6d686")
 var gold:=material("f6d686");gold.emission_enabled=true;gold.emission=Color("e0ac48");gold.emission_energy_multiplier=.4
 cylinder(hour,Vector3(0.,2.17,0.),.11,.13,"d6b46a",.20)
 var lid:=cylinder(hour,Vector3(.2,2.25,-.04),.15,.035,"cba65b");lid.rotation_degrees.z=-35.
 var glow:=OmniLight3D.new();glow.position=Vector3(0.,1.2,.3);glow.light_color=Color("ffe2a4");glow.light_energy=.25;glow.omni_range=2.8;hour.add_child(glow)
 # Two small sand vials on their own shelf beside the hourglass.
 cylinder(hour,Vector3(.96,.82,0.),.26,.08,"ac895c");cylinder(hour,Vector3(.96,.4,0.),.035,.8,"967149")
 for x in [.86,1.08]:
  cylinder(hour,Vector3(x,1.,0.),.065,.25,"ddc67a");cylinder(hour,Vector3(x,1.15,0.),.07,.05,"987345")
func build_overlay() -> void:
 overlay=Node3D.new();overlay.name="Footprints";add_child(overlay)
 var ink:=StandardMaterial3D.new();ink.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;ink.albedo_color=Color(.5,.95,.8,.35);ink.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA
 for row in footprints:
  var mesh:=PlaneMesh.new();mesh.size=row.size
  shape(overlay,mesh,Vector3(row.at.x,.028,row.at.y),ink)
 overlay.hide()
