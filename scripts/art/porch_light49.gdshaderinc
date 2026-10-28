// A fixed canopy opening around home. Evaluated on surfaces, never screen UVs.
uniform float porch_light_strength49=0.;
varying vec3 porch_position49;
vec3 porch_light49(vec3 color,vec3 position){
 if(porch_light_strength49<=0.) return color;
 vec2 p=position.xz-vec2(-4.7,-2.8);
 float home=1.-smoothstep(10.,17.,length(p));
 float opening=exp(-dot((p-vec2(.9,-1.))/vec2(3.7,3.1),(p-vec2(.9,-1.))/vec2(3.7,3.1)));
 float canopy=.5+.5*sin(p.x*.61+p.y*.28+sin(p.y*.67)*.7);
 float shelter=(1.-opening)*(.75+canopy*.25);
 shelter*=mix(1.,.52,smoothstep(1.5,5.5,position.y));
 vec3 tint=mix(vec3(1.),vec3(.38,.55,.57),shelter);
 tint=mix(tint,vec3(1.10,1.04,.91),opening);
 float luma=dot(color,vec3(.2126,.7152,.0722));
 vec3 quiet=mix(vec3(luma)*vec3(.94,1.,.93),color,.88);
 return mix(color,quiet*tint,home*porch_light_strength49);
}
