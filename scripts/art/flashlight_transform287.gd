extends "res://scripts/art/flashlight_transform286.gd"
const ACTIVE_SECONDS := 8.
const RED_BEGIN := INTRO+6.
const END_BEGIN := INTRO+ACTIVE_SECONDS
const END_FINISH := END_BEGIN+.45
var outline: Sprite3D
var badge: MeshInstance3D
var outline_ink: ShaderMaterial
var badge_ink: ShaderMaterial
var audio: Node
var cue_flags := {}
var next_alarm := RED_BEGIN
var last_alarm := -100.
var trail: Array[Dictionary]=[]
var next_trail := 0.
var native: Sprite3D
var badge_allowed := true
func _ready() -> void:
 super._ready()
 outline=Sprite3D.new();outline.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;outline.position.z=.003;add_child(outline)
 var shader=Shader.new();shader.code="""shader_type spatial;
 render_mode unshaded,cull_disabled;
 uniform sampler2D art : source_color, filter_nearest;
 uniform vec4 ink : source_color=vec4(1.0,0.75,0.3,1.0);
 uniform float strength=0.0;
 void fragment(){
  vec2 d=vec2(6.0)/vec2(textureSize(art,0));
  float a=texture(art,UV).a;
  float n=max(max(texture(art,UV+vec2(d.x,0.0)).a,texture(art,UV-vec2(d.x,0.0)).a),max(texture(art,UV+vec2(0.0,d.y)).a,texture(art,UV-vec2(0.0,d.y)).a));
  float edge=step(0.5,n)*(1.0-step(0.5,a));
  ALBEDO=ink.rgb;EMISSION=ink.rgb*0.8;
  ALPHA=edge*strength;ALPHA_SCISSOR_THRESHOLD=0.035;
 }"""
 outline_ink=ShaderMaterial.new();outline_ink.shader=shader;outline.material_override=outline_ink;outline.hide()
 badge=MeshInstance3D.new();var quad=QuadMesh.new();quad.size=Vector2(.16,.16);badge.mesh=quad;badge.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(badge)
 var badge_shader=Shader.new();badge_shader.code="""shader_type spatial;
 render_mode unshaded,cull_disabled;
 uniform vec4 ink : source_color=vec4(1.0,0.75,0.3,1.0);
 uniform float strength=0.0;
 void fragment(){vec2 p=UV*2.0-1.0;float r=length(p);float core=1.0-smoothstep(0.10,0.38,r);float halo=(1.0-smoothstep(0.15,1.0,r))*0.25;
 ALBEDO=ink.rgb;EMISSION=ink.rgb*0.7;ALPHA=(core+halo)*strength;}
 """
 badge_ink=ShaderMaterial.new();badge_ink.shader=badge_shader;badge.material_override=badge_ink;badge.hide()
 audio=preload("res://scripts/art/transform_audio287.gd").new();add_child(audio)
func cape_amount() -> float:return 0.
func red_seconds() -> float:return 2.
func red_at() -> float:return END_BEGIN-red_seconds()
func remaining() -> float:return clampf(END_BEGIN-age,0.,ACTIVE_SECONDS)
func is_red() -> bool:return playing and age>=red_at() and age<END_BEGIN
func strength() -> float:return ramp(1.98,2.5,age)*(1.-ramp(END_BEGIN,END_FINISH,age)) if playing else 0.
func pulse() -> float:return exp(-maxf(0.,age-last_alarm)/.13) if is_red() else 0.
func start() -> void:
 cue_flags.clear();trail.clear();next_alarm=red_at();last_alarm=-100.;next_trail=INTRO
 audio.stop_all();super.start()
func bind_native(source: Sprite3D) -> void:
 native=source
 outline.texture=source.texture;outline.pixel_size=source.pixel_size;outline.offset=source.offset;outline.flip_h=source.flip_h
 outline_ink.set_shader_parameter("art",source.texture.atlas if source.texture is AtlasTexture else source.texture)
func sample(t: float) -> void:
 super.sample(t)
 if is_instance_valid(outline):update_status()
func update_status() -> void:
 var s=strength();var ink=Color(1.,.73,.28)
 if is_red():ink=Color(1.,.16,.24)
 outline.visible=s>.001;badge.visible=s>.001 and badge_allowed
 outline_ink.set_shader_parameter("ink",ink);outline_ink.set_shader_parameter("strength",s*(.55+.25*pulse()))
 badge.position=p(0.,239.,.022)
 badge_ink.set_shader_parameter("ink",ink);badge_ink.set_shader_parameter("strength",s*(.55+.4*pulse()))
func advance(delta: float) -> void:
 if not playing:return
 var next=age+delta
 for event in [["switch",.68],["burst",.76],["bloom",1.05],["hum",INTRO],["outro",END_BEGIN]]:
  if next>=float(event[1]) and not cue_flags.has(event[0]):audio.cue(event[0]);cue_flags[event[0]]=true
 if next>=red_at() and next<END_BEGIN and next>=next_alarm:
  audio.cue("pulse");last_alarm=next
  next_alarm=next+lerpf(.55,.23,clampf((next-red_at())/red_seconds(),0.,1.))
 if next>=INTRO and next<END_BEGIN and motion_target.length()>.7 and next>=next_trail:
  if trail.size()<6:trail.append({"at":global_position+Vector3(0,.35,0),"born":next})
  next_trail=next+.12
 trail=trail.filter(func(dot):return next-float(dot.born)<.42)
 motion=motion.lerp(motion_target,1.-exp(-delta*7.));sample(next)
 audio.update_bed(is_red(),clampf((age-red_at())/red_seconds(),0.,1.),strength())
 if age>=INTRO and not released:released=true;revealed.emit()
 if age>=END_FINISH:
  super.cancel();outline.hide();badge.hide();audio.stop_hum();finished.emit()
func cancel() -> void:
 super.cancel()
 if is_instance_valid(outline):outline.hide();badge.hide();audio.stop_all();trail.clear()
func draw_effects() -> void:
 super.draw_effects()
 if age>=END_BEGIN:
  var t=clampf((age-END_BEGIN)/.45,0.,1.)
  for i in 6:
   var dot=p(cos(i*2.399)*170.,100.+float(i)*82.+t*220.,.025)
   strip(i,[dot,dot+Vector3.UP*pixel*18.],[pixel*5.,pixel*2.],Color(1.,.88,.52,(1.-t)*.8))
 else:
  for i in mini(trail.size(),6):
   var dot=to_local(trail[i].at);var t=clampf((age-float(trail[i].born))/.42,0.,1.);dot.y+=t*.13
   strip(i,[dot,dot+Vector3.UP*pixel*12.],[pixel*5.,pixel*2.],Color(1.,.83,.43,(1.-t)*.55))
