shader_type spatial;
render_mode cull_disabled;
uniform sampler2D painted_fabric : source_color, repeat_disable, filter_linear_mipmap;
uniform vec4 region = vec4(0.07096354,0.18164063,0.85742188,0.62597656);
void fragment(){
 vec4 c=texture(painted_fabric,region.xy+UV*region.zw);
 ALBEDO=c.rgb;ALPHA=c.a;ALPHA_SCISSOR_THRESHOLD=0.5;
 ROUGHNESS=1.0;SPECULAR=0.02;
}
