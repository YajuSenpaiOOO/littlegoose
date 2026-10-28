shader_type canvas_item;
uniform sampler2D material_atlas : source_color, filter_nearest, repeat_disable;
uniform bool paving = false;
uniform vec2 repeat_size = vec2(150.0,300.0);
uniform vec3 tint : source_color = vec3(1.0);
uniform vec2 edge_points[64];
uniform int edge_count = 0;
uniform float shoulder = 5.5;
varying vec2 ground_position;
float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
float patch_noise(vec2 p) {
    vec2 cell=floor(p);
    vec2 w=fract(p);
    w=w*w*(3.0-2.0*w);
    return mix(mix(hash(cell),hash(cell+vec2(1.0,0.0)),w.x),mix(hash(cell+vec2(0.0,1.0)),hash(cell+vec2(1.0)),w.x),w.y);
}
float edge_distance(vec2 p,vec2 a,vec2 b) {
    vec2 ab=b-a;
    return length(p-a-ab*clamp(dot(p-a,ab)/max(dot(ab,ab),0.001),0.0,1.0));
}
void vertex() { ground_position=VERTEX; }
void fragment() {
    // Both panels remain in one source bitmap. Crop in the sampler, never
    // stretch a screenshot or bake scenery into this ground layer.
    vec2 tile=1.0-abs(fract((floor(ground_position)+vec2(113.0,67.0))/repeat_size*0.5)*2.0-1.0);
    vec2 atlas_uv=vec2((paving?0.0:0.5)+0.001+tile.x*0.498,0.001+tile.y*0.998);
    vec3 albedo=texture(material_atlas,atlas_uv).rgb*tint;
    float edge=10000.0;
    for(int i=0;i<64;i++) {
        if(i>=edge_count) break;
        int next_index=(i+1)%edge_count;
        edge=min(edge,edge_distance(ground_position,edge_points[i],edge_points[next_index]));
    }
    float erosion=hash(floor(ground_position/3.0))*3.2+hash(floor(ground_position))*1.3;
    float coverage=smoothstep(0.3,shoulder,edge-erosion);
    if(paving) {
        float grass_pocket=smoothstep(0.65,0.82,patch_noise(ground_position/vec2(15.0,12.0)+vec2(7.0,3.0)));
        coverage*=1.0-grass_pocket*smoothstep(12.0,75.0,ground_position.y);
    }
    COLOR=vec4(albedo,coverage);
}
