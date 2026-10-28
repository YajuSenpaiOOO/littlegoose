shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec2 hero_uv=vec2(.5);
uniform vec2 screen_size=vec2(1600.,1000.);
uniform vec2 axis_right=vec2(400.,0.);
uniform vec2 axis_forward=vec2(0.,-220.);
uniform float strength=0.;
uniform float unfold=0.;
void fragment() {
 vec4 original=textureLod(screen_texture,SCREEN_UV,0.);
 vec2 p=(SCREEN_UV-hero_uv)*screen_size;
 float det=axis_right.x*axis_forward.y-axis_right.y*axis_forward.x;
 vec2 local=vec2(p.x*axis_forward.y-p.y*axis_forward.x,axis_right.x*p.y-axis_right.y*p.x)/max(abs(det),1.)*sign(det);
 float r=length(local)/max(.04,unfold);
 float mask=1.-smoothstep(.60,1.06,r);
 vec3 peach=original.rgb*vec3(1.10,.95,1.)+vec3(.16,.052,.06);
 COLOR=vec4(mix(original.rgb,clamp(peach,vec3(0.),vec3(1.)),mask*strength*.80),original.a);
}
