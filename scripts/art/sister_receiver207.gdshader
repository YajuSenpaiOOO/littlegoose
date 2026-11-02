shader_type spatial;
render_mode cull_disabled;
uniform sampler2D paint:source_color,filter_nearest_mipmap,repeat_disable;
uniform vec3 foot199=vec3(0.);
uniform vec3 camera199=vec3(0.);
uniform vec3 plane_normal199=vec3(0.,0.,1.);
uniform vec3 receiver_normal207=vec3(0.,.422618,.906308);
void fragment(){
 vec4 tex=texture(paint,UV);if(tex.a<.6)discard;
 vec3 world=(INV_VIEW_MATRIX*vec4(VERTEX,1.)).xyz;
 vec3 ray=world-camera199;
 float divisor=dot(ray,plane_normal199);
 float t=abs(divisor)>.00001?dot(foot199-camera199,plane_normal199)/divisor:1.;
 vec3 proxy=camera199+ray*max(t,.001);
 vec4 clip=PROJECTION_MATRIX*VIEW_MATRIX*vec4(proxy,1.);
 DEPTH=clip.z/clip.w*.5+.5;
 // Light and shadow sample the same upright proxy used for depth.
 LIGHT_VERTEX=(VIEW_MATRIX*vec4(proxy,1.)).xyz;
 NORMAL=normalize((VIEW_MATRIX*vec4(receiver_normal207,0.)).xyz);
 ALBEDO=tex.rgb*COLOR.rgb*.82;ROUGHNESS=1.;SPECULAR=0.;
}
