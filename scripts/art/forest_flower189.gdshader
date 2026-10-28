shader_type spatial;
render_mode unshaded,cull_disabled;
uniform sampler2D paint:source_color,filter_nearest_mipmap,repeat_disable;
uniform vec3 push94=vec3(0.);
uniform float clock=0.;
uniform vec2 flower_y=vec2(.30,.85);
void vertex(){
 mat4 facing=mat4(INV_VIEW_MATRIX[0],INV_VIEW_MATRIX[1],INV_VIEW_MATRIX[2],MODEL_MATRIX[3]);
 facing[0].xyz*=length(MODEL_MATRIX[0].xyz);facing[1].xyz*=length(MODEL_MATRIX[1].xyz);facing[2].xyz*=length(MODEL_MATRIX[2].xyz);
 MODELVIEW_MATRIX=VIEW_MATRIX*facing;
 float tip=clamp((flower_y.y-UV.y)/(flower_y.y-flower_y.x),0.,1.);
 float plant=1.-smoothstep(.63,.80,UV.x);
 vec3 wind=vec3(sin(clock*1.45+MODEL_MATRIX[3].x*1.8)*.012,0.,0.);
 VERTEX+=(inverse(facing)*vec4(push94+wind,0.)).xyz*tip*tip*plant;
}
void fragment(){
 vec4 tex=texture(paint,UV);if(tex.a<.6)discard;
 ALBEDO=tex.rgb;
}
