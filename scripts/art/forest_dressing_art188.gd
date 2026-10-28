extends "res://scripts/art/forest_base188.gd"
const DRESS=preload("res://scripts/world/forest_dressing188.gd")
var props181: Array[Sprite3D]=[]
var lights181: Array[OmniLight3D]=[]
var thin_stones181: Array[MeshInstance3D]=[]
var terrain_trail181: MeshInstance3D
var lantern181: Sprite3D
var kitten181: Sprite3D
var flags181: Sprite3D
var bounds181: Dictionary={}
func ribbon(_a: Vector3,_b: Vector3) -> void: pass
func cylinder(radius: float,height: float,at: Vector3,material: Material,solid := true) -> MeshInstance3D:
 var n := super.cylinder(radius,height,at,material,solid)
 if not solid and (is_equal_approx(radius,.055) or is_equal_approx(radius,.16)): n.hide()
 return n
func stairs() -> void:
 for flight in PLAN.FLIGHTS:
  for i in 6:
   var start: float=flight.x+i*.5;var at: Vector2=PLAN.path_point(start+.25);var tangent: Vector2=(PLAN.path_point(start+.4)-PLAN.path_point(start+.1)).normalized()
   var half := 1.78+.045*sin(i*1.8+flight.x)
   var poly := PackedVector2Array([Vector2(-half+.10,-.255),Vector2(half-.13,-.26),Vector2(half,-.12),Vector2(half-.06,.24),Vector2(-half+.08,.26),Vector2(-half-.03,.12)])
   # Reuse the live map's hand-painted stone prism builder/material. Its box
   # colliders are disabled here; the existing per-flight support stays smooth.
   var n: MeshInstance3D=world.park99._prism99(poly,Vector3(PLAN.CENTER.x+at.x,PLAN.path_y(start+.01,true)+.012,PLAN.CENTER.y+at.y),.24)
   n.rotation.y=atan2(tangent.x,tangent.y)
   for child in n.get_children():
    if child is CollisionObject3D: child.collision_layer=0
   stair_treads.append(n)
func opaque_bounds181(texture: Texture2D) -> Rect2i:
 if bounds181.has(texture): return bounds181[texture]
 var image := texture.get_image();var low := Vector2i(image.get_width(),image.get_height());var high := Vector2i.ZERO
 for y in image.get_height():
  for x in image.get_width():
   if image.get_pixel(x,y).a<.6: continue
   low.x=mini(low.x,x);low.y=mini(low.y,y);high.x=maxi(high.x,x);high.y=maxi(high.y,y)
 var bounds := Rect2i(low,high-low+Vector2i.ONE);bounds181[texture]=bounds;return bounds
func cutout181(texture: Texture2D,at: Vector3,units: float,anchor: Vector2,width := false) -> Sprite3D:
 var bounds := opaque_bounds181(texture);var n := Sprite3D.new();n.texture=texture;n.position=at
 n.pixel_size=units/float(bounds.size.x if width else bounds.size.y)
 var foot := Vector2(bounds.position)+Vector2(bounds.size)*anchor
 n.offset=Vector2(texture.get_width()*.5-foot.x,foot.y-texture.get_height()*.5)
 n.billboard=BaseMaterial3D.BILLBOARD_ENABLED;n.alpha_cut=SpriteBase3D.ALPHA_CUT_DISCARD;n.alpha_scissor_threshold=.6;n.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;n.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;n.shaded=false;add_child(n);props181.append(n);return n
func lane181(st: SurfaceTool,points: Array) -> void:
 for segment in range(1,points.size()):
  var a: Vector2=points[segment-1];var b: Vector2=points[segment];var tangent := (b-a).normalized();var side := tangent.orthogonal();var count := ceili(a.distance_to(b)/.35)
  for i in count:
   var t := float(i)/count;var u := float(i+1)/count;var p := a.lerp(b,t);var q := a.lerp(b,u)
   if PLAN.in_flight((p+q)*.5): continue
   var width := .82+.08*sin((p.x+p.y)*1.3)
   for spec in [Vector3(0,0,0),Vector3(1,0,1),Vector3(0,1,0),Vector3(1,0,1),Vector3(1,1,1),Vector3(0,1,0)]:
    var centre: Vector2=p if spec.y<.5 else q;var at: Vector2=centre+side*((spec.x*2.-1.)*width)
    st.set_uv(Vector2(spec.x,centre.distance_to(a)));st.set_normal(Vector3.UP)
    st.add_vertex(Vector3(at.x,world.floor_height(PLAN.CENTER+at)+.022,at.y))
func route181() -> void:
 var st := SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES);lane181(st,PLAN.PATH);lane181(st,DRESS.TRAIL)
 var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/forest_trail181.gdshader");material.set_shader_parameter("soil",preload("res://assets/woodland103/painted_soil103.png"));world.porch49.shade_material(material)
 terrain_trail181=mesh(st.commit(),Vector3.ZERO,material)
 for p in [Vector2(9.9,7.9),Vector2(8.8,7.4),Vector2(6.6,6.9),Vector2(3.2,4.2),Vector2(-4.4,3.3),Vector2(-5.7,.8),Vector2(-5.5,-3.4),Vector2(-6.5,-5.5),Vector2(-8.,-7.),Vector2(-9.2,-7.6),Vector2(-10.4,-8.1)]:
  var poly := PackedVector2Array([Vector2(-.28,-.13),Vector2(-.12,-.23),Vector2(.23,-.16),Vector2(.31,.04),Vector2(.13,.22),Vector2(-.22,.16)])
  var at: Vector2=PLAN.CENTER+p;var node: MeshInstance3D=world.park99._prism99(poly,Vector3(at.x,world.floor_height(at)+.025,at.y),.045)
  node.rotation.y=p.x*1.7
  for child in node.get_children():
   if child is CollisionObject3D: child.collision_layer=0
  thin_stones181.append(node)
func _ready() -> void:
 super._ready();name="ForestEntranceSample181"
 # Remove the obsolete floating scene title from the stair mouth.
 for child in get_children():
  if child is Label3D and child.text=="很吓人的森林！": child.hide()
 # Existing light nodes retain lighting; the simple cylinders are hidden above.
 for child in get_children():
  if child is OmniLight3D: lights181.append(child)
 var lamp_texture: Texture2D=preload("res://assets/forest181/woven_lantern.png")
 for p in [Vector2(30.,-4.4),Vector2(23.,4.5),Vector2(15.,8.7),Vector2(6.,9.5),Vector2(-11.,5.),Vector2(-10.8,-5.8),Vector2(12.5,-15.)]:
  cutout181(lamp_texture,Vector3(p.x,world.floor_height(PLAN.CENTER+p),p.y),1.65,Vector2(.25,1.))
 var lamp_at := Vector2(10.2,4.8);var y: float=world.floor_height(PLAN.CENTER+lamp_at)
 lantern181=cutout181(lamp_texture,Vector3(lamp_at.x,y,lamp_at.y),1.65,Vector2(.25,1.))
 var glow := OmniLight3D.new();glow.position=Vector3(lamp_at.x+.45,y+1.02,lamp_at.y);glow.light_color=Color("ffd0a0");glow.light_energy=1.4;glow.omni_range=4.;add_child(glow);lights181.append(glow)
 var left := Vector2(10.9,4.5);var right := Vector2(13.2,4.5);var top := PLAN.BASE+2.35
 for p in [left,right]:
  var bottom: float=world.floor_height(PLAN.CENTER+p)
  super.cylinder(.055,top-bottom+.08,Vector3(p.x,(top+bottom)*.5,p.y),world.park99.wood97,false)
 flags181=cutout181(preload("res://assets/forest181/lavender_bunting.png"),Vector3((left.x+right.x)*.5,top,left.y),2.5,Vector2(.5,.04),true)
 kitten181=cutout181(preload("res://assets/forest181/ghost_kitten.png"),Vector3(left.x,PLAN.BASE+1.85,left.y-.03),.78,Vector2(.43,.0))
 route181()
