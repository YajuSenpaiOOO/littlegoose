shader_type canvas_item;
render_mode unshaded;

uniform sampler2D scene : hint_screen_texture, repeat_disable, filter_linear;
uniform float amount = 0.;

void fragment() {
 vec2 offset=SCREEN_PIXEL_SIZE*amount*4.0;
 vec3 center=texture(scene,SCREEN_UV).rgb;
 vec3 soft=center*.32;
 soft+=texture(scene,SCREEN_UV+offset).rgb*.17;
 soft+=texture(scene,SCREEN_UV-offset).rgb*.17;
 soft+=texture(scene,SCREEN_UV+vec2(offset.x,-offset.y)).rgb*.17;
 soft+=texture(scene,SCREEN_UV+vec2(-offset.x,offset.y)).rgb*.17;
 COLOR=vec4(mix(center,soft,amount)*mix(1.,.91,amount),1.);
}
