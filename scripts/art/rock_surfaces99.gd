extends "res://scripts/art/rock_surfaces92.gd"
const LAYOUT99=preload("res://scripts/world/park_layout99.gd")
func _rock_score91(at: Vector3,normal: Vector3) -> float:
	var p: Vector2=Vector2(at.x,at.z)-Vector2(world.meadow.landmarks.grove)
	return minf(.9-normal.y,minf((at.y-2.24)*.75,minf(p.x+46.,minf(25.-p.x,minf(p.y+39.,26.-p.y)))))
func _clean_shader91() -> Shader:
	var shader := super._clean_shader91()
	var code: String=shader.code
	code=code.insert(code.find("\n")+1,"uniform sampler2D park_field99 : filter_linear,repeat_disable;\n")
	var g: Vector2=world.meadow.landmarks.grove
	var patch := """
 vec2 p99=world.xz-vec2(%f,%f);
 vec2 stair_delta99=p99-vec2(-7.8,1.25);
 vec2 stair99=vec2(.961055*stair_delta99.x-.276356*stair_delta99.y,.276356*stair_delta99.x+.961055*stair_delta99.y)+vec2(-7.8,1.25);
 if(abs(stair99.x+7.8)<1.35 && stair99.y> -3.3 && stair99.y<1.45) discard;
 if(p99.x> -20. && p99.x<20. && p99.y> -18. && p99.y<18.){
  vec2 tile99=world.xz/6.;vec2 mirror99=1.-abs(fract(tile99*.5)*2.-1.);
  col=textureGrad(paint,mirror99,dFdx(tile99),dFdy(tile99)).rgb;
  vec3 field99=texture(park_field99,(p99+vec2(20.,18.))/vec2(40.,36.)).rgb;
  float dist99=field99.r*8.;float width99=field99.g*2.;
  float irregular99=(soft_noise(world.xz*2.7)-.5)*.43+(soft_noise(world.xz*6.1)-.5)*.18;
  float wear99=(1.-smoothstep(width99*.85+irregular99,width99*1.2+irregular99,dist99))*smoothstep(.88,.99,normal76.y);
  float core99=1.-smoothstep(width99*.16,width99*.85,dist99);
  vec3 sand99=mix(vec3(.42,.355,.245),vec3(.57,.48,.33),core99*.60+soft_noise(world.xz*1.4)*.25);
  float patches99=smoothstep(.34,.68,soft_noise(world.xz*3.5));
  col=mix(col,sand99,wear99*field99.b*(.82+.16*patches99));
 }
 // Low lake banks are earth with moss, not the woodland's fractured slate.
 float shore_bank99=smoothstep(15.,20.,world.x)*(1.-smoothstep(.85,1.7,world.y))*(1.-smoothstep(.68,.90,normal76.y));
 vec3 bank99=mix(vec3(.245,.255,.175),vec3(.34,.335,.225),soft_noise(world.xz*1.2));
 bank99=mix(bank99,vec3(.30,.36,.205),smoothstep(.35,.82,normal76.y)*.5);
 col=mix(col,bank99,shore_bank99);
"""%[g.x,g.y]
	shader.code=code.replace(" ALBEDO=albedo_view ?",patch+" ALBEDO=albedo_view ?")
	return shader
func _ready() -> void:
	super._ready()
	# One small static distance/width field, shared by every ground material.
	# No route searches or new texture uploads occur during gameplay.
	var field := Image.create(256,256,false,Image.FORMAT_RGBF)
	for y in 256:
		for x in 256:
			var p := Vector2((x+.5)/256.*40.-20.,(y+.5)/256.*36.-18.)
			var data := LAYOUT99.info99(p)
			field.set_pixel(x,y,Color(minf(data.x/8.,1.),data.y/2.,data.z,1.))
	var texture := ImageTexture.create_from_image(field)
	for material in after_materials91: material.set_shader_parameter("park_field99",texture)
