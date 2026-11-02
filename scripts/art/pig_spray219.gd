extends Node3D
var world: Node3D
var stream: Node3D
var visual: Sprite3D
var ink: ShaderMaterial
var body: AnimatableBody3D
var shadow: MeshInstance3D
var warning: MeshInstance3D
var poses: Array[AtlasTexture]=[]
var layout: Dictionary
var sheet: Texture2D
var phase219 := "idle"
var age219 := 0.
var emission219 := 0.
var running219 := true
var manual219 := false
var direction219 := Vector2(-1.,.40).normalized()
var width219 := 1.6
func _ready() -> void:
 layout=JSON.parse_string(FileAccess.get_file_as_string("res://assets/pig219/layout.json"));sheet=load("res://assets/pig219/poses.png")
 for f in layout.poses.frames:
  var r: Array=f.region
  var atlas=AtlasTexture.new();atlas.atlas=sheet;atlas.region=Rect2(r[0],r[1],r[2],r[3]);atlas.filter_clip=true;poses.append(atlas)
 visual=Sprite3D.new();visual.shaded=true;visual.layers=1;visual.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;visual.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(visual)
 ink=ShaderMaterial.new();ink.shader=preload("res://scripts/art/sister_receiver207.gdshader");ink.set_shader_parameter("paint",sheet);visual.material_override=ink
 body=AnimatableBody3D.new();body.collision_layer=1;body.collision_mask=0;body.sync_to_physics=false
 var collision=CollisionShape3D.new();var shape=CylinderShape3D.new();shape.radius=.40;shape.height=.45;collision.shape=shape;collision.position.y=.225;body.add_child(collision);add_child(body)
 shadow=preload("res://scripts/combat/actor_shadow105.gd").new();shadow.battle=world;shadow.visual=visual;shadow.opacity_scale=.45;add_child(shadow)
 warning=MeshInstance3D.new();warning.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var st=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 var at=Vector2(global_position.x,global_position.z)
 for nose in 2:
  var direction=direction219.rotated(-.10 if nose==0 else .10)
  var side=Vector2(-direction.y,direction.x)*.055
  for i in 8:
   var a=at+direction*(.45+float(i)*.38)
   var b=at+direction*(.45+float(i+1)*.38)
   for point in [a-side,a+side,b+side,a-side,b+side,b-side]:
    st.add_vertex(to_local(Vector3(point.x,world.floor_height(point)+.04,point.y)))
 warning.mesh=st.commit();var mat=StandardMaterial3D.new();mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;mat.albedo_color=Color("e9b99c");mat.cull_mode=BaseMaterial3D.CULL_DISABLED;warning.material_override=mat;add_child(warning)
 reset219()
func reset219() -> void:
 phase219="idle";age219=0.;emission219=0.;running219=true;body.collision_layer=1;visual.show();visual.scale=Vector3.ONE
 if is_instance_valid(stream):stream.clear219()
 update_pose219()
func flatten219() -> void:
 if phase219 in ["flat","gone"]:return
 phase219="flat";age219=0.;update_pose219()
func nose219(index: int) -> Vector3:
 var f: Dictionary=layout.poses.frames[1]
 var p=Vector2(138.,280.) if index==0 else Vector2(189.,284.)
 var anchor=Vector2(f.anchor[0],f.anchor[1])
 return visual.global_position+visual.global_basis.x*(p.x-anchor.x)*visual.pixel_size+visual.global_basis.y*(anchor.y-p.y)*visual.pixel_size
func advance219(delta: float) -> void:
 if not running219:return
 age219+=delta
 match phase219:
  "idle":
   if age219>=.9:phase219="spray";age219=0.;emission219=0.
  "spray":
   emission219+=delta
   var interval=.28/(3. if stream.stress219 else 1.)
   while emission219>=interval:
    emission219-=interval
    update_pose219();_process(0.)
    for i in 2:stream.emit219(nose219(i),direction219.rotated(-.10 if i==0 else .10),i)
   if age219>=4.2:flatten219()
  "flat":
   if age219>=1.5:phase219="gone";age219=0.;body.collision_layer=0
  "gone":
   if age219>=2.:reset219()
 update_pose219()
func update_pose219() -> void:
 var index=0 if phase219=="idle" else (1 if phase219=="spray" else 2)
 visual.texture=poses[index]
 var f: Dictionary=layout.poses.frames[index];var a: Array=f.anchor;var size=visual.texture.get_size()
 visual.pixel_size=width219/656.
 visual.offset=Vector2(size.x*.5-float(a[0]),float(a[1])-size.y*.5)
 visual.visible=phase219!="gone"
 var shrink=1.-smoothstep(.9,1.5,age219) if phase219=="flat" else 1.
 visual.scale=Vector3.ONE*maxf(shrink,.001)
 warning.visible=phase219=="idle"
func _physics_process(delta: float) -> void:
 if not manual219:advance219(delta)
func _process(_delta: float) -> void:
 if not is_instance_valid(world.camera) or not is_instance_valid(visual):return
 visual.global_basis=world.camera.global_basis
 visual.global_position=global_position+Vector3.UP*.025
 ink.set_shader_parameter("foot199",global_position);ink.set_shader_parameter("camera199",world.camera.global_position)
 var normal=world.camera.global_basis.z;normal.y=0.;ink.set_shader_parameter("plane_normal199",normal.normalized())
 var light_normal=world.hero.visual.global_basis*Vector3(0.,sin(deg_to_rad(25.)),cos(deg_to_rad(25.)))
 ink.set_shader_parameter("receiver_normal207",light_normal.normalized())
