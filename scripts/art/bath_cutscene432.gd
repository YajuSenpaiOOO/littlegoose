extends Node3D

signal completed(skipped:bool)

const PEEK_PORTRAIT := preload("res://assets/bath432/curtain-peek.png")
const GOOSE_ENTRY := Vector3(-1.01,.06,1.63)
const GOOSE_CORNER := Vector3(-1.01,.05,-.73)
const PORTRAIT_LAYER := 1<<17

var life:Node3D
var world:Node3D
var bath:Node3D
var portrait:Sprite3D
var speech:PanelContainer
var time_fade:ColorRect
var timeline:Tween
var hero_step:Tween
var active:=false
var yard_hint_visible:=false
var goose_start:=Vector3.ZERO
var goose_walking_distance:=0.

func _ready() -> void:
 portrait=Sprite3D.new()
 portrait.name="CurtainPeekPortrait"
 portrait.texture=PEEK_PORTRAIT
 portrait.pixel_size=.78/portrait.texture.get_height()
 portrait.position=Vector3(.55,1.54,.96)
 # Preserve the painted highlights; the cutout still receives local scene grading.
 portrait.shaded=false
 portrait.layers=PORTRAIT_LAYER
 portrait.alpha_cut=SpriteBase3D.ALPHA_CUT_DISCARD
 portrait.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 add_child(portrait)
 portrait.hide()

 var dialogue:=CanvasLayer.new()
 dialogue.layer=35
 add_child(dialogue)
 speech=PanelContainer.new()
 speech.mouse_filter=Control.MOUSE_FILTER_IGNORE
 speech.add_theme_stylebox_override("panel",life.choice_style(Color("fff0dd"),Color("ad876b")))
 dialogue.add_child(speech)
 speech.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
 speech.offset_left=-155.
 speech.offset_right=155.
 speech.offset_top=-124.
 speech.offset_bottom=-73.
 var line:=Label.new()
 line.text="小玩家，能帮我们把把风吗？"
 line.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 line.add_theme_font_size_override("font_size",21)
 line.add_theme_color_override("font_color",Color("614339"))
 speech.add_child(line)
 speech.hide()
 time_fade=ColorRect.new()
 time_fade.mouse_filter=Control.MOUSE_FILTER_IGNORE
 time_fade.color=Color(0.,0.,0.,0.)
 dialogue.add_child(time_fade)
 time_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func play() -> void:
 active=true
 yard_hint_visible=world.hint288.visible
 world.hint288.hide()
 var flyer:Node3D=world.goose
 goose_start=bath.to_local(flyer.global_position)
 goose_walking_distance=0.
 world.cancel_goose_recall432()
 flyer.hide()
 var companion:CharacterBody3D=world.home432.companion
 companion.set_physics_process(false)
 companion.show()
 companion.global_position=flyer.global_position
 companion.reset_physics_interpolation()
 timeline=create_tween().set_ignore_time_scale()
 queue_companion_walk()
 timeline.tween_callback(stage_hero_behind_curtain)
 timeline.tween_interval(.24)
 timeline.tween_callback(companion.face373.bind(world.hero.global_position))
 timeline.tween_callback(companion.apply_frame373.bind(0))
 timeline.tween_callback(bath.set_curtain.bind(true,.72))
 timeline.tween_interval(.76)
 timeline.tween_property(bath,"closeup_amount",1.,.68).set_trans(Tween.TRANS_SINE)
 timeline.tween_callback(show_peek)
 timeline.tween_property(bath,"peek_amount",1.,.46).set_trans(Tween.TRANS_SINE)
 timeline.parallel().tween_property(portrait,"position:x",.19,.46).set_trans(Tween.TRANS_SINE)
 timeline.tween_callback(speech.show)
 timeline.tween_property(portrait,"position:y",1.558,1.20).set_trans(Tween.TRANS_SINE)
 timeline.tween_property(portrait,"position:y",1.54,1.25).set_trans(Tween.TRANS_SINE)
 timeline.tween_callback(speech.hide)
 timeline.tween_property(bath,"peek_amount",0.,.40).set_trans(Tween.TRANS_SINE)
 timeline.parallel().tween_property(portrait,"position:x",.55,.40).set_trans(Tween.TRANS_SINE)
 timeline.tween_callback(hide_peek)
 timeline.tween_property(time_fade,"color:a",1.,.24).set_trans(Tween.TRANS_SINE)
 timeline.tween_property(bath,"closeup_amount",0.,.43).set_trans(Tween.TRANS_SINE)
 timeline.tween_property(time_fade,"color:a",0.,.30).set_trans(Tween.TRANS_SINE)
 timeline.tween_callback(finish.bind(false))

func queue_companion_walk() -> void:
 var waypoints:=PackedVector3Array()
 var at:=goose_start
 var comes_from_outside:=at.z< -1.15 or (at.z<.88 and absf(at.x)>1.34)
 if comes_from_outside:
  var around:=2.83 if at.x>0. else -1.91
  waypoints.append(Vector3(around,.06,at.z))
  waypoints.append(Vector3(around,.06,1.68))
 elif at.z<.88 and at.x>-.83:
  waypoints.append(Vector3(at.x,.06,-.96 if at.z<-.60 else .98))
  waypoints.append(Vector3(GOOSE_ENTRY.x,.06,waypoints[-1].z))
 elif at.z>=.88 and at.x>-.83:
  waypoints.append(Vector3(at.x,.06,maxf(at.z,1.63)))
 if (at.z>=.88 and absf(at.x-GOOSE_ENTRY.x)>.35) or comes_from_outside:
  waypoints.append(GOOSE_ENTRY)
 waypoints.append(GOOSE_CORNER)
 for next in waypoints:
  var distance:=Vector2(at.x-next.x,at.z-next.z).length()
  if distance>.025:
   timeline.tween_method(place_companion.bind(at,next,distance),0.,1.,maxf(.12,distance/3.05))
   timeline.tween_callback(add_goose_distance.bind(distance))
  at=next

func add_goose_distance(distance:float) -> void:
 goose_walking_distance+=distance

func place_companion(progress:float,from:Vector3,to:Vector3,distance:float) -> void:
 var companion:CharacterBody3D=world.home432.companion
 var at:=bath.to_global(from.lerp(to,progress))
 var local:=bath.to_local(at)
 if absf(local.x)>1.62 or absf(local.z)>1.30:
  at.y=maxf(at.y,world.open_ground432(Vector2(at.x,at.z))+.025)
 companion.global_position=at
 if companion.ready373:
  companion.face373(at+bath.global_basis*(to-from))
  companion.apply_frame373(1+int((goose_walking_distance+progress*distance)*4.5)%3)

func stage_hero_behind_curtain() -> void:
 var at:=bath.to_local(world.hero.global_position)
 if at.z<.81:return
 var feet:=bath.to_global(Vector3(at.x,at.y,.81))
 hero_step=create_tween()
 hero_step.tween_property(world.hero,"global_position",feet,.22).set_trans(Tween.TRANS_SINE)

func show_peek() -> void:
 portrait.position.x=.55
 portrait.position.y=1.54
 var daylight:=float(world.time55.palette.sample(world.time55.visual_hour).daylight)
 portrait.modulate=Color(.94,.80,.70).lerp(Color(.89,.87,.87),daylight)
 portrait.show()

func hide_peek() -> void:
 portrait.hide()

func skip() -> void:
 if not active:return
 timeline.kill()
 finish(true)

func finish(skipped:bool) -> void:
 if hero_step:hero_step.kill()
 time_fade.color.a=0.
 hide_peek()
 speech.hide()
 bath.peek_amount=0.
 bath.closeup_amount=0.
 var companion:CharacterBody3D=world.home432.companion
 var flyer:Node3D=world.goose
 flyer.global_position=companion.global_position+Vector3.UP*(0. if skipped else .28)
 flyer.reset_physics_interpolation()
 flyer.velocity385=Vector3.ZERO
 companion.hide()
 flyer.show()
 world.hint288.visible=yard_hint_visible
 active=false
 completed.emit(skipped)
