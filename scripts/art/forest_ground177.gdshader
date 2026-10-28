shader_type spatial;
varying vec2 local;
float line_distance(vec2 p,vec2 a,vec2 b){vec2 v=b-a;return length(p-a-v*clamp(dot(p-a,v)/dot(v,v),0.,1.));}
void vertex(){local=VERTEX.xz;}
void fragment(){
 float d=min(line_distance(local,vec2(33.,-3.),vec2(28.,-3.)),line_distance(local,vec2(28.,-3.),vec2(23.,3.)));
 d=min(d,line_distance(local,vec2(23.,3.),vec2(18.,3.)));
 d=min(d,line_distance(local,vec2(18.,3.),vec2(14.,7.)));
 d=min(d,line_distance(local,vec2(14.,7.),vec2(10.,8.)));
 float grid=max(step(.965,fract(local.x)),step(.965,fract(local.y)));
 vec3 floor_color=local.y< -12.?vec3(.44,.47,.50):vec3(.44,.48,.44);
 floor_color=mix(floor_color,vec3(.57,.52,.47),1.-smoothstep(1.2,1.85,d));
 ALBEDO=floor_color*(1.-grid*.065);ROUGHNESS=1.;SPECULAR=0.;
}
