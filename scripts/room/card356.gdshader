shader_type spatial;
render_mode cull_disabled;
uniform sampler2D paint:source_color,filter_linear_mipmap,repeat_disable;
uniform vec4 region356=vec4(0.,0.,1.,1.);
uniform vec3 foot356=vec3(0.);
uniform vec3 camera356=vec3(0.);
uniform float depth356=0.;
uniform float back356=.20;
uniform float front356=.80;
uniform vec3 receiver356=vec3(0.,.422618,.906308);
void fragment(){
 vec4 color=texture(paint,UV);if(color.a<.5)discard;
 vec2 local_uv=(UV-region356.xy)/region356.zw;
 // Painted beds have real depth: the front is at the footboard, the head is at the rear.
 // Only write depth/light coordinates; never stretch or shear the artwork silhouette.
 float behind=depth356*(1.-clamp((local_uv.y-back356)/(front356-back356),0.,1.));
 vec3 world=(INV_VIEW_MATRIX*vec4(VERTEX,1.)).xyz;
 vec3 ray=world-camera356;
 float t=abs(ray.z)>.00001?(foot356.z-behind-camera356.z)/ray.z:1.;
 vec3 proxy=camera356+ray*max(t,.001);
 vec4 clip=PROJECTION_MATRIX*VIEW_MATRIX*vec4(proxy,1.);
 DEPTH=clip.z/clip.w*.5+.5;
 LIGHT_VERTEX=(VIEW_MATRIX*vec4(proxy,1.)).xyz;
 NORMAL=normalize((VIEW_MATRIX*vec4(receiver356,0.)).xyz);
 ALBEDO=color.rgb*COLOR.rgb*.82;ROUGHNESS=1.;SPECULAR=0.;
}
