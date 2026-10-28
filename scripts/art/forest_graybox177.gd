extends Node3D
const PLAN=preload("res://scripts/world/forest_plan177.gd")
var world: Node3D
var cells: Dictionary={}
var fading: Array[MeshInstance3D]=[]
var lanterns: Array[OmniLight3D]=[]
var solids: Array[StaticBody3D]=[]
func ink(color: String,emission := false) -> StandardMaterial3D:
 var m := StandardMaterial3D.new();m.albedo_color=Color(color);m.roughness=1.
 if emission: m.emission_enabled=true;m.emission=Color(color);m.emission_energy_multiplier=1.2
 return m
func mesh(shape: Mesh,at: Vector3,material: Material) -> MeshInstance3D:
 var n := MeshInstance3D.new();n.mesh=shape;n.position=at;n.material_override=material;add_child(n);return n
func body(shape: Shape3D,at: Vector3,layer := 2) -> StaticBody3D:
 var n := StaticBody3D.new();n.position=at;n.collision_layer=layer;n.collision_mask=0
 var c := CollisionShape3D.new();c.shape=shape;n.add_child(c);add_child(n);solids.append(n);return n
func box(size: Vector3,at: Vector3,material: Material,solid := true) -> MeshInstance3D:
 var shape := BoxMesh.new();shape.size=size;var n := mesh(shape,at,material)
 if solid:
  var collision := BoxShape3D.new();collision.size=size;body(collision,at)
 return n
func cylinder(radius: float,height: float,at: Vector3,material: Material,solid := true) -> MeshInstance3D:
 var shape := CylinderMesh.new();shape.top_radius=radius*.85;shape.bottom_radius=radius;shape.height=height;shape.radial_segments=10
 var n := mesh(shape,at,material)
 if solid:
  var c := CylinderShape3D.new();c.radius=radius;c.height=height;body(c,at)
 return n
func label(at: Vector3,words: String,color := "eadfc9") -> void:
 var n := Label3D.new();n.text=words;n.position=at;n.font_size=38;n.pixel_size=.009;n.billboard=BaseMaterial3D.BILLBOARD_ENABLED;n.modulate=Color(color);n.outline_modulate=Color("242937");n.outline_size=7;n.no_depth_test=false;add_child(n)
func floor_mesh() -> void:
 var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for iz in range(-38,26):
  for ix in range(-36,71):
   var key := Vector2i(ix,iz);var center := (Vector2(key)+Vector2.ONE*.5)*PLAN.CELL
   if not PLAN.inside(center): continue
   cells[key]=true
   var a := Vector2(ix,iz)*PLAN.CELL;var b := a+Vector2(PLAN.CELL,0);var c := a+Vector2(0,PLAN.CELL);var d := a+Vector2.ONE*PLAN.CELL
   # Sample each patch from its side of a cliff; never create sloped bridges
   # across the north bank. Only the authored east ramp is walkable there.
   for p in [a,b,c,b,d,c]:
    var y := PLAN.height(p) if center.y> -12. else PLAN.BASE+PLAN.RISE
    if center.y> -12. and p.y<=-12. and center.x<10.: y=PLAN.BASE
    st.add_vertex(Vector3(p.x,y,p.y))
 st.generate_normals();var ground := st.commit();var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/forest_ground177.gdshader")
 mesh(ground,Vector3.ZERO,material);body(ground.create_trimesh_shape(),Vector3.ZERO,1)
 # One collision strip per exposed half-meter edge prevents leaving the finite
 # sandbox; a low curb makes the exact boundary legible without a mountain ring.
 var edge_material := ink("58616a")
 for key: Vector2i in cells:
  for offset in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
   if cells.has(key+offset): continue
   var p := (Vector2(key)+Vector2.ONE*.5)*PLAN.CELL+Vector2(offset)*PLAN.CELL*.5
   var y := PLAN.height((Vector2(key)+Vector2.ONE*.5)*PLAN.CELL)
   var size := Vector3(.10,2.8,.5) if offset.x!=0 else Vector3(.5,2.8,.10)
   var wall := BoxShape3D.new();wall.size=size;body(wall,Vector3(p.x,y+1.4,p.y))
   box(Vector3(size.x,.20,size.z),Vector3(p.x,y+.10,p.y),edge_material,false)
func _ready() -> void:
 position=Vector3(PLAN.CENTER.x,0,PLAN.CENTER.y);name="ForestGraybox177";floor_mesh()
 var bank := ink("657078");var bark := ink("655c65");var roots := ink("7b7279");var foliage := ink("384451");var cottage := ink("938779")
 box(Vector3(27.,PLAN.RISE,1.),Vector3(-3.5,PLAN.BASE+PLAN.RISE*.5,-12.),bank)
 # East ramp's west shoulder blocks sideways clipping, without blocking its ends.
 box(Vector3(.25,1.4,6.5),Vector3(9.85,1.4,-8.6),bank)
 for spec in [Vector4(-13.6,-8.,1.5,2.),Vector4(-13.6,5.,1.,1.6),Vector4(13.7,-1.,1.,1.7)]:
  cylinder(spec.z,spec.w,Vector3(spec.x,PLAN.BASE+spec.w*.5,spec.y),bank)
 var trunk := cylinder(1.65,7.,Vector3(-1.,PLAN.BASE+3.5,0.),bark);fading.append(trunk)
 for spec in [Vector3(-2.3,-1.7,.65),Vector3(-2.5,1.7,.7),Vector3(.5,2.,.6),Vector3(.5,-1.8,.6)]:
  cylinder(spec.z,.65,Vector3(spec.x,PLAN.BASE+.325,spec.y),roots)
 for spec in [Vector3(-2.2,6.6,.5),Vector3(1.2,7.3,-.6),Vector3(-1.,8.1,-1.)]:
  var crown := SphereMesh.new();crown.radius=3.5;crown.height=3.;crown.radial_segments=10;crown.rings=5
  fading.append(mesh(crown,spec,foliage))
 # Blocking shoulders between the bends hide the direct sightline to home.
 box(Vector3(3.,2.6,2.4),Vector3(26.,1.5,4.7),bank)
 box(Vector3(3.,3.0,5.),Vector3(18.,1.7,-1.),bank)
 for p in [Vector2(29.,-6.),Vector2(25.,-.5),Vector2(20.,6.4),Vector2(16.,.5),Vector2(15.,10.7),Vector2(-16.,-7.),Vector2(-16.,3.),Vector2(-9.,14.),Vector2(5.,14.),Vector2(-14.,-16.),Vector2(1.,-16.),Vector2(13.,-16.)]:
  var y := PLAN.height(p);cylinder(.42,6.,Vector3(p.x,y+3.,p.y),bark,false)
  var canopy := SphereMesh.new();canopy.radius=2.7;canopy.height=2.4;canopy.radial_segments=8;canopy.rings=4
  fading.append(mesh(canopy,Vector3(p.x,y+5.6,p.y),foliage))
 var hut := box(Vector3(5.2,2.7,3.6),Vector3(PLAN.COTTAGE.x,1.55,PLAN.COTTAGE.y),cottage);fading.append(hut)
 var roof_ink := ink("76667e")
 for side in [-1.,1.]:
  var roof_node := box(Vector3(3.3,.20,4.2),Vector3(-8.+side*1.4,3.5,-8.8),roof_ink,false);roof_node.rotation_degrees.z=-side*26.;fading.append(roof_node)
 box(Vector3(1.1,1.9,.06),Vector3(-7.,1.15,-6.96),ink("544956"),false)
 box(Vector3(.85,.7,.07),Vector3(-9.,1.8,-6.95),ink("ffc77f",true),false)
 for p in [Vector2(29.,-4.7),Vector2(22.5,4.7),Vector2(15.8,7.5),Vector2(6.,9.5),Vector2(-11.,5.),Vector2(-10.5,-5.5),Vector2(12.5,-15.)]:
  var y := PLAN.height(p);cylinder(.07,1.2,Vector3(p.x,y+.6,p.y),bark,false)
  cylinder(.19,.35,Vector3(p.x,y+1.3,p.y),ink("ffcb8a",true),false)
  var light := OmniLight3D.new();light.position=Vector3(p.x,y+1.5,p.y);light.light_color=Color("ffd8ab");light.light_energy=1.6;light.omni_range=4.;light.shadow_enabled=false;add_child(light);lanterns.append(light)
 label(Vector3(31.,1.4,-5.),"小院方向\n试玩入口")
 label(Vector3(16.,1.5,7.),"很吓人的森林！", "dec8f0")
 label(Vector3(-8.,4.5,-8.8),"蜘蛛姐姐的小屋 · 占位")
 label(Vector3(1.,4.,-14.),"北侧高地 +2.4m")
 label(Vector3(12.1,1.6,-5.5),"缓坡 ↑", "cec0e5")
func _process(delta: float) -> void:
 if not is_instance_valid(world.hero): return
 var target: Vector3=world.hero.global_position+Vector3.UP*.8
 for n in fading:
  var inverse := n.global_transform.affine_inverse()
  var blocked: bool=n.get_aabb().grow(.35).intersects_segment(inverse*world.camera.global_position,inverse*target)!=null
  n.transparency=lerpf(n.transparency,.78 if blocked and not world.overview else 0.,1.-exp(-delta*10.))
