shader_type spatial;
render_mode unshaded,cull_disabled;
uniform sampler2D pose:source_color,filter_nearest_mipmap,repeat_disable;
uniform sampler2D blanket_mask:filter_nearest,repeat_disable;
uniform bool cover_mask=false;
uniform bool head_only=true;
uniform vec3 room_tint=vec3(.85);
uniform vec3 bounce=vec3(0.);
uniform float breathe=0.;
void vertex(){VERTEX.y+=breathe*smoothstep(.48,.70,UV.y);}
void fragment(){if(cover_mask && head_only && UV.y>.49)discard;if(cover_mask && texture(blanket_mask,SCREEN_UV).r>.5)discard;vec4 p=texture(pose,UV);if(p.a<.5)discard;ALBEDO=p.rgb*(room_tint+bounce);}
