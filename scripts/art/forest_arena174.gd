extends Node3D
const PLAN=preload("res://scripts/world/arena_layout174.gd")
var world: Node3D
var bodies174: Array[StaticBody3D]=[]
var fading174: Array[Dictionary]=[]
var painted174: Array[Sprite3D]=[]
func body174(shape: Shape3D,at: Vector3,layer := 2) -> StaticBody3D:
 var body := StaticBody3D.new();body.collision_layer=layer;body.collision_mask=0;body.position=at
 var collider := CollisionShape3D.new();collider.shape=shape;body.add_child(collider);add_child(body);bodies174.append(body);return body
func cylinder174(a: Vector3,b: Vector3,radius: float,material: Material,solid := true) -> MeshInstance3D:
 var axis := b-a;var direction := axis.normalized();var right := direction.cross(Vector3.FORWARD).normalized()
 if right.length_squared()<.01: right=direction.cross(Vector3.RIGHT).normalized()
 var basis174 := Basis(right,direction,right.cross(direction))
 var cylinder := CylinderMesh.new();cylinder.top_radius=radius*.93;cylinder.bottom_radius=radius;cylinder.height=axis.length();cylinder.radial_segments=12
 var node := MeshInstance3D.new();node.mesh=cylinder;node.position=(a+b)*.5;node.basis=basis174;node.material_override=material;add_child(node)
 if solid:
  var shape := CylinderShape3D.new();shape.radius=radius;shape.height=axis.length()
  var body := body174(shape,node.position);body.basis=basis174
 return node
func sprite174(texture: Texture2D,at: Vector2,width: float) -> Sprite3D:
 var sprite := Sprite3D.new();sprite.texture=texture;sprite.pixel_size=width/texture.get_width();sprite.offset.y=texture.get_height()*.5-2.
 sprite.position=Vector3(at.x,-.025,at.y);sprite.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS;sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var ink := ShaderMaterial.new();ink.shader=preload("res://scripts/art/forest_cutout17.gdshader");ink.set_shader_parameter("paint",texture);ink.set_shader_parameter("tint",Vector3(.88,.94,.85));world.porch49.shade_material(ink);sprite.material_override=ink
 add_child(sprite);painted174.append(sprite);return sprite
func rock174(at: Vector2,width: float,index: int) -> void:
 var texture: Texture2D=world.forest87._textures87("moss_boulders87")[index%3]
 var sprite := sprite174(texture,at,width)
 var shape := CylinderShape3D.new();shape.radius=width*.36;shape.height=1.5
 body174(shape,Vector3(at.x,.75,at.y));fading174.append({"node":sprite,"at":at,"radius":width*.45})
func sign174(at: Vector2,words: String) -> void:
 cylinder174(Vector3(at.x,0.,at.y),Vector3(at.x,.72,at.y),.07,world.park99.wood97,false)
 var text := Label3D.new();text.text=words;text.font_size=44;text.pixel_size=.008;text.position=Vector3(at.x,.95,at.y)
 text.billboard=BaseMaterial3D.BILLBOARD_ENABLED;text.modulate=Color("fff0c6");text.outline_modulate=Color("493c36");text.outline_size=8;add_child(text)
func _ready() -> void:
 name="DetachedForestArena174";position=Vector3(PLAN.CENTER.x,PLAN.HEIGHT,PLAN.CENTER.y)
 var floor174 := MeshInstance3D.new();var plane := PlaneMesh.new();plane.size=Vector2(34.,32.);floor174.mesh=plane
 var ink := ShaderMaterial.new();ink.shader=preload("res://scripts/art/arena_ground174.gdshader");ink.set_shader_parameter("paint",world.ground_templates[3].get_shader_parameter("paint"));world.porch49.shade_material(ink);floor174.material_override=ink;add_child(floor174)
 var base := BoxShape3D.new();base.size=Vector3(34.,.4,32.);body174(base,Vector3(0.,-.2,0.),1)
 for at in [Vector3(-11.5,1.,0.),Vector3(11.5,1.,0.),Vector3(0.,1.,-10.5),Vector3(0.,1.,10.5)]:
  var wall := BoxShape3D.new();wall.size=Vector3(.7,2.,21.7) if absf(at.x)>10. else Vector3(23.7,2.,.7);body174(wall,at)
 # Central trunk and visible root shoulders split a short right route from a
 # longer, wider left route. All collision belongs to this arena root only.
 var trunk := cylinder174(Vector3(-1.,0.,0.),Vector3(-1.1,3.5,.1),1.35,world.park99.bark97)
 fading174.append({"node":trunk,"at":PLAN.TRUNK,"radius":1.5})
 for spec in [Vector4(-2.2,-1.4,.55,.8),Vector4(-2.4,1.5,.5,.65),Vector4(.2,1.8,.42,.55),Vector4(-.3,-2.,.46,.65)]:
  cylinder174(Vector3(spec.x,0.,spec.y),Vector3(spec.x+.06,spec.w,spec.y),spec.z,world.park99.bark97)
 cylinder174(Vector3(-2.9,.23,-.8),Vector3(-.9,.35,0.),.28,world.park99.bark97)
 for spec in [Vector4(6.1,.4,2.5,0),Vector4(6.7,2.5,1.8,1),Vector4(7.1,-1.5,2.,2),Vector4(-9.,-4.7,2.2,1),Vector4(-8.8,5.2,1.8,2)]: rock174(Vector2(spec.x,spec.y),spec.z,int(spec.w))
 # Forest edge dressing stays outside both usable bays and the entry pocket.
 for side in [-1.,1.]:
  for z in [-10.,-5.,0.,5.,10.]:
   var tree: Sprite3D=world._art("oak",6.3+absf(z)*.05);tree.position=Vector3(side*13.,-.08,z);tree.visibility_range_end=0.;add_child(tree)
   fading174.append({"node":tree,"at":Vector2(side*13.,z),"radius":2.7})
 for x in [-10.,-5.,0.,5.,10.]:
  var tree: Sprite3D=world._art("oak",7.);tree.position=Vector3(x,-.08,-13.);add_child(tree)
 for x in [-12.,-7.,7.,12.]:
  var tree: Sprite3D=world._art("oak",6.);tree.position=Vector3(x,-.08,13.);add_child(tree);fading174.append({"node":tree,"at":Vector2(x,13.),"radius":2.7})
 var plants: Array=world.forest87._textures87("woodland_plants87")
 for side in [-1.,1.]:
  for i in 10: sprite174(plants[i%3],Vector2(side*10.8,-9.+i*2.),1.3)
 for i in 10:
  sprite174(plants[i%3],Vector2(-10.+i*2.2,-9.8),1.25)
  if i not in [4,5]: sprite174(plants[(i+1)%3],Vector2(-10.+i*2.2,9.8),1.25)
 sign174(Vector2(-3.,5.2),"宽外圈");sign174(Vector2(3.6,4.7),"近路");sign174(Vector2(-4.2,8.8),"林间试玩")
func _process(_delta: float) -> void:
 if not is_instance_valid(world.hero): return
 var p := Vector2(world.hero.position.x,world.hero.position.z)-PLAN.CENTER
 for entry in fading174:
  var blocked: bool=p.y<entry.at.y and p.y>entry.at.y-4.5 and absf(p.x-entry.at.x)<float(entry.radius)
  entry.node.transparency=lerpf(entry.node.transparency,.65 if blocked else 0.,.16)
