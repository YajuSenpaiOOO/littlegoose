extends "res://scripts/art/flashlight_transform287.gd"
var pass_owner288: Material
var previous_pass288: Material
func red_seconds() -> float:return 3.
func _ready() -> void:
 super._ready()
 # Same mesh/UV/interpolation as the native hero: no separately moving outline card.
 var shader=Shader.new();shader.code="""shader_type spatial;
 render_mode unshaded,cull_disabled,depth_draw_never;
 uniform sampler2D art : source_color, filter_linear;
 uniform vec4 ink : source_color=vec4(1.0,0.75,0.3,1.0);
 uniform float strength=0.0;
 void fragment(){
  vec2 d=vec2(5.0)/vec2(textureSize(art,0));
  float a=texture(art,UV).a;
  float n=max(max(texture(art,UV+vec2(d.x,0.0)).a,texture(art,UV-vec2(d.x,0.0)).a),max(texture(art,UV+vec2(0.0,d.y)).a,texture(art,UV-vec2(0.0,d.y)).a));
  float edge=max(0.0,smoothstep(0.08,0.85,n)-smoothstep(0.08,0.85,a));
  ALBEDO=ink.rgb;EMISSION=ink.rgb*0.35;ALPHA=edge*strength;
 }"""
 outline_ink.shader=shader;outline.hide()
func restore_pass288() -> void:
 if is_instance_valid(pass_owner288) and pass_owner288.next_pass==outline_ink:pass_owner288.next_pass=previous_pass288
 pass_owner288=null;previous_pass288=null
func bind_native(source: Sprite3D) -> void:
 native=source
 outline_ink.set_shader_parameter("art",source.texture.atlas if source.texture is AtlasTexture else source.texture)
 sync_pass288()
func sync_pass288() -> void:
 if not is_instance_valid(native) or strength()<=.001:restore_pass288();return
 var material=native.material_override
 if material==null:return
 if material!=pass_owner288:
  restore_pass288();pass_owner288=material;previous_pass288=material.next_pass;material.next_pass=outline_ink
func update_status() -> void:
 super.update_status();outline.hide();sync_pass288()
func advance(delta: float) -> void:
 super.advance(delta)
 if not playing:restore_pass288()
func cancel() -> void:
 restore_pass288();super.cancel()
func _exit_tree() -> void:restore_pass288()
