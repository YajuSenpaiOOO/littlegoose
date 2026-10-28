extends "res://scripts/art/rock_surfaces99.gd"
func _clean_shader91() -> Shader:
 var shader := super._clean_shader91()
 var code: String=shader.code
 code=code.insert(code.find("\n")+1,"uniform float soil_strength103=1.;\nuniform sampler2D soil_paint103 : source_color,filter_linear_mipmap_anisotropic,repeat_enable;\n")
 var old := "vec3 sand99=mix(vec3(.42,.355,.245),vec3(.57,.48,.33),core99*.60+soft_noise(world.xz*1.4)*.25);"
 var detailed := """
 vec2 dirt_uv103=world.xz/6.8;
 vec2 dirt_mirror103=1.-abs(fract(dirt_uv103*.5)*2.-1.);
 vec3 dirt103=textureGrad(soil_paint103,dirt_mirror103,dFdx(dirt_uv103),dFdy(dirt_uv103)).rgb;
 float gray103=dot(dirt103,vec3(.299,.587,.114));dirt103=mix(vec3(gray103),dirt103,.78);
 vec3 old_sand103=mix(vec3(.42,.355,.245),vec3(.57,.48,.33),core99*.60+soft_noise(world.xz*1.4)*.25);
 vec3 sand99=mix(old_sand103,mix(vec3(.31,.29,.24),dirt103,.58)*mix(.96,1.04,core99),soil_strength103);
 """
 assert(code.contains(old));code=code.replace(old,detailed)
 var g: Vector2=world.meadow.landmarks.grove
 var transition := """
 // A grassy forecourt intentionally separates the two worn-earth approaches.
 // Broad distance falloff removes a rectangular material boundary here.
 vec2 ep103=world.xz-vec2(%f,%f);
 vec2 a103=vec2(12.8,7.9),b103=vec2(24.,14.2),ab103=b103-a103;
 float t103=clamp(dot(ep103-a103,ab103)/dot(ab103,ab103),0.,1.);
 float d103=length(ep103-a103-ab103*t103);
 float region103=(1.-smoothstep(2.5,4.0,d103))*smoothstep(-.02,.13,t103)*(1.-smoothstep(.85,1.,t103));
 vec2 grass_uv103=world.xz/6.;vec2 grass_mirror103=1.-abs(fract(grass_uv103*.5)*2.-1.);
 vec3 grass103=textureGrad(paint,grass_mirror103,dFdx(grass_uv103),dFdy(grass_uv103)).rgb;
 vec2 duv103=world.xz/6.8;vec2 dm103=1.-abs(fract(duv103*.5)*2.-1.);
 vec3 dirt103b=textureGrad(soil_paint103,dm103,dFdx(duv103),dFdy(duv103)).rgb;
 float fragments103=smoothstep(.48,.78,soft_noise(world.xz*2.3)+.12*sin(world.x*2.8+world.z*3.2));
 float walk103=(1.-smoothstep(.65,1.8,d103))*(.06+.26*fragments103);
 vec3 worn103=mix(grass103*vec3(.98,1.0,.95),dirt103b,walk103);
 col=mix(col,worn103,region103*smoothstep(.90,.98,normal76.y));
 """%[g.x,g.y]
 shader.code=code.replace(" ALBEDO=albedo_view ?",transition+" ALBEDO=albedo_view ?")
 return shader
func _ready() -> void:
 super._ready()
 var paint: Texture2D=preload("res://assets/woodland103/painted_soil103.png")
 for material in after_materials91: material.set_shader_parameter("soil_paint103",paint)
