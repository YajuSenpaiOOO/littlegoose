extends "res://scripts/art/paper_stage297.gd"
## Grass remains the arena. No flying book, floor strips or actor translation.
var layout298: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/paper_stage298/layout.json"))
var wings298: Array[Sprite3D]=[]
var gates298: Array[Node3D]=[]
var puppet298: Node3D
var dinosaur298: Sprite3D
var door_shape298: CollisionShape3D
var gate_open298 := 0.
var girl_home298 := Vector3.ZERO
func ground298(x: float,z: float) -> float:
 return battle.floor_height(Vector2(global_position.x+x,global_position.z+z))-global_position.y+.04
func card298(texture: Texture2D,spec: Dictionary,width: float,parent: Node3D) -> Sprite3D:
 var s=Sprite3D.new();s.texture=texture;s.pixel_size=width/float(spec.span[0]);s.offset=Vector2(texture.get_width()*.5-float(spec.foot[0]),float(spec.foot[1])-texture.get_height()*.5)
 s.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;s.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var ink=material(Color.WHITE);ink.albedo_texture=texture;ink.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR;ink.cull_mode=BaseMaterial3D.CULL_DISABLED;ink.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;s.material_override=ink
 parent.add_child(s);return s
func shadow298(sprite: Sprite3D,parent: Node3D) -> void:
 var holder=Girl.new();parent.add_child(holder);battle._add_actor_shadow(holder,sprite)
func collider298(at: Vector3,size: Vector3) -> CollisionShape3D:
 var body=StaticBody3D.new();body.collision_layer=2;body.collision_mask=0;body.position=at;add_child(body)
 var shape=CollisionShape3D.new();var box_shape=BoxShape3D.new();box_shape.size=size;shape.shape=box_shape;body.add_child(shape);return shape
func _ready() -> void:
 girl=Girl.new();add_child(girl);girl_home298=Vector3(-1.15,ground298(-1.15,-3.1),-3.1);girl.position=girl_home298
 visual=Sprite3D.new();visual.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;visual.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;girl.add_child(visual)
 visual.material_override=battle.hero.visual.material_override.duplicate();visual.material_override.next_pass=null;battle._add_actor_shadow(girl,visual)
 bubble=Label3D.new();bubble.font_size=48;bubble.pixel_size=.006;bubble.position=Vector3(0,2.0,0);bubble.billboard=BaseMaterial3D.BILLBOARD_ENABLED;girl.add_child(bubble)
 castle=card298(preload("res://assets/paper_stage297/castle.png"),data.castle,9.8,self);shadow298(castle,self)
 for side in [-1.,1.]:
  var s=card298(preload("res://assets/paper_stage298/scenery.png"),layout298.scenery,3.5,self);s.position=Vector3(side*5.,ground298(side*5.,1.3),1.3);s.flip_h=side>0.;wings298.append(s);shadow298(s,self)
  var col=collider298(Vector3(side*3.25,ground298(side*3.25,0)+1.1,0),Vector3(3.45,2.2,.23));bodies.append(col)
  var wing_col=collider298(Vector3(side*5.,ground298(side*5.,1.3)+.45,1.3),Vector3(2.5,.9,.2));bodies.append(wing_col)
 var gate_tex=preload("res://assets/paper_stage298/gate.png");var b: Array=layout298.gate.bounds;var half=float(layout298.gate.span[0])*.5;var height=float(layout298.gate.span[1])
 for i in 2:
  var pivot=Node3D.new();pivot.position=Vector3(-1.45 if i==0 else 1.45,.02,.02);castle.add_child(pivot);gates298.append(pivot)
  var atlas=AtlasTexture.new();atlas.atlas=gate_tex;atlas.region=Rect2(float(b[0])+float(i)*half,b[1],half,height);atlas.filter_clip=true
  var spec={"span":[half,height],"foot":[0. if i==0 else half,height]}
  var leaf=card298(atlas,spec,1.45,pivot);leaf.material_override.albedo_texture=gate_tex
 door_shape298=collider298(Vector3(0,ground298(0,0)+1.,0),Vector3(2.9,2.0,.23))
 puppet298=Girl.new();add_child(puppet298)
 dinosaur298=card298(preload("res://assets/paper_stage298/dinosaur.png"),layout298.dinosaur,1.7,puppet298);dinosaur298.rotation.x=deg_to_rad(-25.);shadow298(dinosaur298,puppet298)
 var op_spec: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/paper134/animation.json")).base
 var operator=Sprite3D.new();operator.texture=preload("res://assets/paper134/base_C.png");operator.pixel_size=.42*float(op_spec.scale)/float(op_spec.visible_height);operator.offset=Vector2(operator.texture.get_width()*.5-float(op_spec.foot[0]),float(op_spec.foot[1])-operator.texture.get_height()*.5);operator.position=Vector3(.42,.02,-.15);operator.shaded=true;puppet298.add_child(operator);shadow298(operator,puppet298)
 sample(0.)
func _process(delta: float) -> void:
 if not playing:return
 sample(age+delta)
 if age>=8.6:
  playing=false;finished=true;battle.hero.controls_enabled=saved_controls;battle.combat_paused=saved_pause
func sample(t: float) -> void:
 age=t;pose(t>=.65 and t<2.8);girl.position=girl_home298
 bubble.visible=t<.7 or t>2.9 and t<3.8
 bubble.text="啊？我的小纸怪\n怎么都趴下了！" if t<.7 else "那就看我的——开演！"
 castle.visible=t>=1.
 castle.position=Vector3(0,ground298(0,0),0)
 var lift=smoothstep(1.0,2.4,t)
 castle.rotation.x=lerpf(-PI*.5,deg_to_rad(-25.),lift)
 for i in wings298.size():
  var s=wings298[i];var reveal=smoothstep(1.25+float(i)*.15,2.7+float(i)*.15,t)
  s.visible=t>=1.25+float(i)*.15;s.rotation.x=lerpf(-PI*.5,deg_to_rad(-25.),reveal);s.position.y=ground298(s.position.x,s.position.z)+1.3*(1.-reveal)
 gate_open298=smoothstep(3.8,4.6,t)*(1.-smoothstep(7.5,8.2,t))
 for i in 2:gates298[i].rotation.y=(1. if i==0 else -1.)*gate_open298*PI*.48
 for shape in bodies:shape.disabled=t<2.9
 door_shape298.disabled=t<2.9 or gate_open298>.65
 puppet298.visible=t>=4.5
 var u=smoothstep(4.5,7.35,t)
 var target=Vector3(0,0,-1.2).lerp(Vector3(1.1,0,4.0),u)
 target.y=ground298(target.x,target.z)
 puppet298.position=target;dinosaur298.rotation.z=sin(t*10.)*.045 if t>=4.5 and t<7.35 else 0.
