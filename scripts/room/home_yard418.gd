extends "res://scripts/room/home_yard417.gd"

var permanent418: Node3D
var built_roofs418: Array[Node3D] = []
const FRONT418 := 3.12
const WING418 := 1.95

func foundation414() -> void:
 # Ancestor construction calls this more than once. Build the new plinth once.
 pass

func build_house404(room: Node3D) -> void:
 super.build_house404(room)
 built_roofs418 = built_roofs418.filter(func(node): return is_instance_valid(node))
 facade403.name = "FrontAndRoof418"
 permanent418 = Node3D.new()
 permanent418.name = "SharedHouseWalls418"
 add_child(permanent418)
 for part in facade403.get_children():
  if part is MeshInstance3D and absf(absf(part.position.x)-6.51)<.01 and part.position.z<0:
   part.reparent(permanent418)
  elif part is MeshInstance3D and is_equal_approx(part.position.z,-4.76):
   part.queue_free()
 box413(Vector3(0,1.95,-4.76),Vector3(7.0,3.90,.20),plaster413,permanent418)
 # The previous right-hand prototype left a blocker ahead of the new wing.
 for body in get_children():
  if body is StaticBody3D and body.position.is_equal_approx(Vector3(4.37,1.70,3.46)):
   body.free()
 for side in [-1.,1.]:
  box413(Vector3(side*5.02,1.57,-4.76),Vector3(3.05,3.14,.20),plaster413,permanent418)
  box413(Vector3(side*3.5,1.85,2.53),Vector3(.20,3.7,1.18),plaster413)
  box413(Vector3(side*3.30,1.94,3.32),Vector3(.40,3.88,.48),wood413)
  box413(Vector3(side*3.30,.40,3.42),Vector3(.62,.78,.68),stone413)
  box413(Vector3(side*3.30,3.72,3.41),Vector3(.57,.27,.55),wood413)
  var brace: Array[Vector2] = []
  for i in 17:
   var t := float(i)/16.
   brace.append(Vector2(side*(3.28-.95*t*t),2.68+1.06*t))
  curve414(brace,.27,.34,3.49,wood413)
  plinth418(side*2.30,2.38,FRONT418)
  plinth418(side*5.02,2.99,WING418+.38)
  vine413(Vector3(side*3.18,.82,3.58),2.65 if side>0 else 1.78)
  for i in 5:
   flower413(Vector3(side*(4.05+i*.34),.20+float(i%2)*.07,2.42),.80)
 carving414(Vector3(0,5.91,3.28),1.24)
 for window in windows414:
  var depth: float = window.glass + .024
  curtain418(window,depth)
 print("HOME418_READY fronts/roof cut away independently, permanent walls=",permanent418.get_child_count())

func window413(at: Vector3,width: float,height: float) -> void:
 super.window413(at,width,height)
 windows414.back().merge({"at":at,"width":width,"height":height})

func curtain418(window: Dictionary,depth: float) -> void:
 var at: Vector3 = window.at
 var width: float = window.width
 var height: float = window.height
 var cloth: StandardMaterial3D = kit.material("d5c49a").duplicate()
 cloth.cull_mode = BaseMaterial3D.CULL_DISABLED
 var st := SurfaceTool.new()
 st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for side in [-1.,1.]:
  var x: float = side*width*.43
  quad404(st,[Vector3(at.x+x,at.y+height*.10,depth),Vector3(at.x+x*.30,at.y+height*.15,depth),Vector3(at.x+x*.67,at.y-height*.36,depth),Vector3(at.x+x,at.y-height*.45,depth)])
 st.generate_normals()
 kit.shape(facade403,st.commit(),Vector3.ZERO,cloth)

func plinth418(center: float,width: float,front: float) -> void:
 box413(Vector3(center,.32,front+.05),Vector3(width,.64,.35),kit.material("736c57"))
 for row in 2:
  var count := 4 + row
  var step := width/float(count)
  for i in count:
   var x := center-width*.5+(i+.5)*step
   stone414(Vector3(x,.15+row*.29,front+.20+float(i%3)*.018),Vector3(step-.025,.29,.41))
 box413(Vector3(center,.62,front+.13),Vector3(width,.10,.42),stone413)

func roof_y418(x: float,half: float,eave: float,peak: float) -> float:
 var t := clampf(absf(x)/half,0.,1.)
 return lerpf(peak,eave,t)+sin(PI*t)*.19

func mass415(center: float,width: float,eave: float,peak: float,front: float,back: float) -> void:
 masses415 += 1
 var roof_root := Node3D.new()
 roof_root.name = "Roof418"
 facade403.add_child(roof_root)
 built_roofs418.append(roof_root)
 var half := width*.5
 var overhang := .36
 var deck := SurfaceTool.new()
 deck.begin(Mesh.PRIMITIVE_TRIANGLES)
 var gables := SurfaceTool.new()
 gables.begin(Mesh.PRIMITIVE_TRIANGLES)
 for side in [-1.,1.]:
  var trim: Array[Vector2] = []
  for i in 21:
   var x: float = side*(half+overhang)*i/20.
   trim.append(Vector2(center+x,roof_y418(x,half+overhang,eave-.17,peak)))
  curve414(trim,.29,.34,front+.55,wood413)
  for i in 20:
   var a := trim[i]
   var b := trim[i+1]
   quad404(deck,[Vector3(a.x,a.y,front+.63),Vector3(b.x,b.y,front+.63),Vector3(b.x,b.y,back-.36),Vector3(a.x,a.y,back-.36)])
   var left: float = side*half*i/20.
   var right: float = side*half*(i+1)/20.
   for z in [front,back]:
    quad404(gables,[Vector3(center+left,eave-.10,z),Vector3(center+right,eave-.10,z),Vector3(center+right,roof_y418(right,half,eave,peak)-.06,z),Vector3(center+left,roof_y418(left,half,eave,peak)-.06,z)])
  box413(Vector3(center+side*(half+.23),eave-.21,(front+back)*.5),Vector3(.28,.26,front-back+.72),wood413,roof_root)
  for i in 5:
   var z := lerpf(back,front,float(i)/4.)
   box413(Vector3(center+side*(half+.18),eave-.36,z),Vector3(.48,.16,.15),wood413,roof_root)
 deck.generate_normals()
 gables.generate_normals()
 kit.shape(roof_root,deck.commit(),Vector3.ZERO,slate413)
 kit.shape(roof_root,gables.commit(),Vector3.ZERO,plaster413)
 var rows := ceili(half/.59)
 var cols := ceili((front-back+.55)/.62)
 var tiles := MultiMesh.new()
 tiles.transform_format = MultiMesh.TRANSFORM_3D
 tiles.use_colors = true
 tiles.mesh = tile_mesh413()
 tiles.instance_count = rows*cols*2
 var tile_node := MultiMeshInstance3D.new()
 tile_node.multimesh = tiles
 var ink: StandardMaterial3D = slate413.duplicate()
 ink.albedo_color = Color(1.06,1.01,.99)
 ink.vertex_color_use_as_albedo = true
 tile_node.material_override = ink
 roof_root.add_child(tile_node)
 var index := 0
 for side in [-1.,1.]:
  for row in rows:
   var x: float = side*(row+.5)*(half+.18)/rows
   var y := roof_y418(x,half+overhang,eave-.17,peak)
   var slope := (roof_y418(x+.06,half+overhang,eave-.17,peak)-roof_y418(x-.06,half+overhang,eave-.17,peak))/.12
   for col in cols:
    var z := lerpf(back-.03,front+.28,float(col)/float(cols-1))+.07*(row%2)
    var basis := Basis.from_euler(Vector3(0,0,atan(slope))).scaled(Vector3(.95,1.24,.80))
    tiles.set_instance_transform(index,Transform3D(basis,Vector3(center+x,y+.13,z)))
    var shade := .86+float((row*31+col*13)%9)*.024
    tiles.set_instance_color(index,Color(shade,shade,shade))
    index+=1
 for i in cols:
  var z := lerpf(back-.10,front+.44,float(i)/float(cols-1))
  box413(Vector3(center,peak+.13,z),Vector3(.31,.21,.67),slate413,roof_root)
