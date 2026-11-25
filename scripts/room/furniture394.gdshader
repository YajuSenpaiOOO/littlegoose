shader_type spatial;
render_mode cull_disabled;
uniform sampler2D paint:source_color,filter_linear_mipmap,repeat_disable;
uniform vec4 region394;
uniform vec3 foot394;
uniform float depth394=1.;
uniform vec2 top_range394=vec2(.25,.55);
uniform vec4 rear_legs394=vec4(-1.);
uniform float rear_depth394=.8;
void fragment(){
 vec4 color=texture(paint,UV);if(color.a<.5)discard;
 vec2 uv=(UV-region394.xy)/region394.zw;
 float behind=depth394*(1.-smoothstep(top_range394.x,top_range394.y,uv.y));
 if(uv.y>top_range394.y && ((uv.x>rear_legs394.x && uv.x<rear_legs394.y)||(uv.x>rear_legs394.z && uv.x<rear_legs394.w)))behind=rear_depth394;
 // Reuse the room356 ray-depth strategy, with the CURRENT view for close-up cameras.
 vec3 world=(INV_VIEW_MATRIX*vec4(VERTEX,1.)).xyz;
 vec3 eye=INV_VIEW_MATRIX[3].xyz;
 vec3 ray=world-eye;
 float t=abs(ray.z)>.00001?(foot394.z-behind-eye.z)/ray.z:1.;
 // A rear-leg depth region can also intersect a painted stretcher. Keep its ray
 // above the supporting floor, otherwise the floor cuts rectangular holes in it.
 if(ray.y<-.00001)t=min(t,(.015-eye.y)/ray.y);
 vec3 proxy=eye+ray*max(t,.001);
 vec4 clip=PROJECTION_MATRIX*VIEW_MATRIX*vec4(proxy,1.);
 DEPTH=clip.z/clip.w*.5+.5;
 LIGHT_VERTEX=(VIEW_MATRIX*vec4(proxy,1.)).xyz;
 NORMAL=normalize((VIEW_MATRIX*vec4(0.,.422618,.906308,0.)).xyz);
 ALBEDO=color.rgb*.78;ROUGHNESS=1.;SPECULAR=0.;
}
