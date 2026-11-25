extends "res://scripts/room/furniture_model396.gd"
var kind398:=""
var details398: StandardMaterial3D
var sage398: StandardMaterial3D
func build398(kind: String) -> void:
 kind398=kind;name="Solid398_"+kind
 wood396=ShaderMaterial.new();wood396.shader=preload("res://scripts/room/wood395.gdshader")
 wood396.set_shader_parameter("paint",preload("res://assets/room398/cabinet-atlas.png"))
 sage398=paint398("cabinet-atlas.png",Color(.72,.76,.80))
 details398=paint398("details-atlas.png",Color(.66,.69,.72))
 if kind=="wardrobe":wardrobe398()
 else:wash398();rotation_degrees.y=-90.
func paint398(file: String,tint: Color) -> StandardMaterial3D:
 var m:=plain396("ffffff");m.albedo_texture=load("res://assets/room398/"+file);m.albedo_color=tint
 m.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS;return m
func leg398(at: Vector3,height: float,radius: float) -> void:
 var profile: Array[Vector2]=[Vector2(radius*.8,.008),Vector2(radius,.04),Vector2(radius*.95,.10),Vector2(radius*.75,height*.7),Vector2(radius,height)]
 legs396.append(piece396(lathe396(profile,Vector2i.ZERO),at,wood396,"CabinetFoot"))
func knob398(at: Vector3,ring: bool=false) -> void:
 var sphere:=SphereMesh.new();sphere.radius=.03;sphere.height=.06
 piece396(sphere,at,brass396,"AntiqueBrassPullBase")
 if ring:
  var points: Array[Vector3]=[]
  for i in 25:
   var a: float=TAU*float(i)/24.;points.append(at+Vector3(cos(a)*.035,-.03+sin(a)*.045,.025))
  tube396(points,.008,brass396,"BrassPullRing")
func wardrobe398() -> void:
 for x in [-.58,.58]:
  for z in [-.43,.43]:leg398(Vector3(x,0,z),.32,.066)
 piece396(rounded_box396(Vector3(1.40,2.08,1.08),.035),Vector3(0,1.36,0),wood396,"WardrobeBody")
 piece396(rounded_box396(Vector3(1.48,.15,1.16),.025),Vector3(0,.33,0),wood396,"RaisedBasePlinth")
 for x in [-.34,.34]:
  piece396(rounded_box396(Vector3(.63,1.88,.075),.022,Vector2i.ZERO,Vector2i(1,0)),Vector3(x,1.43,.565),wood396,"ArchedFeatherDoor")
  knob398(Vector3(signf(x)*.11,1.29,.63),true)
 for x in [-.67,0.,.67]:piece396(rounded_box396(Vector3(.055,1.99,.085),.012),Vector3(x,1.43,.566),wood396,"DoorFrameStile")
 piece396(rounded_box396(Vector3(1.52,.13,1.20),.025),Vector3(0,2.43,0),wood396,"RoundedCorniceLower")
 piece396(rounded_box396(Vector3(1.58,.09,1.24),.023),Vector3(0,2.53,0),wood396,"RoundedCorniceTop")
 piece396(rounded_box396(Vector3(1.47,.055,1.13),.015),Vector3(0,2.60,0),wood396,"CorniceCap")
func countertop398() -> ArrayMesh:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 # Real annulus: no solid slab behind the basin that would fill its hollow.
 for i in 64:
  var a: float=TAU*float(i)/64.;var b: float=TAU*float(i+1)/64.
  var oa:=Vector3(signf(cos(a))*pow(absf(cos(a)),.5)*.80,1.10,signf(sin(a))*pow(absf(sin(a)),.5)*.49)
  var ob:=Vector3(signf(cos(b))*pow(absf(cos(b)),.5)*.80,1.10,signf(sin(b))*pow(absf(sin(b)),.5)*.49)
  var ia:=Vector3(cos(a)*.35,1.10,sin(a)*.245);var ib:=Vector3(cos(b)*.35,1.10,sin(b)*.245)
  for p in [oa,ib,ia,oa,ob,ib]:vertex396(st,p,Vector3.UP,Vector2(p.x/1.6+.5,p.z/.98+.5),Vector2i(1,1))
  var normal:=Vector3(oa.x,0,oa.z).normalized()
  for p in [oa,oa-Vector3(0,.08,0),ob-Vector3(0,.08,0),oa,ob-Vector3(0,.08,0),ob]:vertex396(st,p,normal,Vector2(.5,.5),Vector2i(1,1))
 return st.commit()
func towel398(at: Vector3,width: float,height: float,tile: Vector2i) -> void:
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for j in 12:
  for i in 12:
   for ij in [Vector2i(i,j),Vector2i(i+1,j),Vector2i(i+1,j+1),Vector2i(i,j),Vector2i(i+1,j+1),Vector2i(i,j+1)]:
    var u: float=float(ij.x)/12.;var v: float=float(ij.y)/12.
    var p:=at+Vector3((u-.5)*width,-v*height,.015*cos(u*TAU*2.)*(.3+.7*v))
    vertex396(st,p,Vector3.BACK,Vector2(u,v),tile)
 var mat:=details398.duplicate() as StandardMaterial3D;mat.cull_mode=BaseMaterial3D.CULL_DISABLED
 var n:=piece396(st.commit(),Vector3.ZERO,mat,"EmbroideredTowel");n.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
func wash398() -> void:
 for x in [-.61,.61]:
  for z in [-.33,.33]:leg398(Vector3(x,0,z),.24,.047)
 # Hollow cabinet carcass lets the real basin extend below the countertop.
 for x in [-.68,.68]:piece396(rounded_box396(Vector3(.075,.82,.84),.018,Vector2i(0,1)),Vector3(x,.60,0),sage398,"SageCabinetSide")
 piece396(rounded_box396(Vector3(1.35,.78,.06),.015,Vector2i(0,1)),Vector3(0,.60,-.40),sage398,"CabinetBack")
 piece396(rounded_box396(Vector3(1.43,.10,.90),.02),Vector3(0,.22,0),wood396,"WashBaseRail")
 for x in [-.34,.34]:
  piece396(rounded_box396(Vector3(.62,.72,.065),.016,Vector2i(0,1)),Vector3(x,.62,.43),sage398,"SageLeafDoor")
  knob398(Vector3(signf(x)*.12,.83,.48))
 piece396(countertop398(),Vector3.ZERO,details398,"CountertopWithBasinOpening")
 var ceramic:=plain396("c9bfaa")
 var basin:=piece396(lathe396([Vector2(.04,.88),Vector2(.18,.91),Vector2(.29,1.02),Vector2(.34,1.10),Vector2(.36,1.10),Vector2(.36,1.12),Vector2(.335,1.12),Vector2(.29,1.055),Vector2(.21,.97),Vector2(.08,.925),Vector2(.02,.925)],Vector2i.ZERO,false),Vector3.ZERO,ceramic,"HollowIvoryBasin")
 basin.scale.z=.74
 piece396(lathe396([Vector2(.028,.925),Vector2(.028,.929)],Vector2i.ZERO),Vector3.ZERO,plain396("655a46"),"BasinDrain")
 tube396([Vector3(0,1.11,-.35),Vector3(0,1.36,-.35),Vector3(0,1.46,-.28),Vector3(0,1.46,-.15),Vector3(0,1.38,-.08)],.019,brass396,"GooseneckTap")
 for x in [-.09,.09]:
  piece396(lathe396([Vector2(.035,1.10),Vector2(.028,1.16)],Vector2i.ZERO),Vector3(x,0,-.35),brass396,"TapHandle")
 # Quiet, matte backsplash, then two real towels mounted on a wall-side rail.
 piece396(rounded_box396(Vector3(1.48,.14,.055),.015),Vector3(0,1.14,-.465),wood396,"LowBacksplash")
 tube396([Vector3(-.53,1.82,-.49),Vector3(.53,1.82,-.49)],.016,brass396,"TowelRail")
 for x in [-.52,.52]:tube396([Vector3(x,1.82,-.55),Vector3(x,1.82,-.49)],.023,brass396,"RailWallMount")
 towel398(Vector3(-.24,1.81,-.455),.36,.47,Vector2i.ZERO)
 towel398(Vector3(.23,1.81,-.455),.29,.42,Vector2i(1,0))
 towel398(Vector3(.06,1.105,.506),.43,.28,Vector2i.ZERO)
 piece396(lathe396([Vector2(.075,0),Vector2(.12,.014),Vector2(.12,.028)],Vector2i(0,1)),Vector3(.55,1.105,.20),details398,"SoapDish")
 piece396(rounded_box396(Vector3(.15,.04,.075),.012),Vector3(.55,1.15,.20),plain396("c9b88d"),"SoapBar")
 var jug_at:=Vector3(-.55,1.10,-.10)
 piece396(lathe396([Vector2(.065,0),Vector2(.10,.045),Vector2(.10,.17),Vector2(.07,.23),Vector2(.09,.26)],Vector2i(0,1)),jug_at,details398,"LeafPitcher")
 var handle: Array[Vector3]=[]
 for i in 17:
  var a: float=-PI*.5+PI*float(i)/16.;handle.append(jug_at+Vector3(-.075-.075*cos(a),.13+.085*sin(a),0))
 tube396(handle,.012,details398,"PitcherHandle",Vector2i(0,1))
