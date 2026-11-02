shader_type spatial;
render_mode cull_disabled;
uniform sampler2D paint:source_color,filter_nearest_mipmap,repeat_disable;
uniform vec3 foot199=vec3(0.);
uniform vec3 camera199=vec3(0.);
uniform vec3 plane_normal199=vec3(0.,0.,1.);
void fragment(){
 vec4 tex=texture(paint,UV);if(tex.a<.6)discard;
 vec3 world=(INV_VIEW_MATRIX*vec4(VERTEX,1.)).xyz;
 vec3 ray=world-camera199;
 float divisor=dot(ray,plane_normal199);
 float t=abs(divisor)>.00001?dot(foot199-camera199,plane_normal199)/divisor:1.;
 vec4 clip=PROJECTION_MATRIX*VIEW_MATRIX*vec4(camera199+ray*max(t,.001),1.);
 DEPTH=clip.z/clip.w*.5+.5;
 ALBEDO=tex.rgb*COLOR.rgb*.82;ROUGHNESS=1.;SPECULAR=0.;
 NORMAL=vec3(0.,0.,1.);
}
