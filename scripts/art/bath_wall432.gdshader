shader_type spatial;

uniform sampler2D finish : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform sampler2D exposed_bricks : source_color, filter_linear_mipmap_anisotropic, repeat_enable;
uniform bool has_exposed_bricks = false;
uniform vec2 repeats = vec2(1.0);
uniform vec3 tint : source_color = vec3(1.0);
varying vec2 surface_uv;
varying vec2 wall_point;

void vertex() {
 float across = abs(NORMAL.x) > 0.5 ? VERTEX.z : VERTEX.x;
 wall_point = vec2(across, VERTEX.y);
 surface_uv = vec2(wall_point.x, -wall_point.y) * repeats + vec2(0.5);
}

void fragment() {
 ALBEDO = texture(finish, surface_uv).rgb * tint;
 if (has_exposed_bricks) {
  float chips = sin(wall_point.x * 52.0 + cos(wall_point.y * 49.0)) * 0.08 +
                sin(wall_point.x * 25.0 - wall_point.y * 43.0) * 0.07;
  float left = length((wall_point - vec2(-1.12, -0.68)) / vec2(0.31, 0.23));
  float right = length((wall_point - vec2(1.31, -0.72)) / vec2(0.30, 0.18));
  float edge = 1.0 - smoothstep(0.76, 1.01, min(left, right) + chips);
  vec2 brick_uv = vec2(wall_point.x * 1.65, -(wall_point.y + 0.84) * 1.90) + vec2(0.5);
  vec3 brick = texture(exposed_bricks, brick_uv).rgb * vec3(0.91, 0.90, 0.87);
  ALBEDO = mix(ALBEDO, brick, edge * 0.88);
 }
 ROUGHNESS = 0.96;
 SPECULAR = 0.12;
}
