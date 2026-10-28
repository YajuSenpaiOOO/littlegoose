float segment96(vec2 p,vec2 a,vec2 b){vec2 ab=b-a;return length(p-a-ab*clamp(dot(p-a,ab)/dot(ab,ab),0.,1.));}
float rest_trail96(vec2 p){
 float d=segment96(p,vec2(0.,3.),vec2(-3.,2.5));
 d=min(d,segment96(p,vec2(-3.,2.5),vec2(-5.,1.5)));
 d=min(d,segment96(p,vec2(-5.,1.5),vec2(-7.,.8)));
 d=min(d,segment96(p,vec2(-7.,.8),vec2(-9.,.9)));
 return 1.-smoothstep(.28,.85,d);
}
