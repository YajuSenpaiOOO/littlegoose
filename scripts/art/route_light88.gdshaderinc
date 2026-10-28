uniform sampler2D route_field50 : filter_linear,repeat_disable;
uniform vec4 route_bounds50=vec4(0.,0.,1.,1.);
uniform float route_strength50=0.;
uniform sampler2D forest_field88 : filter_linear,repeat_disable;
uniform vec4 forest_bounds88=vec4(0.,0.,1.,1.);
uniform float forest_ready88=0.;
vec3 route_light50(vec3 color,vec3 position){
 if(route_strength50<=0.) return color;
 vec2 uv=(position.xz-route_bounds50.xy)/route_bounds50.zw;
 vec4 field=vec4(.8,.8,.8,0.);
 if(uv.x>=0. && uv.x<=1. && uv.y>=0. && uv.y<=1.) field=texture(route_field50,uv);
 vec2 local88=(position.xz-forest_bounds88.xy)/forest_bounds88.zw;
 if(forest_ready88>0. && local88.x>=0. && local88.x<=1. && local88.y>=0. && local88.y<=1.){
  float edge88=1.-smoothstep(.72,.98,max(abs(local88.x-.5),abs(local88.y-.5))*2.);
  field=mix(field,texture(forest_field88,local88),edge88);
 }
 float height_response=mix(1.,.48,smoothstep(1.5,6.,position.y));
 return color*mix(vec3(1.),field.rgb*1.25,field.a*route_strength50*height_response);
}
