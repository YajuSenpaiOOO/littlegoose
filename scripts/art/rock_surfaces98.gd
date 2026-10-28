extends "res://scripts/art/rock_surfaces92.gd"
const LAYOUT98=preload("res://scripts/world/park_layout98.gd")
func _rock_score91(at: Vector3,normal: Vector3) -> float:
	var p: Vector2=Vector2(at.x,at.z)-Vector2(world.meadow.landmarks.grove)
	return minf(.9-normal.y,minf((at.y-2.24)*.75,minf(p.x+46.,minf(25.-p.x,minf(p.y+39.,26.-p.y)))))
func _clean_shader91() -> Shader:
	var shader := super._clean_shader91()
	var code: String=shader.code
	code=code.insert(code.find("\n")+1,"uniform sampler2D park_field98 : filter_linear,repeat_disable;\n")
	var g: Vector2=world.meadow.landmarks.grove
	var patch := """
 vec2 p98=world.xz-vec2(%f,%f);
 vec2 stair_delta98=p98-vec2(-10.625,1.7);
 vec2 stair98=vec2(.975897*stair_delta98.x-.21823*stair_delta98.y,.21823*stair_delta98.x+.975897*stair_delta98.y)+vec2(-10.625,1.7);
 if(abs(stair98.x+10.625)<1.35 && stair98.y> -2.75 && stair98.y<1.9) discard;
 if(p98.x> -20. && p98.x<20. && p98.y> -18. && p98.y<18.){
  vec2 tile98=world.xz/6.;vec2 mirror98=1.-abs(fract(tile98*.5)*2.-1.);
  col=textureGrad(paint,mirror98,dFdx(tile98),dFdy(tile98)).rgb;
  vec2 field98=texture(park_field98,(p98+vec2(20.,18.))/vec2(40.,36.)).rg;
  float dist98=field98.r*8.;float width98=field98.g*2.;
  float irregular98=(soft_noise(world.xz*2.7)-.5)*.43+(soft_noise(world.xz*6.1)-.5)*.18;
  float wear98=(1.-smoothstep(width98*.85+irregular98,width98*1.2+irregular98,dist98))*smoothstep(.88,.98,normal76.y);
  float core98=1.-smoothstep(width98*.16,width98*.85,dist98);
  vec3 sand98=mix(vec3(.42,.355,.245),vec3(.57,.48,.33),core98*.60+soft_noise(world.xz*1.4)*.25);
  float patches98=smoothstep(.34,.68,soft_noise(world.xz*3.5));
  col=mix(col,sand98,wear98*(.82+.16*patches98));
 }
"""%[g.x,g.y]
	shader.code=code.replace(" ALBEDO=albedo_view ?",patch+" ALBEDO=albedo_view ?")
	return shader
func _ready() -> void:
	super._ready()
	# One small static distance/width field, shared by every ground material.
	# No route searches or new texture uploads occur during gameplay.
	var field := Image.create(256,256,false,Image.FORMAT_RGF)
	for y in 256:
		for x in 256:
			var p := Vector2((x+.5)/256.*40.-20.,(y+.5)/256.*36.-18.)
			var data := LAYOUT98.info98(p)
			field.set_pixel(x,y,Color(minf(data.x/8.,1.),data.y/2.,0.,1.))
	var texture := ImageTexture.create_from_image(field)
	for material in after_materials91: material.set_shader_parameter("park_field98",texture)
