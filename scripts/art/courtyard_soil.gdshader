shader_type canvas_item;
varying vec2 ground_position;
float hash(vec2 p) { return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453); }
void vertex() { ground_position=VERTEX; }
void fragment() {
    vec4 base=COLOR;
    float grain=hash(floor(ground_position));
    float broad=hash(floor(ground_position/7.0));
    base.rgb*=0.96+broad*0.06;
    if(grain>0.965) base.rgb*=0.87;
    if(grain<0.035) base.rgb*=1.055;
    COLOR=base;
}
