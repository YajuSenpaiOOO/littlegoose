extends Node3D
const PLAN=preload("res://scripts/world/forest_plan183.gd")
var world: Node3D
var cells: Dictionary={}
var solids: Array[StaticBody3D]=[]
var fading: Array[Dictionary]=[]
var trees: Array[Sprite3D]=[]
var ribbons: Array[MeshInstance3D]=[]
var stair_treads: Array[MeshInstance3D]=[]
var cottage_sprite: Sprite3D
var alpha_bounds := Rect2i()
func ink(color: String,glow := false) -> StandardMaterial3D:
 var m := StandardMaterial3D.new();m.albedo_color=Color(color);m.roughness=1.
 if glow: m.emission_enabled=true;m.emission=Color(color);m.emission_energy_multiplier=.7
 return m
func mesh(shape: Mesh,at: Vector3,material: Material) -> MeshInstance3D:
 var n := MeshInstance3D.new();n.mesh=shape;n.position=at;n.material_override=material;add_child(n);return n
func body(shape: Shape3D,at: Vector3,layer := 2) -> StaticBody3D:
 var n := StaticBody3D.new();n.position=at;n.collision_layer=layer;n.collision_mask=0
 var c := CollisionShape3D.new();c.shape=shape;n.add_child(c);add_child(n);solids.append(n);return n
func box(size: Vector3,at: Vector3,material: Material,solid := false) -> MeshInstance3D:
 var shape := BoxMesh.new();shape.size=size;var n := mesh(shape,at,material)
 if solid:
  var c := BoxShape3D.new();c.size=size;body(c,at)
 return n
func cylinder(radius: float,height: float,at: Vector3,material: Material,solid := true) -> MeshInstance3D:
 var shape := CylinderMesh.new();shape.top_radius=radius*.8;shape.bottom_radius=radius;shape.height=height;shape.radial_segments=10;var n := mesh(shape,at,material)
 if solid:
  var c := CylinderShape3D.new();c.radius=radius;c.height=height;body(c,at)
 return n
func label(at: Vector3,words: String) -> void:
 var n := Label3D.new();n.text=words;n.position=at;n.font_size=32;n.pixel_size=.008;n.billboard=BaseMaterial3D.BILLBOARD_ENABLED;n.modulate=Color("e9d8f2");n.outline_size=7;n.outline_modulate=Color("242937");add_child(n)
func sprite(texture: Texture2D,at: Vector3,width: float) -> Sprite3D:
 var n := Sprite3D.new();n.texture=texture;n.position=at;n.pixel_size=width/texture.get_width();n.offset.y=texture.get_height()*.5-2.;n.alpha_cut=SpriteBase3D.ALPHA_CUT_DISCARD;n.alpha_scissor_threshold=.5;n.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;n.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(n);return n
func stairs() -> void:
 var stone := ink("686576")
 for flight in PLAN.FLIGHTS:
  for i in 6:
   var start: float=flight.x+i*.5;var at: Vector2=PLAN.path_point(start+.25);var tangent: Vector2=(PLAN.path_point(start+.4)-PLAN.path_point(start+.1)).normalized()
   var step := box(Vector3(3.6,.22,.51),Vector3(at.x,PLAN.path_y(start+.01,true)-.11,at.y),stone);step.rotation.y=atan2(tangent.x,tangent.y);stair_treads.append(step)
func tree(at: Vector2,height: float,index: int) -> void:
 var id := "young" if index%3==1 else "oak"
 var profile: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/forest14/profiles.json"))["a"][id]
 var tile := AtlasTexture.new();tile.atlas=preload("res://assets/forest14/a_trees.png");var rect: Array=profile.cell;tile.region=Rect2(rect[0],rect[1],rect[2],rect[3])
 var n := sprite(tile,Vector3(at.x,PLAN.height183(at)-.04,at.y),5.)
 n.pixel_size=height/float(profile.height);n.offset=Vector2(tile.get_width()*.5-float(profile.foot[0])+4.,float(profile.foot[1])-4.-tile.get_height()*.5)
 var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/forest_cutout17.gdshader");material.set_shader_parameter("paint",tile);material.set_shader_parameter("tint",Vector3(.42,.52,.78));n.material_override=material;trees.append(n)
 fading.append({"node":n,"at":at,"radius":height*.32,"height":height})
 var trunk := CylinderShape3D.new();trunk.radius=.38;trunk.height=2.;body(trunk,Vector3(at.x,PLAN.height183(at)+1.,at.y))
func ribbon(a: Vector3,b: Vector3) -> void:
 var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 20:
  var t := float(i)/20.;var u := float(i+1)/20.;var p := a.lerp(b,t)-Vector3.UP*sin(t*PI)*.55;var q := a.lerp(b,u)-Vector3.UP*sin(u*PI)*.55
  for v in [p,q,p-Vector3.UP*.12,q,q-Vector3.UP*.12,p-Vector3.UP*.12]: st.add_vertex(v)
 st.generate_normals();var material := ink("b8a0d0");material.cull_mode=BaseMaterial3D.CULL_DISABLED
 ribbons.append(mesh(st.commit(),Vector3.ZERO,material))
func cottage() -> void:
 var texture: Texture2D=preload("res://assets/forest179/cottage_right_down.png");var image := texture.get_image();var low := Vector2i(image.get_width(),image.get_height());var high := Vector2i.ZERO
 for y in image.get_height():
  for x in image.get_width():
   if image.get_pixel(x,y).a<.65: continue
   low.x=mini(low.x,x);low.y=mini(low.y,y);high.x=maxi(high.x,x);high.y=maxi(high.y,y)
 alpha_bounds=Rect2i(low,high-low+Vector2i.ONE)
 cottage_sprite=sprite(texture,Vector3(-11.,PLAN.BASE,-9.),6.7);cottage_sprite.pixel_size=6.7/alpha_bounds.size.x;cottage_sprite.offset=Vector2(image.get_width()*.5-float(low.x+high.x)*.5,float(high.y)-image.get_height()*.5);cottage_sprite.billboard=BaseMaterial3D.BILLBOARD_ENABLED;cottage_sprite.shaded=false;cottage_sprite.alpha_scissor_threshold=.65
 var shape := BoxShape3D.new();shape.size=Vector3(5.2,2.7,3.6);body(shape,Vector3(-11.,PLAN.BASE+1.35,-11.))
func _ready() -> void:
 name="IntegratedForest183";position=Vector3(PLAN.CENTER.x,0,PLAN.CENTER.y);stairs();cottage()
 var bark := ink("625d6b")
 var trunk := cylinder(1.5,6.5,Vector3(-1.,PLAN.BASE+3.25,0.),bark);trunk.hide()
 for p in [Vector2(-2.4,-1.7),Vector2(-2.3,1.8),Vector2(.3,1.7),Vector2(.5,-1.8)]: cylinder(.55,.5,Vector3(p.x,PLAN.BASE+.25,p.y),bark).hide()
 var edge: Array[Vector2]=[Vector2(-16.,-15.),Vector2(-10.,-16.),Vector2(-3.,-16.),Vector2(4.,-16.),Vector2(14.,-16.),Vector2(-16.,-6.),Vector2(-16.,2.),Vector2(-16.,10.),Vector2(-9.,14.5),Vector2(-2.,14.5),Vector2(6.,14.5),Vector2(15.8,12.),Vector2(16.2,-5.),Vector2(26.,-7.),Vector2(31.,.8),Vector2(21.,7.),Vector2(18.,-1.),Vector2(15.7,1.)]
 for i in edge.size(): tree(edge[i],7.5+float(i%3)*.8,i)
 # A large reused oak temporarily provides the central canopy, with an
 # independent physical trunk. Theme-specific root trees can replace it later.
 tree(Vector2(-1.,0.),10.,21)
 var props := preload("res://scripts/art/forest_props87.gd").new()
 var rocks: Array=props._textures87("moss_boulders87");var plants: Array=props._textures87("woodland_plants87")
 for i in 15:
  var at := Vector2(-13.5+i*1.7,-11.5+sin(i*1.3)*.35);var y := PLAN.height183(at)
  var r := sprite(rocks[i%3],Vector3(at.x,y-.15,at.y),2.+float(i%3)*.3);r.modulate=Color(.78,.79,.91)
 for i in 30:
  var at := Vector2(-13.+float(i%15)*1.8,-10.4 if i<15 else 10.6)
  if at.x>9.: continue
  var plant := sprite(plants[i%3],Vector3(at.x,PLAN.height183(at)-.03,at.y),1.0);plant.modulate=Color(.72,.76,.92)
 props.free()
 for p in [Vector2(30.,-4.4),Vector2(23.,4.5),Vector2(15.,8.7),Vector2(6.,9.5),Vector2(-11.,5.),Vector2(-10.8,-5.8),Vector2(12.5,-15.)]:
  var y := PLAN.height183(p);cylinder(.055,1.3,Vector3(p.x,y+.65,p.y),bark,false);cylinder(.16,.28,Vector3(p.x,y+1.35,p.y),ink("ffca88",true),false)
  var light := OmniLight3D.new();light.position=Vector3(p.x,y+1.5,p.y);light.light_color=Color("ffd2a0");light.light_energy=1.;light.omni_range=4.;add_child(light)
 ribbon(Vector3(15.,PLAN.height183(Vector2(15.,8.7))+3.2,8.7),Vector3(8.,PLAN.BASE+3.,10.))
 ribbon(Vector3(-14.,PLAN.BASE+3.4,5.),Vector3(-9.,PLAN.BASE+3.,7.))
 label(Vector3(32.,1.5,-4.8),"小院方向 · 原地势")
 label(Vector3(15.,PLAN.BASE+1.6,7.5),"很吓人的森林！")
 label(Vector3(2.,1.5,-15.),"北侧原地势 · 岩石断面")
func _process(delta: float) -> void:
 if not is_instance_valid(world.hero): return
 var p: Vector3=world.hero.position-position
 for item in fading:
  var inverse: Transform3D=item.node.global_transform.affine_inverse()
  var bounds: AABB=item.node.get_aabb().grow(.2)
  var blocked: bool=bounds.intersects_segment(inverse*world.camera.global_position,inverse*(world.hero.position+Vector3.UP*.8))!=null
  item.node.transparency=lerpf(item.node.transparency,.82 if blocked else 0.,1.-exp(-delta*10.))
  if item.node.material_override is ShaderMaterial:
   item.node.material_override.set_shader_parameter("fade",1.-item.node.transparency)
 var hidden_by_house := p.z< -9. and p.z> -16. and absf(p.x+11.)<3.7
 cottage_sprite.transparency=lerpf(cottage_sprite.transparency,.8 if hidden_by_house else 0.,1.-exp(-delta*10.))

