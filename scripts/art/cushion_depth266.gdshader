shader_type spatial;
render_mode cull_disabled;
uniform sampler2D paint:source_color,filter_nearest_mipmap,repeat_disable;
uniform vec3 centre266=vec3(0.);
uniform vec3 camera266=vec3(0.);
void vertex(){
 mat4 facing=mat4(INV_VIEW_MATRIX[0],INV_VIEW_MATRIX[1],INV_VIEW_MATRIX[2],MODEL_MATRIX[3]);
 facing[0].xyz*=length(MODEL_MATRIX[0].xyz);facing[1].xyz*=length(MODEL_MATRIX[1].xyz);facing[2].xyz*=length(MODEL_MATRIX[2].xyz);
 MODELVIEW_MATRIX=VIEW_MATRIX*facing;
}
void fragment(){
 vec4 tex=texture(paint,UV);if(tex.a<.5)discard;
 // Painted top and front lip write their real support depth, not the upright display card depth.
 float height=.22*(1.-smoothstep(580./764.,713./764.,UV.y));
 vec3 world=(INV_VIEW_MATRIX*vec4(VERTEX,1.)).xyz;vec3 ray=world-camera266;
 float t=abs(ray.y)>.00001?(centre266.y+height-camera266.y)/ray.y:1.;
 vec4 clip=PROJECTION_MATRIX*VIEW_MATRIX*vec4(camera266+ray*max(t,.001),1.);
 DEPTH=clip.z/clip.w*.5+.5;ALBEDO=tex.rgb*COLOR.rgb;ROUGHNESS=1.;SPECULAR=0.;
 NORMAL=normalize((VIEW_MATRIX*vec4(0.,1.,0.,0.)).xyz);
}
