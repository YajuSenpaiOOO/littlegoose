shader_type canvas_item;
varying vec2 p;
void vertex(){p=VERTEX;}
float hash(vec2 q){return fract(sin(dot(q,vec2(127.1,311.7)))*43758.5453);}
void fragment(){
 vec2 cell=floor(p/vec2(13.0,3.0));
 float h=hash(cell);
 vec3 col=mix(vec3(0.12,0.23,0.30),vec3(0.20,0.36,0.42),h*0.45);
 float ripple=step(0.95,h)*step(0.2,sin(TIME*0.5+h*20.0));
 col=mix(col,vec3(0.40,0.51,0.52),ripple*0.35);
 COLOR=vec4(col,1.0);
}
