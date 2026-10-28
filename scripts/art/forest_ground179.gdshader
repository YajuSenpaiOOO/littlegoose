shader_type spatial;
uniform sampler2D paint:source_color,filter_linear_mipmap,repeat_enable;
varying vec2 local;
float segment(vec2 p,vec2 a,vec2 b){vec2 v=b-a;return length(p-a-v*clamp(dot(p-a,v)/dot(v,v),0.,1.));}
void vertex(){local=VERTEX.xz;}
void fragment(){
 float d=min(segment(local,vec2(33.,-3.),vec2(28.,-3.)),segment(local,vec2(28.,-3.),vec2(23.,3.)));
 d=min(d,segment(local,vec2(23.,3.),vec2(18.,3.)));d=min(d,segment(local,vec2(18.,3.),vec2(14.,7.)));d=min(d,segment(local,vec2(14.,7.),vec2(10.,8.)));
 vec3 grass=texture(paint,1.-abs(fract(local/12.)*2.-1.)).rgb;
 float luma=dot(grass,vec3(.299,.587,.114));grass=mix(grass,vec3(luma*.70,luma*.85,luma*1.05),.7);
 vec3 tint=mix(vec3(.55,.65,.74),vec3(.67,.68,.72),smoothstep(12.,30.,local.x));
 vec3 soil=mix(grass,vec3(.38,.32,.29),.55);
 ALBEDO=mix(grass*tint,soil*tint,(1.-smoothstep(1.0,1.9,d))*.8);
 ROUGHNESS=1.;SPECULAR=0.;
}
