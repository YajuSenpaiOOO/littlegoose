shader_type canvas_item;
render_mode unshaded;
uniform float flow=0.0;
uniform float red263=0.0;
void fragment(){
 float d=abs(UV.y*2.0-1.0);
 float core=1.0-smoothstep(0.16,0.43,d);
 float edge=1.0-smoothstep(0.40,1.0,d);
 float moving=0.96+0.04*sin(UV.x*6.283185-flow*6.283185);
 vec3 outside=mix(vec3(0.24,0.76,1.0),vec3(1.0,0.24,0.36),red263);
 vec3 ink=mix(outside,vec3(0.94,0.99,1.0),core);
 COLOR=vec4(ink,(0.50*edge+0.49*core)*moving)*COLOR;
}
