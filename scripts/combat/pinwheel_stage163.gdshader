shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2 hero_uv = vec2(.5);
uniform vec2 screen_size = vec2(1600.,1000.);
uniform float strength = 0.;
uniform float unfold = 0.;
float grain(vec2 p) {
 p=floor(p);
 return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);
}
void fragment() {
 vec4 original=textureLod(screen_texture,SCREEN_UV,0.);
 vec2 delta=(SCREEN_UV-hero_uv)*screen_size;
 float scale=min(screen_size.x,screen_size.y);
 vec2 ellipse=delta/(vec2(.48,.34)*scale*max(.08,unfold));
 float distance=length(ellipse);
 float paper=grain((SCREEN_UV*screen_size)/18.)*.035;
 float mask=1.-smoothstep(.63+paper,1.08+paper,distance);
 vec3 peach=original.rgb*vec3(1.08,.95,.93)+vec3(.135,.049,.038);
 // Light remains local: outside the soft film the current world is untouched.
 vec3 sunset=mix(original.rgb,clamp(peach,vec3(0.),vec3(1.)),mask*strength*.72);
 float rim=exp(-pow((distance-.86)*6.,2.))*mask*strength;
 sunset+=vec3(.055,.021,.030)*rim;
 COLOR=vec4(sunset,original.a);
}
