shader_type spatial;
render_mode cull_disabled;
uniform sampler2D paint : source_color,filter_linear_mipmap;
void fragment(){
 // The lower painted strata are opaque across the width. The mesh has a real
 // top connection; grass is never stretched down as the exposed cliff face.
 vec4 c=texture(paint,vec2(mix(.025,.975,UV.x),mix(.44,.96,UV.y)));
 ALBEDO=c.rgb;
 ROUGHNESS=1.; SPECULAR=0.;
}
