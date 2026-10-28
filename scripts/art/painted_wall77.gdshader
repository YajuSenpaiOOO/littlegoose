shader_type spatial;
render_mode cull_disabled;
uniform sampler2D stone_paint77 : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform float tile_size77=1.8;
varying vec3 wall_at77;
varying vec3 wall_normal77;
void vertex(){wall_at77=(MODEL_MATRIX*vec4(VERTEX,1.)).xyz;wall_normal77=normalize(MODEL_NORMAL_MATRIX*NORMAL);}
void fragment(){
 vec3 n=normalize(wall_normal77);
 vec2 uv=abs(n.y)>.65?wall_at77.xz:(abs(n.z)>.6?wall_at77.xy:wall_at77.zy);
 vec3 stone=texture(stone_paint77,uv/tile_size77).rgb;
 // Painted volume remains readable on a vertical face, while actual geometry
 // still supplies silhouette, contact, directional shadows and day/night light.
 NORMAL=normalize((VIEW_MATRIX*vec4(normalize(n+vec3(0.,.65,0.)),0.)).xyz);
 ALBEDO=stone*.90;
 ROUGHNESS=1.;SPECULAR=0.;
}
