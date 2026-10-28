shader_type spatial;
uniform sampler2D paint: source_color,filter_linear_mipmap_anisotropic,repeat_enable;
varying vec2 local;
float segment(vec2 p,vec2 a,vec2 b){vec2 v=b-a;return length(p-a-v*clamp(dot(p-a,v)/dot(v,v),0.,1.));}
void vertex(){local=VERTEX.xz;}
void fragment(){
 vec2 uv=1.-abs(fract(local/12.)*2.-1.);
 vec3 grass=texture(paint,uv).rgb;
 float right=min(segment(local,vec2(0.,8.),vec2(3.5,3.)),min(segment(local,vec2(3.5,3.),vec2(3.5,-4.)),segment(local,vec2(3.5,-4.),vec2(0.,-8.))));
 float left=min(segment(local,vec2(0.,8.),vec2(-6.,3.)),min(segment(local,vec2(-6.,3.),vec2(-6.,-4.)),segment(local,vec2(-6.,-4.),vec2(0.,-8.))));
 float path=1.-smoothstep(.55,1.35,min(left,right));
 ALBEDO=mix(grass*vec3(.94,1.,.91),mix(grass,vec3(.36,.31,.18),.42),path*.65);
 ROUGHNESS=1.;SPECULAR=.02;
}
