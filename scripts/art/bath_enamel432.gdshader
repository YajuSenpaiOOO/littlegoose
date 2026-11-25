shader_type spatial;

uniform sampler2D decal : source_color, filter_linear_mipmap;
varying vec2 enamel_point;
varying float facing;

void vertex() {
 enamel_point = VERTEX.xy / 0.142 + vec2(0.5);
 facing = NORMAL.z;
}

void fragment() {
 vec3 cream = texture(decal, vec2(0.10, 0.08)).rgb;
 vec2 uv = vec2(enamel_point.x, 1.0 - enamel_point.y);
 vec2 edge = abs(uv - 0.5);
 float print_mask = smoothstep(0.22, 0.61, facing) * (1.0 - smoothstep(0.39, 0.50, max(edge.x, edge.y)));
 ALBEDO = mix(cream, texture(decal, clamp(uv, 0.0, 1.0)).rgb, print_mask);
 ROUGHNESS = 0.32;
 SPECULAR = 0.38;
}
