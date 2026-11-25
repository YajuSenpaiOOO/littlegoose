shader_type spatial;
render_mode cull_disabled;
uniform sampler2D paint : source_color, hint_default_white, filter_linear_mipmap, repeat_enable;
uniform vec4 tint : source_color = vec4(1.0);
uniform vec3 glow : source_color = vec3(0.0);
uniform float cut_height = 10.0;
uniform float coverage423 = 1.0;
uniform float edge_noise = 1.0;
uniform float keep_behind = -100.0;
uniform bool use_vertex_color = false;
varying vec3 world_pos;
uniform vec3 house_origin = vec3(0.0);
void vertex() { world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz - house_origin; }
void fragment() {
 vec3 cell = floor(world_pos * 90.0);
 float noise = fract(sin(dot(cell, vec3(12.9898, 78.233, 37.719))) * 43758.5453);
 if (noise >= coverage423) discard;
 if (world_pos.z > keep_behind + (noise - 0.5) * 0.10 * edge_noise && world_pos.y + (noise - 0.5) * 0.24 * edge_noise > cut_height) discard;
 ALBEDO = texture(paint, UV).rgb * tint.rgb * (use_vertex_color ? COLOR.rgb : vec3(1.0));
 EMISSION = glow;
 ROUGHNESS = 1.0;
 SPECULAR = 0.1;
}
