shader_type spatial;
render_mode cull_disabled;
uniform sampler2D paint : source_color, filter_linear_mipmap, repeat_enable;
uniform float cut_height = 20.0;
varying vec3 point;
uniform vec3 house_origin = vec3(0.0);
void vertex(){point=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz - house_origin;}
void fragment(){
 if(point.y>cut_height) discard;
 vec3 normal=abs(normalize((INV_VIEW_MATRIX*vec4(NORMAL,0.0)).xyz));
 vec2 side=normal.x>normal.z ? point.zy : point.xy;
 vec2 uv=side*vec2(.33,-.41)+vec2(.56,.12);
 vec3 brush=texture(paint,uv).rgb;
 ALBEDO=brush*vec3(.89,.85,.77);
 ROUGHNESS=1.0;
 SPECULAR=.06;
}
