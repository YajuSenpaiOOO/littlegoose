shader_type spatial;
render_mode unshaded, fog_disabled, cull_disabled, depth_draw_never, depth_test_disabled;
uniform sampler2D screen_image : hint_screen_texture, filter_linear;
uniform sampler2D depth_image : hint_depth_texture, filter_nearest;
uniform float focus_distance=15.;
uniform float radius_pixels=3.4;
void vertex(){ POSITION=vec4(VERTEX.xy,1.,1.); }
void fragment(){
 float depth=texture(depth_image,SCREEN_UV).r;
 vec3 ndc=vec3(SCREEN_UV*2.-1.,depth);
 if(CLIP_SPACE_FAR==-1.) ndc.z=depth*2.-1.;
 vec4 point=INV_PROJECTION_MATRIX*vec4(ndc,1.);
 float distance=-point.z/point.w;
 float far_focus=smoothstep(focus_distance+3.5,focus_distance+14.,distance);
 float near_focus=1.-smoothstep(3.,7.,distance);
 float amount=max(far_focus,near_focus);
 vec2 step_uv=radius_pixels/vec2(textureSize(screen_image,0));
 vec3 sharp=texture(screen_image,SCREEN_UV).rgb;
 vec3 soft=sharp*4.;
 soft+=texture(screen_image,SCREEN_UV+step_uv*vec2(1,0)).rgb*2.;
 soft+=texture(screen_image,SCREEN_UV+step_uv*vec2(-1,0)).rgb*2.;
 soft+=texture(screen_image,SCREEN_UV+step_uv*vec2(0,1)).rgb*2.;
 soft+=texture(screen_image,SCREEN_UV+step_uv*vec2(0,-1)).rgb*2.;
 soft+=texture(screen_image,SCREEN_UV+step_uv*vec2(1,1)).rgb;
 soft+=texture(screen_image,SCREEN_UV+step_uv*vec2(-1,1)).rgb;
 soft+=texture(screen_image,SCREEN_UV+step_uv*vec2(1,-1)).rgb;
 soft+=texture(screen_image,SCREEN_UV+step_uv*vec2(-1,-1)).rgb;
 ALBEDO=mix(sharp,soft/16.,amount*.85);
}
