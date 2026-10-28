shader_type canvas_item;
render_mode unshaded;
uniform sampler2D grass_texture : source_color, filter_linear;
uniform sampler2D dirt_texture : source_color, filter_linear;
uniform vec4 ground_bounds = vec4(-1400.0,-1400.0,2800.0,2800.0);

float hash(vec2 p) {
    return fract(sin(dot(p,vec2(127.1,311.7)))*43758.5453);
}
float noise(vec2 p) {
    vec2 i=floor(p), f=fract(p);
    f=f*f*(3.0-2.0*f);
    return mix(mix(hash(i),hash(i+vec2(1.0,0.0)),f.x),mix(hash(i+vec2(0.0,1.0)),hash(i+vec2(1.0,1.0)),f.x),f.y);
}
vec2 mirrored(vec2 p) { return abs(fract(p*0.5)*2.0-1.0); }
float root_contact(vec2 p,vec2 center,vec2 radius) {
    float d=length((p-center)/radius);
    return (1.0-smoothstep(0.25,1.0,d))*0.075;
}
void fragment() {
    vec2 world=ground_bounds.xy+UV*ground_bounds.zw;
    vec3 grass=texture(grass_texture,mirrored(world/1000.0+vec2(0.37,0.12))).rgb;
    vec3 dirt=texture(dirt_texture,mirrored(world/720.0+vec2(0.1,0.3))).rgb;
    float road_x=18.0*sin((world.y+130.0)/330.0)+max(world.y-420.0,0.0)*0.18;
    float width=78.0+smoothstep(200.0,950.0,world.y)*35.0;
    float broken_edge=(noise(world*0.025)-0.5)*22.0+(noise(world*0.1)-0.5)*9.0;
    float road=(1.0-smoothstep(-9.0,10.0,abs(world.x-road_x)-width+broken_edge))*smoothstep(-170.0,-125.0,world.y);
    vec2 yard=abs(world-vec2(0.0,-245.0))-vec2(193.0,128.0);
    float apron=1.0-smoothstep(-6.0,20.0,length(max(yard,vec2(0.0)))+min(max(yard.x,yard.y),0.0)+broken_edge*0.45);
    float soil=max(road,apron*0.85);
    vec3 surface=mix(grass,dirt,soil);
    float contact=root_contact(world,vec2(-443.0,28.0),vec2(55.0,30.0));
    contact+=root_contact(world,vec2(452.0,-32.0),vec2(50.0,28.0));
    contact+=root_contact(world,vec2(255.0,347.0),vec2(102.0,42.0));
    surface*=1.0-contact;
    COLOR=vec4(surface,1.0);
}
