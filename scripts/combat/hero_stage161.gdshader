shader_type canvas_item;
uniform vec2 hero_uv = vec2(.5);
uniform vec2 screen_size = vec2(1600.,1000.);
uniform float strength = 0.;
void fragment() {
 vec2 delta = (SCREEN_UV-hero_uv)*screen_size;
 float local_glow = 1.-smoothstep(60.,290.,length(delta*vec2(1.,.85)));
 float edge = smoothstep(.18,.77,length((SCREEN_UV-.5)*vec2(1.,.85)));
 float darkness = (.075+.11*edge)*(1.-local_glow*.85);
 vec3 pigment = mix(vec3(.17,.15,.27),vec3(1.,.79,.36),local_glow);
 COLOR = vec4(pigment,(darkness+local_glow*.06)*strength);
}
