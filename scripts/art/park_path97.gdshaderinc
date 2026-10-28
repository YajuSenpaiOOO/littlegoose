vec2 park_loop97(float a){return vec2(1.15+9.9*cos(a)+.51*sin(3.*a),8.5*sin(a)+.51*sin(2.*a));}
float park_segment97(vec2 p,vec2 a,vec2 b){vec2 ab=b-a;return length(p-a-ab*clamp(dot(p-a,ab)/dot(ab,ab),0.,1.));}
float park_path97(vec2 p){
 float angle=atan(p.y/8.5,(p.x-1.15)/9.9);
 float d=length(p-park_loop97(angle));
 d=min(d,park_segment97(p,vec2(-8.7,1.7),vec2(-10.625,1.7)));
 d=min(d,park_segment97(p,vec2(10.2,-5.95),vec2(11.05,-5.1)));
 return d;
}
