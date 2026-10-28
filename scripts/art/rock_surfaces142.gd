extends "res://scripts/art/rock_surfaces103.gd"
func _clean_shader91() -> Shader:
 var shader := super._clean_shader91()
 var g: Vector2=world.meadow.landmarks.grove
 var detail := """
 vec2 hp142=world.xz-vec2(%f,%f);
 float field142=1.-smoothstep(.90,1.12,length((hp142-vec2(-24.,-18.))/vec2(10.,14.)));
 float broad142=soft_noise(hp142*.19);
 vec3 grass_tint142=mix(vec3(.86,.97,.87),vec3(1.065,1.025,.88),smoothstep(.25,.78,broad142));
 col=mix(col,col*grass_tint142,field142*.75);
 vec2 aa142=vec2(-19.,-15.4),bb142=vec2(-23.,-19.5),cc142=vec2(-23.8,-24.),dd142=vec2(-25.7,-28.3);
 vec2 ab142=bb142-aa142,bc142=cc142-bb142,cd142=dd142-cc142;
 float trail142=length(hp142-aa142-ab142*clamp(dot(hp142-aa142,ab142)/dot(ab142,ab142),0.,1.));
 trail142=min(trail142,length(hp142-bb142-bc142*clamp(dot(hp142-bb142,bc142)/dot(bc142,bc142),0.,1.)));
 trail142=min(trail142,length(hp142-cc142-cd142*clamp(dot(hp142-cc142,cd142)/dot(cd142,cd142),0.,1.)));
 float noise142=(soft_noise(hp142*2.1)-.5)*.22;
 float path142=(1.-smoothstep(.35,1.25,trail142+noise142))*.48;
 float view142=1.-smoothstep(.45,1.18,length((hp142-dd142)/vec2(3.,2.1))+noise142);
 vec3 earth142=texture(soil_paint103,world.xz/6.8).rgb;
 earth142=mix(vec3(.49,.40,.27),earth142,.65);
 col=mix(col,earth142,max(path142,view142*.92)*field142);
 """%[g.x,g.y]
 shader.code=shader.code.replace(" ALBEDO=albedo_view ?",detail+" ALBEDO=albedo_view ?")
 return shader
