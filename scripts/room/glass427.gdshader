shader_type spatial;
render_mode cull_disabled, unshaded, depth_draw_never;
uniform float cut_height = 12.0;
varying vec3 point;
uniform vec3 house_origin = vec3(0.0);
void vertex(){point=(MODEL_MATRIX*vec4(VERTEX,1.0)).xyz - house_origin;}
void fragment(){
 if(point.y>cut_height) discard;
 float edge=pow(1.0-abs(dot(normalize(NORMAL),normalize(VIEW))),2.0);
 float streak=1.0-smoothstep(.025,.055,abs(fract(UV.x-UV.y*.33+.4)-.16));
 ALBEDO=vec3(.76,.87,.83);
 ALPHA=.095+edge*.17+streak*.075;
}
