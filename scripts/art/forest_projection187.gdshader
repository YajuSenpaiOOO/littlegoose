shader_type spatial;
render_mode unshaded,cull_disabled,depth_draw_never;
uniform sampler2D paint:filter_linear_mipmap,repeat_disable;
uniform vec4 region187=vec4(0.,0.,1.,1.);
uniform float opacity=.18;
void fragment(){
 vec2 px=1./vec2(textureSize(paint,0))*2.5;
 float a=texture(paint,region187.xy+UV*region187.zw).a*.4;
 a+=(texture(paint,region187.xy+UV*region187.zw+vec2(px.x,0)).a+texture(paint,region187.xy+UV*region187.zw-vec2(px.x,0)).a+texture(paint,region187.xy+UV*region187.zw+vec2(0,px.y)).a+texture(paint,region187.xy+UV*region187.zw-vec2(0,px.y)).a)*.15;
 ALBEDO=vec3(.07,.09,.13);ALPHA=a*opacity;
}
