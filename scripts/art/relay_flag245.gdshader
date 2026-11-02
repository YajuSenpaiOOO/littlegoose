shader_type spatial;
render_mode cull_disabled;
uniform sampler2D paint:source_color,filter_nearest_mipmap,repeat_disable;
uniform vec3 foot199=vec3(0.);
uniform vec3 camera199=vec3(0.);
uniform vec3 plane_normal199=vec3(0.,0.,1.);
uniform vec2 hinge245=vec2(0.);
uniform float unfold245=1.;
uniform float angle245=0.;
uniform float flip245=1.;
uniform float opacity245=1.;
uniform float settle245=0.;
void vertex(){
 vec2 relative=VERTEX.xy-hinge245;relative.y*=unfold245;
 float cs=cos(angle245);float sn=sin(angle245);relative=mat2(vec2(cs,sn),vec2(-sn,cs))*relative;
 VERTEX.xy=hinge245+relative;VERTEX.x*=flip245;
 float rc=cos(settle245);float rs=sin(settle245);VERTEX.xy=mat2(vec2(rc,rs),vec2(-rs,rc))*VERTEX.xy;
 mat4 facing=mat4(INV_VIEW_MATRIX[0],INV_VIEW_MATRIX[1],INV_VIEW_MATRIX[2],MODEL_MATRIX[3]);
 facing[0].xyz*=length(MODEL_MATRIX[0].xyz);facing[1].xyz*=length(MODEL_MATRIX[1].xyz);facing[2].xyz*=length(MODEL_MATRIX[2].xyz);
 MODELVIEW_MATRIX=VIEW_MATRIX*facing;
}
void fragment(){
 vec4 tex=texture(paint,UV);if(tex.a<.5)discard;
 if(fract(sin(dot(FRAGCOORD.xy,vec2(12.9898,78.233)))*43758.5453)>opacity245)discard;
 // Retain native rasterization/UVs and change only depth at the fragment.
 vec3 world=(INV_VIEW_MATRIX*vec4(VERTEX,1.)).xyz;
 vec3 ray=world-camera199;
 float divisor=dot(ray,plane_normal199);
 float t=abs(divisor)>.00001?dot(foot199-camera199,plane_normal199)/divisor:1.;
 vec4 clip=PROJECTION_MATRIX*VIEW_MATRIX*vec4(camera199+ray*max(t,.001),1.);
 DEPTH=clip.z/clip.w*.5+.5;
 ALBEDO=tex.rgb*COLOR.rgb*.82;ROUGHNESS=1.;SPECULAR=0.;
 // This is already a camera-facing surface; do not tilt its normal again.
 NORMAL=vec3(0.,0.,1.);
}
