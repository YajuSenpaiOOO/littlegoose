extends Node3D
# Minimal read-only host for the unchanged 192 actor; no woodland loading or saves.
const Audio=preload("res://scripts/combat/combat_sfx22.gd")
var hero: CharacterBody3D
var camera: Camera3D
var sun: DirectionalLight3D
var fill355: DirectionalLight3D
var room: Node3D
var environment: Environment
var combat_paused:=false
var active114:=false
var player_hp:=12.
var invulnerability:=0.
var charge_active:=false
var park99: Node3D
var paper_memories146: Node3D
var buffs=preload("res://scripts/combat/buff_book39.gd").new()
var enemies: Array=[]
var silk171: Array=[]
var combat_budget105:=true
var contact_enabled:=true
var goose: Sprite3D
var goose_root: Node3D
var ready355:=false
var night355:=false
var time355:=0.
var pour355:=0.
var message355:=""
var message_left355:=0.
var prompt: Label
var title_panel: Control
var nearest355: Dictionary={}
func combat_effect_root159() -> Node3D:return self
func floor_height(_at: Vector2) -> float:return 0.
func on_web172(_at: Vector3) -> bool:return false
func perfect_dodge() -> void:pass
func room_script355() -> Script:return preload("res://scripts/room/room_shell355.gd")
func home_goose355() -> bool:return true
func _ready() -> void:
 DisplayServer.window_set_title("小白鹅 · 355 · 暖木小屋布局")
 var env:=WorldEnvironment.new();environment=Environment.new();env.environment=environment;add_child(env)
 environment.background_mode=Environment.BG_COLOR;environment.background_color=Color("292522")
 environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;environment.ambient_light_color=Color("eadbba");environment.ambient_light_energy=.70
 environment.tonemap_mode=Environment.TONE_MAPPER_LINEAR
 sun=DirectionalLight3D.new();sun.rotation_degrees=Vector3(-48.,-155.,0.);sun.light_color=Color("ffe1aa");sun.light_energy=.72
 sun.shadow_enabled=true;sun.directional_shadow_max_distance=35.;add_child(sun)
 fill355=DirectionalLight3D.new();fill355.rotation_degrees=Vector3(-35.,-20.,0.);fill355.light_color=Color("dce4ef");fill355.light_energy=.28;add_child(fill355)
 camera=Camera3D.new();camera.fov=42.;camera.near=.1;camera.far=80.;camera.rotation_degrees=Vector3(-25.,0.,0.)
 camera.position=Vector3(0.,1.05,-.35)+Vector3(0.,sin(deg_to_rad(25.)),cos(deg_to_rad(25.)))*17.8;camera.current=true;add_child(camera)
 room=room_script355().new();room.world=self;add_child(room)
 hero=preload("res://scripts/combat/hero192.gd").new();hero.position=Vector3(0.,.06,2.8);add_child(hero)
 hero.combat_enabled=true;hero.legacy_motion_enabled=true;hero.motion_pixels_per_m=78.3/4.1
 var shadow=preload("res://scripts/combat/actor_shadow105.gd").new();shadow.battle=self;shadow.visual=hero.visual;shadow.opacity_scale=.7;hero.add_child(shadow)
 goose_root=Node3D.new();goose_root.visible=home_goose355();goose_root.position=Vector3(-4.7,.53,1.);add_child(goose_root)
 goose=Sprite3D.new();goose.texture=load("res://assets/black_goose_v2/hover_gentle_v1.png")
 goose.pixel_size=.68/float(goose.texture.get_height());goose.offset=Vector2(0.,goose.texture.get_height()*.5)
 goose.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS;goose.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;goose.shaded=true
 var ink=preload("res://scripts/combat/hero192.gd").make_receiver192();ink.albedo_texture=goose.texture;goose.material_override=ink
 goose_root.add_child(goose)
 var plane:=PlaneMesh.new();plane.size=Vector2(.8,.50)
 var contact:=MeshInstance3D.new();contact.mesh=plane;contact.position=Vector3(-4.7,.55,1.)
 var mat:=ShaderMaterial.new();mat.shader=preload("res://scripts/art/foot_contact16.gdshader");contact.material_override=mat;contact.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;contact.visible=home_goose355();add_child(contact)
 Audio.attach(get_tree());build_hud355()
 await get_tree().physics_frame;await get_tree().physics_frame;ready355=true
func build_hud355() -> void:
 var canvas:=CanvasLayer.new();add_child(canvas)
 var panel:=PanelContainer.new();panel.position=Vector2(18,18);panel.mouse_filter=Control.MOUSE_FILTER_IGNORE;canvas.add_child(panel);title_panel=panel
 var style:=StyleBoxFlat.new();style.bg_color=Color(.12,.10,.09,.82);style.corner_radius_top_left=9;style.corner_radius_bottom_right=9
 style.content_margin_left=15;style.content_margin_right=15;style.content_margin_top=10;style.content_margin_bottom=10;panel.add_theme_stylebox_override("panel",style)
 var label:=Label.new();label.text="355 · 暖木小屋\nWASD走动 · Shift闪避 · E查看 / 沙漏\nF2昼夜 · F4占地 · F7回门口 · F3小院 · F1收起提示"
 label.add_theme_font_size_override("font_size",17);label.modulate=Color("f1dfba");panel.add_child(label)
 prompt=Label.new();prompt.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
 prompt.offset_top=-76.;prompt.offset_bottom=-24.;prompt.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER;prompt.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
 prompt.add_theme_font_size_override("font_size",21);prompt.add_theme_color_override("font_color",Color("fff0cd"));prompt.add_theme_color_override("font_outline_color",Color(.12,.1,.08,.96));prompt.add_theme_constant_override("outline_size",7);canvas.add_child(prompt)
func reset355() -> void:
 hero.global_position=Vector3(0.,.06,2.8);hero.velocity=Vector3.ZERO;hero.locomotion=Vector2.ZERO;hero.combat_impulse=Vector2.ZERO;hero.reset_actions();hero.reset_physics_interpolation()
func choose355() -> Dictionary:
 var best:=1.25
 var result: Dictionary={}
 var at:=Vector2(hero.position.x,hero.position.z)
 for row in room.footprints:
  if row.id in ["desk_chair","tea_chair","goose_stool","bedside"]:continue
  var distance: float=at.distance_to(row.approach)
  if distance<best:best=distance;result=row
 if at.distance_to(Vector2(0.,4.85))<1.5:result={"id":"exit","title":"离开小屋"}
 return result
func interact355() -> void:
 nearest355=choose355()
 if nearest355.is_empty():return
 match nearest355.id:
  "exit":get_tree().change_scene_to_file("res://scenes/world/world169.tscn")
  "hourglass":pour355=1.5;message355="金色的时光沙，轻轻流下。";message_left355=2.8
  "wardrobe":message355="衣柜里，留着两份整整齐齐的换洗用品。";message_left355=3.
  "nest":message355="小黑鹅也有自己的软枕和小毯子。";message_left355=3.
  "bed":message355="柔软的被子，等着冒险结束后回家。";message_left355=3.
  "tea":message355="一大一小，两只杯子。";message_left355=3.
  _:message355=nearest355.title;message_left355=2.
func set_night355(value: bool) -> void:
 night355=value;sun.light_energy=.08 if value else .72;environment.ambient_light_energy=.42 if value else .70;fill355.light_energy=.18 if value else .28
func _process(delta: float) -> void:
 if not is_instance_valid(hero):return
 time355+=delta;goose.position.y=.04+sin(time355*2.3)*.035
 message_left355=maxf(0.,message_left355-delta)
 nearest355=choose355()
 prompt.text=message355 if message_left355>0. else ("E · "+str(nearest355.title) if not nearest355.is_empty() else "")
 pour355=maxf(0.,pour355-delta)
 var t:=clampf(pour355/1.5,0.,1.)
 room.stream.scale=Vector3(1.+sin(time355*23.)*.25,1.,1.+sin(time355*23.)*.25)*(1.8 if t>0. else 1.)
 room.lower_sand.scale.y=1.+sin((1.-t)*PI)*.25 if t>0. else 1.
func _input(event: InputEvent) -> void:
 if not event is InputEventKey or not event.pressed or event.echo or not ready355:return
 match event.physical_keycode:
  KEY_E:interact355()
  KEY_F1:title_panel.visible=not title_panel.visible
  KEY_F2:set_night355(not night355)
  KEY_F4:room.overlay.visible=not room.overlay.visible
  KEY_F7:reset355()
  KEY_F3:get_tree().change_scene_to_file("res://scenes/world/world169.tscn")
