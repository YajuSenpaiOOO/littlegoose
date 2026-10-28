shader_type spatial;
render_mode unshaded,cull_disabled;
uniform sampler2D paint:source_color,filter_nearest,repeat_disable;
uniform float cut_y=.9;
uniform float fade=1.;
uniform vec4 tint:source_color=vec4(1.);
void vertex(){
 mat4 facing=mat4(INV_VIEW_MATRIX[0],INV_VIEW_MATRIX[1],INV_VIEW_MATRIX[2],MODEL_MATRIX[3]);
 facing[0].xyz*=length(MODEL_MATRIX[0].xyz);facing[1].xyz*=length(MODEL_MATRIX[1].xyz);facing[2].xyz*=length(MODEL_MATRIX[2].xyz);
 MODELVIEW_MATRIX=VIEW_MATRIX*facing;
}
void fragment(){
 vec2 uv=UV;
 vec4 tex=texture(paint,uv);
 if(tex.a<.6) discard;
 ALBEDO=tex.rgb*tint.rgb;ALPHA=(1.-smoothstep(cut_y-.018,cut_y,UV.y))*fade;
}
