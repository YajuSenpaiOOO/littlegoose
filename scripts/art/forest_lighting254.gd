extends "res://scripts/art/forest_lighting201.gd"
## Warm, fixture-owned accent lights. No change to actors, geometry or old previews.
var ready254 := false
var fixtures254: Array[Dictionary]=[]
var masks254 := {}
func lamp(at: Vector3,energy: float,radius: float) -> OmniLight3D:
 var light=super.lamp(at,energy,radius)
 var gain=.20 if energy>=.5 else .40
 light.set_meta("energy254",energy*gain)
 light.set_meta("range254",minf(3.5,radius*(.60 if energy>=.5 else .65)))
 return light
func _ready() -> void:
 super._ready();stage_enabled=false
 for prop in world.forest188.props181:
  var uv=Vector2.ZERO;var radius=Vector2.ZERO
  if prop.texture==preload("res://assets/forest188/post_top_nightlight_pixel.png"):uv=Vector2(.56,.23);radius=Vector2(.27,.16)
  elif prop.texture==preload("res://assets/forest184/hanging_lantern.png"):uv=Vector2(.5,.78);radius=Vector2(.32,.19)
  elif prop.texture==preload("res://assets/forest201/ribbon_fence.png"):uv=Vector2(.90,.18);radius=Vector2(.075,.16)
  if radius==Vector2.ZERO:continue
  var original=core(prop,uv)+world.camera.global_basis.z*(.35 if uv.x>.51 else .4)
  var closest: OmniLight3D;var distance=.8
  for light in lamps:
   var d=light.global_position.distance_to(original)
   if d<distance:distance=d;closest=light
  if is_instance_valid(closest):
   closest.set_meta("fixture254",prop);closest.set_meta("uv254",uv)
   closest.set_meta("energy254",.055 if uv.x>.8 else (.15 if uv.x>.51 else (.065 if prop.name=="StumpAmberLantern201" else .13)))
   closest.set_meta("range254",2.4 if uv.x>.8 else (3.0 if uv.x>.51 else (2.3 if prop.name=="StumpAmberLantern201" else 2.8)))
  attach_glow254(prop,uv,radius)
 ready254=true;_process(0.)
func mask254(prop: Sprite3D,uv: Vector2,radius: Vector2) -> Texture2D:
 var source: Texture2D=prop.texture.atlas if prop.texture is AtlasTexture else prop.texture
 var key=str(source.get_instance_id())+str(uv)
 if masks254.has(key):return masks254[key]
 var image=source.get_image();var bounds: Rect2i=world.forest188.opaque_bounds181(source)
 var center=Vector2(bounds.position)+Vector2(bounds.size)*uv;var span=Vector2(bounds.size)*radius
 var result=Image.create(image.get_width(),image.get_height(),false,Image.FORMAT_RGBA8)
 var rect=Rect2i(Vector2i(center-span),Vector2i(span*2.)).intersection(Rect2i(Vector2i.ZERO,image.get_size()))
 for y in range(rect.position.y,rect.end.y):
  for x in range(rect.position.x,rect.end.x):
   var color=image.get_pixel(x,y)
   var q=(Vector2(x,y)-center)/span
   var inside=1.-smoothstep(.50,1.,q.length_squared())
   var warm=smoothstep(.45,.75,color.g)*smoothstep(.04,.18,color.r-color.b)
   var amount=inside*warm*(1. if color.a>.6 else 0.)
   if amount>.001:result.set_pixel(x,y,Color(1.*amount,.66*amount,.22*amount,1.))
 var texture=ImageTexture.create_from_image(result);masks254[key]=texture;return texture
func attach_glow254(prop: Sprite3D,uv: Vector2,radius: Vector2) -> void:
 var glow=mask254(prop,uv,radius)
 if prop.material_override is ShaderMaterial:
  # Keep the actual registered material instance, so relations199 still updates depth uniforms.
  var ink: ShaderMaterial=prop.material_override
  var values={}
  for u in ink.shader.get_shader_uniform_list():
   var value=ink.get_shader_parameter(u.name)
   if value!=null:values[u.name]=value
  var code=ink.shader.code;var end=code.rfind("}")
  code=code.substr(0,end)+"\n EMISSION=texture(glow254,UV).rgb*glow_gain254;\n"+code.substr(end)
  code=code.replace("void fragment()", "uniform sampler2D glow254:source_color,filter_linear,repeat_disable;\nuniform float glow_gain254=.38;\nvoid fragment()")
  var shader=Shader.new();shader.code=code;ink.shader=shader
  for key in values:ink.set_shader_parameter(key,values[key])
  ink.set_shader_parameter("glow254",glow)
  fixtures254.append({"prop":prop,"ink":ink,"shader":true,"uv":uv,"radius":radius})
 else:
  var ink=StandardMaterial3D.new();ink.albedo_texture=prop.texture;ink.vertex_color_use_as_albedo=true
  ink.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR;ink.alpha_scissor_threshold=.6;ink.cull_mode=BaseMaterial3D.CULL_DISABLED
  ink.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;ink.billboard_mode=prop.billboard
  ink.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED;ink.albedo_color=Color(.82,.82,.82,1.);ink.roughness=1.;ink.metallic_specular=0.;ink.emission_enabled=true;ink.emission=Color.WHITE;ink.emission_texture=glow;ink.emission_energy_multiplier=.38
  prop.material_override=ink;fixtures254.append({"prop":prop,"ink":ink,"shader":false,"uv":uv,"radius":radius})
func _process(delta: float) -> void:
 super._process(delta)
 if not ready254:return
 # Relations199/201 attach depth materials later in world initialization.
 # Preserve that final material, and wrap it once rather than retaining a detached emitter.
 for i in range(fixtures254.size()-1,-1,-1):
  var fixture=fixtures254[i]
  if fixture.prop.material_override!=fixture.ink:
   fixtures254.remove_at(i);attach_glow254(fixture.prop,fixture.uv,fixture.radius)
 for light in lamps:
  if not light.has_meta("energy254"):light.set_meta("energy254",minf(.08,float(light.get_meta("energy191",.18))*.4));light.set_meta("range254",2.5)
  light.set_meta("energy191",light.get_meta("energy254"));light.light_energy=float(light.get_meta("energy254")) if enabled and light.visible else 0.
  light.omni_range=float(light.get_meta("range254"));light.omni_attenuation=1.6;light.light_color=Color("ffb56b");light.shadow_enabled=false
  if light.has_meta("fixture254"):
   var prop: Sprite3D=light.get_meta("fixture254")
   light.global_position=core(prop,light.get_meta("uv254"))+world.camera.global_basis.z*.12
 for item in fixtures254:
  if item.shader:item.ink.set_shader_parameter("glow_gain254",.38 if enabled else 0.)
  else:item.ink.emission_energy_multiplier=.38 if enabled else 0.
 var spot: SpotLight3D=world.time55.accents57.stage_light
 spot.light_color=Color("ffb56b");spot.light_energy=.28*stage_level;spot.shadow_enabled=false
 world.time55.accents57.stage_beam.hide()
 # The relief footprint must match the reduced native light volumes, not old 7m pools.
 var ordered=lamps.duplicate();var at=world.hero.global_position
 ordered.sort_custom(func(a,b):return a.global_position.distance_squared_to(at)<b.global_position.distance_squared_to(at))
 var upload=PackedVector4Array()
 if enabled:
  for light in ordered:
   if upload.size()>=20:break
   if light.visible and light.light_energy>0.:
    var p=light.global_position;upload.append(Vector4(p.x,p.y,p.z,light.omni_range))
 var focus: ShaderMaterial=world.atmosphere41.focus_material
 focus.set_shader_parameter("light_count191",upload.size());upload.resize(20);focus.set_shader_parameter("lights191",upload)
 if not stage_enabled or not enabled:focus.set_shader_parameter("stage191",Vector4.ZERO)
