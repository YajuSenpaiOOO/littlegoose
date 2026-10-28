// Numeric atlas, deliberately without source_color conversion.
uniform sampler2D route_field50 : filter_linear,repeat_disable;
uniform vec4 route_bounds50=vec4(0.,0.,1.,1.);
uniform float route_strength50=0.;
vec3 route_light50(vec3 color,vec3 position){
 if(route_strength50<=0.) return color;
 vec2 uv=(position.xz-route_bounds50.xy)/route_bounds50.zw;
 if(uv.x<0. || uv.x>1. || uv.y<0. || uv.y>1.) return color;
 vec4 field=texture(route_field50,uv);
 float height_response=mix(1.,.48,smoothstep(1.5,6.,position.y));
 return color*mix(vec3(1.),field.rgb*1.25,field.a*route_strength50*height_response);
}
