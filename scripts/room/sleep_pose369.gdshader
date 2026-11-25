shader_type spatial;
render_mode unshaded,cull_disabled;
uniform sampler2D pose:source_color,filter_nearest_mipmap,repeat_disable;
uniform vec3 room_tint=vec3(.85);
uniform float breathe=0.;
void vertex(){VERTEX.y+=breathe*smoothstep(.48,.70,UV.y);}
void fragment(){vec4 p=texture(pose,UV);if(p.a<.5)discard;ALBEDO=p.rgb*room_tint;}
