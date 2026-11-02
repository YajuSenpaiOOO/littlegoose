extends Node3D
## A preview-only transport actor. Physical feet and visual lift are independent.
const ROOT = "res://assets/sister205/"
const DURATIONS = {"idle":1.6,"approach":1.4,"board":.75,"lift":.65,"travel":2.8,"land":.75,"alight":.75,"depart":1.4,"rest":1.5}
const ORDER = ["idle","approach","board","lift","travel","land","alight","depart","rest"]
var world: Node3D
var start_at := Vector2.ZERO
var end_at := Vector2.ZERO
var state := "idle"
var age := 0.
var elapsed := 0.
var running := true
var manual := false
var cycles := 0
var standing: Sprite3D
var seated: Sprite3D
var hammock: Sprite3D
var bats: Array[Sprite3D] = []
var cards: Array[Sprite3D] = []
var shadows: Array[MeshInstance3D] = []
var textures := {}
var manifests := {}
var body: AnimatableBody3D
var contact: MeshInstance3D
var contact_ink: ShaderMaterial
var person_at := Vector2.ZERO
var rig_at := Vector2.ZERO
var lift := 0.
var rig_visible := false
var sitting := false
var bat_frame := -1
var state_history: Array[String] = []

func _ready() -> void:
 name="SisterTransport205"
 for file in ["idle","seated","hammock","bat_up","bat_down"]:
  var texture: Texture2D=load(ROOT+file+".png")
  textures[file]=texture
  manifests[file]=opaque_bounds(texture.get_image())
 standing=make_card("idle",2.10,Vector2(.5,1.))
 seated=make_card("seated",1.98,Vector2(.5,1.))
 hammock=make_card("hammock",2.35,Vector2(.5,1.))
 for i in 2: bats.append(make_card("bat_up",.80,Vector2(.5,.86)))
 # A stable ground footprint, never the sprite rectangle or a flying shadow.
 body=AnimatableBody3D.new();body.name="GroundFootprint205";body.collision_layer=1;body.collision_mask=0;body.sync_to_physics=false
 var shape=CollisionShape3D.new();var cylinder=CylinderShape3D.new();cylinder.radius=.34;cylinder.height=.65;shape.shape=cylinder;shape.position.y=.325;body.add_child(shape);add_child(body)
 contact=MeshInstance3D.new();contact.name="GroundContact205";contact.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var plane=PlaneMesh.new();plane.size=Vector2(1.1,.75);contact.mesh=plane
 contact_ink=ShaderMaterial.new();var shader=Shader.new();shader.code="shader_type spatial;render_mode unshaded,cull_disabled,depth_draw_never;uniform float strength=.2;void fragment(){float r=length((UV-.5)*2.);ALBEDO=vec3(.025,.018,.04);ALPHA=(1.-smoothstep(.2,1.,r))*strength;}"
 contact_ink.shader=shader;contact.material_override=contact_ink;add_child(contact)
 restart()

static func opaque_bounds(img: Image) -> Rect2i:
 var lo=Vector2i(img.get_width(),img.get_height());var hi=Vector2i.ZERO
 for y in img.get_height():
  for x in img.get_width():
   if img.get_pixel(x,y).a>=.6:
    lo.x=mini(lo.x,x);lo.y=mini(lo.y,y);hi.x=maxi(hi.x,x+1);hi.y=maxi(hi.y,y+1)
 return Rect2i(lo,hi-lo)

func make_card(file: String,height: float,pivot: Vector2) -> Sprite3D:
 var sprite=Sprite3D.new();sprite.name=file.capitalize()+"205"
 sprite.texture=textures[file];sprite.centered=true;sprite.shaded=true
 sprite.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
 sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;sprite.layers=1;sprite.extra_cull_margin=3.
 var bounds: Rect2i=manifests[file]
 var anchor=Vector2(bounds.position)+Vector2(bounds.size)*pivot
 sprite.pixel_size=height/bounds.size.y
 sprite.offset=Vector2(sprite.texture.get_width()*.5-anchor.x,anchor.y-sprite.texture.get_height()*.5)
 var ink=ShaderMaterial.new();ink.shader=preload("res://scripts/art/card_depth199.gdshader");ink.set_shader_parameter("paint",sprite.texture);sprite.material_override=ink
 sprite.set_meta("source205",file);sprite.set_meta("anchor205",anchor)
 add_child(sprite);cards.append(sprite)
 # Reuse the established terrain-conforming contour shadow, not an invisible cylinder.
 var shadow=preload("res://scripts/combat/actor_shadow105.gd").new()
 shadow.battle=world;shadow.visual=sprite;shadow.opacity_scale=.45
 add_child(shadow);shadows.append(shadow)
 return sprite

func restart() -> void:
 state="idle";age=0.;elapsed=0.;running=true;person_at=start_at;rig_at=start_at+Vector2(-4.,-.4);lift=0.;cycles=0
 state_history.clear();state_history.append(state)
 evaluate()

func enter(next: String) -> void:
 state=next;age=0.;state_history.append(next)

func advance(delta: float) -> void:
 if not running: return
 elapsed+=delta;age+=delta
 while age>=float(DURATIONS[state]):
  var remaining=age-float(DURATIONS[state])
  var index=ORDER.find(state)+1
  if index==ORDER.size():
   var old=start_at;start_at=end_at;end_at=old;cycles+=1;index=0
  enter(ORDER[index]);age=remaining
 evaluate()

func _physics_process(delta: float) -> void:
 if not manual: advance(delta)

func ease205(t: float) -> float: return t*t*(3.-2.*t)

func evaluate() -> void:
 var t=clampf(age/float(DURATIONS[state]),0.,1.)
 person_at=start_at
 rig_at=start_at
 sitting=state in ["lift","travel","land"] or (state=="board" and t>=.5) or (state=="alight" and t<.5)
 rig_visible=state not in ["idle","rest"]
 lift=.08
 match state:
  "approach": rig_at=(start_at+Vector2(-4.,-.4)).lerp(start_at,ease205(t));lift=.3+sin(t*PI)*.3
  "lift": lift=lerpf(.08,.70,ease205(t))
  "travel":
   person_at=start_at.lerp(end_at,ease205(t));rig_at=person_at;lift=.70+sin(t*PI)*.18
  "land": person_at=end_at;rig_at=end_at;lift=lerpf(.70,.08,ease205(t))
  "alight": person_at=end_at;rig_at=end_at
  "depart": person_at=end_at;rig_at=end_at.lerp(end_at+Vector2(4.,-.5),ease205(t));lift=.08+ease205(t)*1.25
  "rest": person_at=end_at
 var floor_y: float=world.floor_height(person_at)
 body.global_position=Vector3(person_at.x,floor_y,person_at.y)
 contact.global_position=Vector3(person_at.x,floor_y+.03,person_at.y)
 contact_ink.set_shader_parameter("strength",.15 if sitting else .23)
 contact.scale=Vector3.ONE*(1.12 if sitting else .82)

func ground(at: Vector2) -> Vector3: return Vector3(at.x,world.floor_height(at),at.y)

func set_card(sprite: Sprite3D,foot: Vector3,shift: Vector2,roll: float=0.) -> void:
 var basis205: Basis=world.camera.global_basis
 sprite.global_basis=basis205
 # card_depth199 faces the camera itself; use actual lateral sway rather than
 # rotate a basis the shader would ignore (also keeps contour shadow aligned).
 sprite.global_position=foot+basis205.x*(shift.x+roll*2.)+basis205.y*shift.y
 var ink: ShaderMaterial=sprite.material_override
 ink.set_shader_parameter("foot199",foot+basis205.z*float(sprite.get_meta("depth205",0.)))
 ink.set_shader_parameter("camera199",world.camera.global_position)
 ink.set_shader_parameter("plane_normal199",Vector3(basis205.z.x,0.,basis205.z.z).normalized())

func pixel_point(sprite: Sprite3D,pixel: Vector2) -> Vector3:
 var anchor: Vector2=sprite.get_meta("anchor205")
 return sprite.global_position+sprite.global_basis.x*(pixel.x-anchor.x)*sprite.pixel_size+sprite.global_basis.y*(anchor.y-pixel.y)*sprite.pixel_size

func _process(_delta: float) -> void:
 if not is_instance_valid(world.camera): return
 var near205: bool=Vector2(world.hero.position.x,world.hero.position.z).distance_squared_to(person_at)<28.*28.
 contact.visible=near205
 if not near205:
  for card in cards: card.hide()
  return
 standing.visible=not sitting;seated.visible=sitting;hammock.visible=rig_visible
 for bat in bats: bat.visible=rig_visible
 var root=ground(person_at)
 var rig=ground(rig_at)+Vector3.UP*lift
 var sway=sin(elapsed*3.1)*.018 if sitting else 0.
 var bob=sin(elapsed*3.1)*.025 if state in ["travel","depart","approach"] else 0.
 standing.set_meta("depth205",.003);seated.set_meta("depth205",.004);hammock.set_meta("depth205",0.)
 set_card(standing,root,Vector2(0.,.015))
 # A short crouch masks the idle/seated key-pose cut; no geometry migration.
 if state in ["board","alight"]:
  standing.scale*=Vector3(1.,1.-sin(age/float(DURATIONS[state])*PI)*.06,1.)
 set_card(seated,rig,Vector2(0.,.08+bob),sway)
 set_card(hammock,rig,Vector2(0.,.10+bob),sway)
 # Attachment coordinates are authored on the full, complete empty hammock.
 var size=textures.hammock.get_size()
 for i in 2:
  var uv=Vector2(.089,.091) if i==0 else Vector2(.922,.091)
  var hook=pixel_point(hammock,size*uv)
  var frame=(int(elapsed*8.)+i)%2
  var texture: Texture2D=textures.bat_up if frame==0 else textures.bat_down
  var bat=bats[i]
  if int(bat.get_meta("frame205",-1))!=frame:
   bat.texture=texture
   var anchor: Vector2=bat_anchor(frame)
   bat.set_meta("anchor205",anchor);bat.set_meta("frame205",frame)
   bat.offset=Vector2(texture.get_width()*.5-anchor.x,anchor.y-texture.get_height()*.5)
   # Register to carrying ring, not changing wing bounds; update only on frame changes.
   bat.pixel_size=.80/float((manifests.bat_up as Rect2i).size.y)
   (bat.material_override as ShaderMaterial).set_shader_parameter("paint",texture)
  bat.set_meta("depth205",.002)
  set_card(bat,ground(rig_at),Vector2.ZERO)
  bat.global_position=hook
  bat.global_basis=world.camera.global_basis

func bat_anchor(frame: int) -> Vector2:
 var tex: Texture2D=textures.bat_up if frame==0 else textures.bat_down
 return tex.get_size()*Vector2(.5,.805)

func label() -> String:
 return {"idle":"姐姐等车","approach":"蝙蝠带空吊床接近","board":"扶边坐下","lift":"轻轻提起","travel":"振翅运输","land":"缓缓放下","alight":"起身落脚","depart":"空吊床离场","rest":"姐姐整理裙摆"}[state]
