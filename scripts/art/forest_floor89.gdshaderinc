uniform sampler2D soil_field89 : filter_linear,repeat_disable;
uniform vec4 soil_bounds89=vec4(0.,0.,1.,1.);
uniform float floor_strength89=1.;
vec3 forest_floor89(vec3 col,vec3 at,vec3 normal,float path){
 vec2 uv=(at.xz-soil_bounds89.xy)/soil_bounds89.zw;
 if(uv.x<0. || uv.y<0. || uv.x>1. || uv.y>1.) return col;
 float border=1.-smoothstep(.78,.99,max(abs(uv.x-.5),abs(uv.y-.5))*2.);
 float flat89=smoothstep(.80,.96,normal.y);
 float grain89=soft_noise(floor(at.xz/.06)*5.);
 float ragged=soft_noise(at.xz*2.4);
 float roots=texture(soil_field89,uv).r;
 float duff=smoothstep(.16,.75,roots+(ragged-.5)*.23)*flat89*(1.-path)*border;
 // Actual tree bases determine the leaf litter, rather than a dark arena ring.
 vec3 litter=mix(vec3(.20,.185,.115),vec3(.32,.275,.17),grain89);
 float leaves=step(.92,grain(floor(at.xz*12.)));
 litter=mix(litter,vec3(.43,.34,.18),leaves*.42);
 col=mix(col,litter,duff*.79*floor_strength89);
 // Broad interlocking worn turf, with small texture grain retained above it.
 float clearing=1.-smoothstep(.65,1.3,length((at.xz-soil_bounds89.xy-soil_bounds89.zw*.5)/vec2(23.,18.)));
 float wear=smoothstep(.43,.72,soft_noise(at.xz*.24+vec2(7.,13.))+(ragged-.5)*.12);
 vec3 turf=mix(col*vec3(.83,.84,.78),vec3(.32,.29,.17),wear*.55);
 col=mix(col,turf,clearing*flat89*(1.-path)*floor_strength89*.7);
 // Side planes keep their painted detail; a restrained cool tint separates them.
 float rock=(1.-smoothstep(.72,.93,normal.y))*border;
 col=mix(col,col*vec3(.76,.81,.87),rock*.45*floor_strength89);
 return col;
}

