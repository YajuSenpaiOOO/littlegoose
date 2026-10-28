shader_type spatial;
render_mode unshaded,cull_disabled,depth_prepass_alpha;
uniform sampler2D paint:source_color,filter_nearest_mipmap,repeat_disable;
uniform vec4 tint:source_color=vec4(1.);
uniform float cut_y=.9;
void fragment(){
 vec4 tex=texture(paint,UV);if(tex.a<.6) discard;
 ALBEDO=tex.rgb*tint.rgb;ALPHA=smoothstep(cut_y-.018,cut_y,UV.y);
}
