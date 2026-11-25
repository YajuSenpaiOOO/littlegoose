shader_type spatial;
uniform sampler2D wood: source_color,repeat_enable,filter_linear_mipmap;
void fragment(){
 vec2 p=UV*vec2(4.,20.);float row=floor(p.y);p.x+=mod(row,2.)*.5;
 vec2 q=fract(p);float seam=min(min(q.x,1.-q.x)*2.,min(q.y,1.-q.y));
 float tint=fract(sin(row*17.+floor(p.x)*7.)*437.15);
 vec3 color=texture(wood,vec2(q.x,q.y*.5+fract(row*.17)*.5)).rgb;
 ALBEDO=mix(vec3(.23,.13,.075),color*mix(.89,1.08,tint),smoothstep(0.,.026,seam));
 ROUGHNESS=.94;
}
