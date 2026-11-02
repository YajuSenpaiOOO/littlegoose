shader_type canvas_item;
render_mode unshaded;
uniform float red263=0.0;
void fragment(){
 float r=length((UV-vec2(0.5))*2.0);
 float core=1.0-smoothstep(0.08,0.28,r);
 float halo=pow(1.0-smoothstep(0.05,1.0,r),2.0);
 vec3 outside=mix(vec3(0.30,0.83,1.0),vec3(1.0,0.24,0.35),red263);
 COLOR=vec4(mix(outside,vec3(0.95,1.0,1.0),core),.29*halo+.65*core)*COLOR;
}
