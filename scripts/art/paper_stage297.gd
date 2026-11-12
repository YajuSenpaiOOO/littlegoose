extends Node3D
## Opening-only prototype; stage footprints become solid after unfolding.
class Girl:
 extends Node3D
 var shadow: MeshInstance3D
var battle: Node3D
var girl: Node3D
var visual: Sprite3D
var castle: Sprite3D
var book: Node3D
var halves: Array[Node3D]=[]
var lanes: Array[MeshInstance3D]=[]
var bodies: Array[CollisionShape3D]=[]
var bubble: Label3D
var plinth: MeshInstance3D
var age := 0.
var playing := false
var finished := false
var saved_controls := true
var saved_pause := false
var data: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/paper_stage297/layout.json"))
const IDLE=preload("res://assets/paper_girl295/idle_front.png")
const THROW=preload("res://assets/paper_stage297/throw.png")
func material(color: Color) -> StandardMaterial3D:
 var m=StandardMaterial3D.new();m.albedo_color=color.darkened(.30);m.roughness=1.;m.metallic_specular=0.;return m
func box(parent: Node3D,at: Vector3,size: Vector3,color: Color) -> MeshInstance3D:
 var node=MeshInstance3D.new();var mesh=BoxMesh.new();mesh.size=size;node.mesh=mesh;node.material_override=material(color);node.position=at;parent.add_child(node);return node
func _ready() -> void:
 girl=Girl.new();add_child(girl)
 visual=Sprite3D.new();visual.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;visual.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;visual.alpha_cut=SpriteBase3D.ALPHA_CUT_DISCARD;girl.add_child(visual)
 var receiver=battle.hero.visual.material_override.duplicate();receiver.next_pass=null;visual.material_override=receiver
 battle._add_actor_shadow(girl,visual)
 bubble=Label3D.new();bubble.text="啊？我的小纸怪\n怎么都趴下了！";bubble.font_size=54;bubble.pixel_size=.006;bubble.position=Vector3(0,2.0,0);bubble.billboard=BaseMaterial3D.BILLBOARD_ENABLED;girl.add_child(bubble)
 castle=Sprite3D.new();castle.texture=preload("res://assets/paper_stage297/castle.png");castle.pixel_size=6.4/float(data.castle.span[0]);castle.offset=Vector2(castle.texture.get_width()*.5-float(data.castle.foot[0]),float(data.castle.foot[1])-castle.texture.get_height()*.5);castle.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;castle.alpha_cut=SpriteBase3D.ALPHA_CUT_DISCARD;castle.shaded=true;castle.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(castle)
 var card=material(Color.WHITE);card.albedo_texture=castle.texture;card.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR;card.cull_mode=BaseMaterial3D.CULL_DISABLED;card.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;castle.material_override=card
 pass_shadow297()
 plinth=box(self,Vector3(-1.85,.475,-1.35),Vector3(1.2,.95,.9),Color("bba184"))
 for side in [-1.,1.]:
  var lane=box(self,Vector3(side*1.8,.035,1.7),Vector3(1.45,.025,3.8),Color("d4bfa5"));lane.rotation.y=side*.13;lanes.append(lane)
  var body=StaticBody3D.new();body.collision_layer=2;body.collision_mask=0;body.position=Vector3(side*2.15,.6,-.4);add_child(body)
  var shape=CollisionShape3D.new();var cube=BoxShape3D.new();cube.size=Vector3(2.05,1.2,.20);shape.shape=cube;body.add_child(shape);bodies.append(shape)
 book=Node3D.new();add_child(book)
 for side in [-1.,1.]:
  var hinge=Node3D.new();book.add_child(hinge);halves.append(hinge)
  box(hinge,Vector3(side*.24,0,0),Vector3(.48,.72,.065),Color("ab7668"))
  box(hinge,Vector3(side*.24,0,-.045),Vector3(.44,.66,.025),Color("eee2bf"))
  for i in 3:box(hinge,Vector3(side*.40,.15-float(i)*.12,-.065-float(i)*.002),Vector3(.10,.08,.008),[Color("b2cad6"),Color("edd18e"),Color("dcb5ba")][i])
 sample(0.)
func pass_shadow297() -> void:
 var holder=Girl.new();add_child(holder);battle._add_actor_shadow(holder,castle)
func pose(throwing: bool) -> void:
 visual.texture=THROW if throwing else IDLE
 var foot=Vector2(data.throw.foot[0],data.throw.foot[1]) if throwing else Vector2(542.5,1387.)
 visual.pixel_size=1.6/(float(data.throw.span[1]) if throwing else 1268.)
 visual.offset=Vector2(visual.texture.get_width()*.5-foot.x,foot.y-visual.texture.get_height()*.5)
 visual.material_override.albedo_texture=visual.texture
func start() -> void:
 if playing:return
 saved_controls=battle.hero.controls_enabled;saved_pause=battle.combat_paused
 battle.hero.controls_enabled=false;battle.hero.velocity=Vector3.ZERO;battle.hero.locomotion=Vector2.ZERO;battle.combat_paused=true
 age=0.;playing=true;finished=false;sample(0.)
func _process(delta: float) -> void:
 if playing:
  sample(age+delta)
  if age>=5.1:
   playing=false;finished=true;battle.hero.controls_enabled=saved_controls;battle.combat_paused=saved_pause
func sample(t: float) -> void:
 age=t;pose(t>=.72 and t<4.65)
 var move=smoothstep(3.6,4.65,t)
 girl.position=Vector3.ZERO.lerp(Vector3(-1.85,.95,-1.35),move)
 bubble.visible=t<.72 or (t>4.65 and t<5.1)
 bubble.text="开演了！" if t>4.65 else "啊？我的小纸怪\n怎么都趴下了！"
 book.visible=t>=.72 and t<4.65
 var toss=clampf((t-.72)/.90,0.,1.)
 book.position=Vector3(0,.65,0).lerp(Vector3(0,3.7,-.35),sin(toss*PI*.5))
 if t>3.4:book.position=book.position.lerp(girl.position+Vector3(0,.65,0),smoothstep(3.4,4.65,t))
 book.rotation.z=sin(toss*PI)*.2;book.rotation.x=-.15;book.rotation.y=PI
 for i in 2:halves[i].rotation.y=(-1. if i==0 else 1.)*PI*.5*(1.-smoothstep(1.15,1.9,t))
 castle.visible=t>=1.95
 castle.position=Vector3(0,lerpf(1.8,.065,smoothstep(1.95,2.7,t)),-.4)
 var fold=smoothstep(2.65,3.6,t)
 castle.rotation.x=lerpf(-PI*.5,deg_to_rad(-25.),fold)+sin(maxf(0.,t-3.6)*15.)*.045*exp(-maxf(0.,t-3.6)*6.) if t>3.6 else lerpf(-PI*.5,deg_to_rad(-25.),fold)
 for i in lanes.size():
  lanes[i].visible=t>=1.9;lanes[i].scale.z=maxf(.01,smoothstep(1.9+float(i)*.12,2.85+float(i)*.12,t))
 plinth.visible=t>=3.6;plinth.scale.y=maxf(.01,smoothstep(3.6,4.65,t))
 for shape in bodies:shape.disabled=t<4.65
func cancel() -> void:
 if playing:battle.hero.controls_enabled=saved_controls;battle.combat_paused=saved_pause
 playing=false
func _exit_tree() -> void:cancel()
