shader_type spatial;
render_mode unshaded,cull_disabled,depth_draw_never;
uniform sampler2D paint : filter_linear_mipmap,repeat_disable;
uniform float root_start100=.834;
void fragment(){
 float a=texture(paint,UV).a;
 a+=texture(paint,UV+vec2(.008,0.)).a+texture(paint,UV-vec2(.008,0.)).a;
 a+=texture(paint,UV+vec2(0.,.008)).a+texture(paint,UV-vec2(0.,.008)).a;
 a+=texture(paint,UV+vec2(.006,.006)).a+texture(paint,UV+vec2(-.006,.006)).a;
 a+=texture(paint,UV+vec2(.006,-.006)).a+texture(paint,UV-vec2(.006,.006)).a;
 ALBEDO=vec3(.08,.12,.06);
 ALPHA=a/9.*.28*smoothstep(root_start100-.008,root_start100+.008,UV.y);
}
