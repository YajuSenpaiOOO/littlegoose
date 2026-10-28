uniform vec2 grove104=vec2(-49.99167,-45.65833);
uniform float woodland_strength104=1.;
uniform bool flower_petals104=false;
float patch104(vec2 p,vec2 centre,vec2 radius){vec2 q=(p-centre)/radius;return 1.-smoothstep(.08,1.,dot(q,q));}
vec3 woodland_palette104(vec3 color,vec3 at){
 vec2 p=at.xz-grove104;
 float region=1.-smoothstep(.78,1.15,length((p-vec2(0.,3.))/vec2(32.,26.)));
 if(region<.001 || woodland_strength104<.001) return color;
 vec3 c=color;
 float green=smoothstep(.018,.09,c.g-c.b)*(1.-smoothstep(.025,.15,c.r-c.g));
 float gray=dot(c,vec3(.2126,.7152,.0722));
 vec3 sage=mix(vec3(gray),c,.84)*vec3(.87,.95,1.065);
 c=mix(c,sage,green*.88);
 float rim=smoothstep(.40,1.18,length((p-vec2(0.,2.))/vec2(13.,10.)));
 float front=patch104(p,vec2(-.5,12.0),vec2(13.,5.7));
 float rear=patch104(p,vec2(-2.,-5.8),vec2(11.,4.0));
 float side=patch104(p,vec2(9.,-.5),vec2(4.3,5.7));
 float shelter=clamp(rim*.38+front*.38+rear*.26+side*.20,0.,.67);
 float ground=1.-smoothstep(3.2,6.5,at.y);
 c*=mix(vec3(1.),vec3(.65,.80,.86),shelter*mix(.62,1.,ground));
 float opening=patch104(p,vec2(-1.8,2.4),vec2(5.8,4.8));
 float small=patch104(p,vec2(5.3,5.0),vec2(3.3,2.7));
 c*=mix(vec3(1.),vec3(1.055,1.025,.94),max(opening,small*.55)*ground*.62);
 if(flower_petals104){
  float petals=smoothstep(.42,.72,min(color.r,min(color.g,color.b)));
  float lilac=patch104(p,vec2(-4.7,8.2),vec2(3.1,1.9));
  c=mix(c,c*vec3(.76,.74,1.04),lilac*petals*.80);
 }
 return mix(color,c,region*woodland_strength104);
}
