extends "res://scripts/room/room_shell361.gd"
var layered362: Node3D
var front362: Sprite3D
var sleeper362: Sprite3D
var base362: Sprite3D
var slot_debug362: Node3D
var anchors362: Array[Node3D]=[]
var covers362: Array[Texture2D]=[]
var actors362: Array[Sprite3D]=[]
var mode362:=0
var use_layers362:=true
var cover_shown362:=true
var contact362: MeshInstance3D
var t362:=0.
var lamps362: Array=[]
const PIXEL362:=2.65/985.
func build_furniture() -> void:
 super.build_furniture()
 var row:=item356("bed");row.title="分层双人床"
 layered362=Node3D.new();layered362.name="PaintedLayeredBed362";row.root.add_child(layered362)
 layered362.global_basis=world.camera.global_basis
 layered362.global_position=row.root.global_position+Vector3(0.,.02,1.57)
 var ground:=PlaneMesh.new();ground.size=Vector2(2.85,3.25)
 var shadow:=ShaderMaterial.new();shadow.shader=preload("res://scripts/art/foot_contact16.gdshader")
 contact362=shape(row.root,ground,Vector3(0.,.013,0.),shadow);contact362.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 base362=layer362("bed_base.png",0.)
 for file in ["cover_empty.png","cover_single.png","cover_double.png"]:covers362.append(source356("res://assets/room362/"+file))
 front362=layer362("cover_empty.png",.024)
 sleeper362=Sprite3D.new();sleeper362.name="HeroSleepingPose";sleeper362.texture=source356("res://assets/room362/hero_sleep.png");sleeper362.pixel_size=PIXEL362*650./sleeper362.texture.get_height()
 sleeper362.position=Vector3((480.-656.)*PIXEL362,(1127.-565.)*PIXEL362,.012)
 sleeper362.shaded=false;sleeper362.alpha_cut=SpriteBase3D.ALPHA_CUT_DISCARD;sleeper362.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS;sleeper362.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 layered362.add_child(sleeper362);actors362.append(sleeper362)
 slot_debug362=Node3D.new();slot_debug362.name="SleepAnchors_DebugOnly";row.root.add_child(slot_debug362)
 for x in [-.56,.56]:
  var anchor:=Node3D.new();anchor.name="SleepLeft" if x<0. else "SleepRight_Reserved";anchor.position=Vector3(x,.81,-1.0);row.root.add_child(anchor);anchors362.append(anchor)
  var mat:=StandardMaterial3D.new();mat.albedo_color=Color(.3,.7,.85,.65);mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
  var mesh:=BoxMesh.new();mesh.size=Vector3(.65,.06,1.25)
  shape(slot_debug362,mesh,Vector3(x,.85,-.35),mat).cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 slot_debug362.hide()
 lamps362=item356("bedside").root.find_children("*","OmniLight3D",true,false)
 set_mode362(0);apply362()
func layer362(file: String,depth: float) -> Sprite3D:
 var sprite:=Sprite3D.new();sprite.name=file.get_basename();sprite.texture=source356("res://assets/room362/"+file)
 sprite.pixel_size=PIXEL362;sprite.offset=Vector2(sprite.texture.get_width()*.5-656.,1127.-sprite.texture.get_height()*.5);sprite.position.z=depth
 sprite.shaded=false;sprite.alpha_cut=SpriteBase3D.ALPHA_CUT_DISCARD;sprite.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS;sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 layered362.add_child(sprite);return sprite
func set_mode362(value: int) -> void:
 mode362=clampi(value,0,2)
 if not is_instance_valid(front362):return
 front362.texture=covers362[mode362];front362.visible=cover_shown362;sleeper362.visible=mode362>0
func apply362() -> void:
 if not is_instance_valid(layered362):return
 layered362.visible=art356 and use_layers362
 contact362.visible=art356 and use_layers362
 bed360.visible=art356 and not use_layers362
 bed358.hide()
 for row in cards356:
  if row.id=="bed":row.sprite.hide();row.shadow.hide()
 # 361 floor contact only; no duplicate long shadow from the hidden solid assembly.
 contact361.visible=not use_layers362 and painted361
func set_art356(value: bool) -> void:
 super.set_art356(value);apply362()
func toggle_soft359() -> void:
 use_layers362=not use_layers362;apply362()
func _process(delta: float) -> void:
 if not is_instance_valid(layered362):return
 t362+=delta
 # Regional painted tint responds to existing ambient and bedside lamp; not per-face PBR.
 var level:=clampf(inverse_lerp(.42,.70,world.environment.ambient_light_energy),0.,1.)
 var tint:=Color(.56,.55,.61).lerp(Color(.94,.92,.88),level)
 for lamp in lamps362:
  if lamp.visible and lamp.light_energy>0.:tint+=Color(.055,.025,.005,0.)
 for sprite in [base362,front362,sleeper362]:sprite.modulate=tint
 # Subtle breathing only on the sleeping actor; bed frame and front board stay anchored.
 sleeper362.position.y=(1127.-565.)*PIXEL362+sin(t362*1.7)*.004
