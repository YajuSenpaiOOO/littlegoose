uniform float bend154=0.;
uniform float squash154=0.;
uniform float collapse154=0.;
uniform vec2 tip154=vec2(0.,.525);
vec3 balloon_warp154(vec3 point){
 float t=clamp((tip154.y-point.y)/1.05,0.,1.);
 point.x=tip154.x+(point.x-tip154.x)*(1.+squash154*.32);
 point.y=tip154.y+(point.y-tip154.y)*(1.-squash154-collapse154*.3);
 point.x+=(bend154+collapse154*.23)*t*t;
 return point;
}
