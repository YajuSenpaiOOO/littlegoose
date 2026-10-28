shader_type spatial;
render_mode cull_disabled;
uniform int style59=0;
varying vec3 at59;
void vertex(){at59=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;}
float h59(vec2 p){return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);}
void fragment(){
 float grain=h59(floor(at59.xz*24.));
 float edge=smoothstep(0.,.13,UV.y)*(1.-smoothstep(.88,1.,UV.y));
 if(grain>edge) discard;
 vec3 dry=mix(vec3(.32,.30,.19),vec3(.39,.37,.27),float(style59)*.25);
 vec3 wet=vec3(.17,.24,.22);
 float pebble=smoothstep(.80,.96,h59(floor(at59.xz*5.)));
 ALBEDO=mix(dry,wet,smoothstep(.35,1.,UV.y))*(.92+grain*.16)+pebble*.07;
 ROUGHNESS=1.; SPECULAR=0.;
}
