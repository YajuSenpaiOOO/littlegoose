extends Node3D

const YARD := preload("res://scripts/world/yard_layout432.gd")
const BATH_SHED := preload("res://scripts/art/yard_bath432.gd")
const BATH_CUTSCENE := preload("res://scripts/art/bath_cutscene432.gd")
const BASIN_SITE := YARD.BATH_SITE
const BASIN_REACH := 1.45
const NAP_RECOVERY := .35

var world: Node3D
var bath_shed: BATH_SHED
var basin: Node3D
var basin_water:MeshInstance3D
var soaking_pearl: MeshInstance3D
var visible_bath_state := -1
var drop_rng := RandomNumberGenerator.new()
var seed_drops: Node3D
var bed_choice: ConfirmationDialog
var basin_choice:PanelContainer
var basin_note:Label
var wash_choice:Button
var water_bead_choice:Button
var bath_scene:BATH_CUTSCENE
var bathing:=false
var resting := false

func _ready() -> void:
 drop_rng.randomize()
 bath_shed=BATH_SHED.new()
 bath_shed.name="YardBathShelter"
 bath_shed.position=Vector3(BASIN_SITE.x,world.open_ground432(BASIN_SITE)+.015,BASIN_SITE.y)
 bath_shed.rotation.y=YARD.BATH_FACING
 add_child(bath_shed)
 bath_shed.build(world.home432)
 build_basin()
 seed_drops=preload("res://scripts/combat/droplets432.gd").new()
 seed_drops.world=world
 seed_drops.bath_seed=true
 add_child(seed_drops)
 bed_choice=ConfirmationDialog.new()
 bed_choice.title="在床上歇一会儿"
 bed_choice.get_ok_button().text="睡到早上七点"
 bed_choice.get_cancel_button().text="先不睡"
 bed_choice.add_button("小睡一小时",true,&"nap")
 bed_choice.confirmed.connect(rest.bind(false))
 bed_choice.custom_action.connect(func(_action: StringName): rest(true))
 bed_choice.canceled.connect(release_controls)
 add_child(bed_choice)
 build_basin_choice()
 bath_scene=BATH_CUTSCENE.new()
 bath_scene.life=self
 bath_scene.world=world
 bath_scene.bath=bath_shed
 bath_shed.add_child(bath_scene)
 bath_scene.completed.connect(end_bath)
 var kit=world.memory_kit116
 var time: Node=world.time55
 var clock=time.clock55
 time.resume_natural()
 clock.set_total(time.palette.start_hour)
 if is_finite(kit.last_saved_time) and kit.last_saved_time>=0.:
  clock.set_total(kit.last_saved_time)
 time.snap_to_clock()
 if is_finite(kit.last_saved_health) and kit.last_saved_health>=0.:
  world.player_hp=clampf(kit.last_saved_health,1.,world.max_player_health())
 update_basin()

func build_basin_choice() -> void:
 var choices:=CanvasLayer.new()
 choices.layer=35
 add_child(choices)
 basin_choice=PanelContainer.new()
 basin_choice.add_theme_stylebox_override("panel",choice_style(Color("fff0d9"),Color("a58166")))
 choices.add_child(basin_choice)
 basin_choice.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
 basin_choice.offset_left=-194.
 basin_choice.offset_right=194.
 basin_choice.offset_top=-170.
 basin_choice.offset_bottom=-55.
 var layout:=VBoxContainer.new()
 layout.add_theme_constant_override("separation",7)
 basin_choice.add_child(layout)
 basin_note=Label.new()
 basin_note.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
 basin_note.add_theme_color_override("font_color",Color("634638"))
 basin_note.add_theme_font_size_override("font_size",19)
 layout.add_child(basin_note)
 var row:=HBoxContainer.new()
 row.alignment=BoxContainer.ALIGNMENT_CENTER
 row.add_theme_constant_override("separation",8)
 layout.add_child(row)
 wash_choice=make_basin_button(row,"洗澡",start_bath)
 water_bead_choice=make_basin_button(row,"泡水宝宝",choose_water_bead)
 make_basin_button(row,"先离开",cancel_basin)
 basin_choice.hide()

func choice_style(fill:Color,border:Color) -> StyleBoxFlat:
 var style:=StyleBoxFlat.new()
 style.bg_color=fill
 style.border_color=border
 style.set_border_width_all(2)
 style.set_corner_radius_all(10)
 style.content_margin_left=14.
 style.content_margin_right=14.
 style.content_margin_top=9.
 style.content_margin_bottom=9.
 return style

func make_basin_button(row:HBoxContainer,title:String,action:Callable) -> Button:
 var button:=Button.new()
 button.text=title
 button.add_theme_font_size_override("font_size",17)
 button.add_theme_stylebox_override("normal",choice_style(Color("f8e3c7"),Color("b89879")))
 button.add_theme_stylebox_override("hover",choice_style(Color("ffe9bd"),Color("ad7948")))
 button.add_theme_stylebox_override("pressed",choice_style(Color("efd2ac"),Color("ad7948")))
 var highlight:=choice_style(Color.TRANSPARENT,Color("a96d3d"))
 highlight.draw_center=false
 button.add_theme_stylebox_override("focus",highlight)
 for state in ["font_color","font_hover_color","font_pressed_color","font_focus_color"]:
  button.add_theme_color_override(state,Color("51372d"))
 row.add_child(button)
 button.pressed.connect(action)
 return button

func _process(_delta: float) -> void:
 update_basin()

func open_bed() -> void:
 var clock=world.time55.clock55
 var dawn_day:=floori(clock.next_dawn()/24.)+1
 var when:="今天早上" if dawn_day==clock.day else "明天早上"
 bed_choice.dialog_text="第 %d 天 · %s\n\n小睡一小时，恢复一部分决心。\n长睡到%s 07:00，回满决心。"%[clock.day,clock.caption(),when]
 world.combat_paused=true
 world.hero.controls_enabled=false
 world.hero.velocity=Vector3.ZERO
 world.hero.locomotion=Vector2.ZERO
 bed_choice.popup_centered(Vector2i(474,211))

func rest(nap: bool) -> void:
 if resting:return
 resting=true
 bed_choice.hide()
 var time_controller: Node=world.time55
 time_controller.sleeping=true
 world.home432.set_sleep(true)
 await get_tree().create_timer(.70,true,false,true).timeout
 var fade:=create_tween().set_ignore_time_scale()
 fade.tween_property(time_controller.curtain,"color:a",1.,.25)
 await fade.finished
 var clock=time_controller.clock55
 if nap:
  clock.set_total(clock.total_hours()+1.)
  world.player_hp=minf(world.max_player_health(),world.player_hp+world.max_player_health()*NAP_RECOVERY)
 else:
  clock.sleep_to_morning()
  world.player_hp=world.max_player_health()
 time_controller.resume_natural()
 time_controller.snap_to_clock()
 world.home432.set_sleep(false)
 update_basin()
 await get_tree().create_timer(.25,true,false,true).timeout
 var reveal:=create_tween().set_ignore_time_scale()
 reveal.tween_property(time_controller.curtain,"color:a",0.,.40)
 await reveal.finished
 time_controller.sleeping=false
 resting=false
 release_controls()
 world.materials432.notify("第 %d 天 · %s · %s"%[clock.day,clock.caption(),"歇了一会儿" if nap else "决心已恢复"])

func release_controls() -> void:
 world.combat_paused=false
 world.hero.controls_enabled=true

func save_at_desk() -> void:
 var kit=world.memory_kit116
 var clock=world.time55.clock55
 kit.last_saved_time=clock.total_hours()
 kit.last_saved_health=world.player_hp
 if kit.save_checkpoint(world.memory_save116)==OK:
  world.materials432.notify("记下今天了 · 第 %d 天 %s"%[clock.day,clock.caption()])
 else:
  world.materials432.notify("这次没能存好 · 可以再试一次")

func maybe_drop_seed(at: Vector3, velocity: Vector3) -> void:
 if drop_rng.randf()<.10:seed_drops.spawn120(at,velocity)

func basin_in_reach() -> bool:
 var at:=bath_shed.to_local(world.hero.global_position)
 return at.z>-.78 and at.x<1.40 and world.hero.global_position.distance_squared_to(basin.global_position)<BASIN_REACH*BASIN_REACH

func bath_mature() -> bool:
 var ready_at: float=world.memory_kit116.bath_ready_at
 return ready_at>=0. and world.time55.clock55.total_hours()>=ready_at

func open_basin() -> bool:
 if not basin_in_reach():return false
 world.speech112.dismiss()
 world.combat_paused=true
 world.hero.controls_enabled=false
 world.hero.velocity=Vector3.ZERO
 world.hero.locomotion=Vector2.ZERO
 var kit=world.memory_kit116
 basin_note.text="水宝宝已经泡大了。" if bath_mature() else ("水宝宝还在泡着。" if kit.bath_ready_at>=0. else "今天想做什么？")
 water_bead_choice.text="取水宝宝" if bath_mature() else ("看水宝宝" if kit.bath_ready_at>=0. else "泡水宝宝")
 basin_choice.show()
 wash_choice.grab_focus()
 return true

func start_bath() -> void:
 if bathing:return
 basin_choice.hide()
 bathing=true
 bath_scene.play()

func end_bath(skipped:bool) -> void:
 bath_shed.set_curtain(false,0. if skipped else .75)
 if not skipped:await bath_shed.curtain_motion.finished
 bathing=false
 release_controls()

func cancel_basin() -> void:
 basin_choice.hide()
 release_controls()

func choose_water_bead() -> void:
 cancel_basin()
 var kit=world.memory_kit116
 if bath_mature():
  kit.bath_ready_at=-1.
  kit.water_baby=mini(kit.water_baby+1,999999)
  world.materials432.pickup_fx.burst(soaking_pearl.global_position,Color("ffd1bc"))
  world.materials432.notify("收到养大的水宝宝 ×1")
 elif kit.bath_ready_at>=0.:
  say_bath_wait()
 elif kit.water_seed>0:
  kit.remember_materials()
  kit.water_seed-=1
  kit.bath_ready_at=world.time55.clock55.next_dawn()
  say_bath_wait()
 else:
  world.say264("小团团藏着的水宝宝，可以带回来放在这里泡。")
 update_basin()

func say_bath_wait() -> void:
 var clock=world.time55.clock55
 var same_day:=floori(world.memory_kit116.bath_ready_at/24.)+1==int(clock.day)
 world.say264("再泡一会儿，今天早上七点就能来看啦。" if same_day else "我们先去睡觉吧，明天早上再来看看。")

func update_basin() -> void:
 var state:=0
 if world.memory_kit116.bath_ready_at>=0.:state=2 if bath_mature() else 1
 if visible_bath_state==state:return
 visible_bath_state=state
 soaking_pearl.visible=state!=0
 soaking_pearl.scale=Vector3.ONE*(1. if state==2 else .43)
 soaking_pearl.position.y=.252+(.045 if state==2 else 0.)

func build_basin() -> void:
 basin=Node3D.new()
 basin.name="RedBathBasin"
 basin.position=Vector3(.07,.019,-.23)
 bath_shed.add_child(basin)
 var plastic:=CylinderMesh.new()
 plastic.top_radius=.665
 plastic.bottom_radius=.52
 plastic.height=.285
 plastic.radial_segments=40
 plastic.cap_top=false
 plastic.cap_bottom=false
 var basin_wall:=piece(plastic,Vector3.UP*.1425,Color("a84c37"))
 basin_wall.material_override=bath_shed.basin_finish
 # The interior floor receives shed shadows, but never casts a shadow onto itself.
 var floor_art:=piece(basin_disc(.524),Vector3.UP*.003,Color.WHITE)
 floor_art.name="BasinInteriorFloor"
 floor_art.material_override=bath_shed.basin_finish
 floor_art.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var rim:=TorusMesh.new()
 rim.inner_radius=.627
 rim.outer_radius=.682
 rim.rings=40
 rim.ring_segments=10
 var rim_art:=piece(rim,Vector3.UP*.285,Color.WHITE)
 var rim_finish:=bath_shed.basin_finish.duplicate() as StandardMaterial3D
 rim_finish.albedo_color=Color(1.,.88,.82)
 rim_finish.roughness=.38
 rim_art.material_override=rim_finish
 var water_material:=ShaderMaterial.new()
 water_material.shader=preload("res://scripts/art/bath_water432.gdshader")
 # Keep the translucent water local to the bowl and draw it after the scene grade.
 water_material.render_priority=4
 basin_water=piece(basin_disc(.636),Vector3.UP*.231,Color.WHITE)
 basin_water.name="ClearBasinWater"
 basin_water.material_override=water_material
 basin_water.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 var pearl:=SphereMesh.new()
 pearl.radius=.112
 pearl.height=.224
 pearl.radial_segments=16
 pearl.rings=8
 soaking_pearl=piece(pearl,Vector3(.14,.252,-.04),Color("ec9d99"))
 soaking_pearl.material_override.roughness=.18
 soaking_pearl.hide()
 var body:=StaticBody3D.new()
 body.collision_layer=2
 var collider:=CollisionShape3D.new()
 var shape:=CylinderShape3D.new()
 shape.radius=.63
 shape.height=.30
 collider.shape=shape
 collider.position.y=.15
 body.add_child(collider)
 basin.add_child(body)

func basin_disc(radius:float) -> ArrayMesh:
 var surface:=SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 40:
  for point in [Vector2.ZERO,Vector2.from_angle(float(i)/40.*TAU),Vector2.from_angle(float(i+1)/40.*TAU)]:
   surface.set_normal(Vector3.UP)
   surface.set_uv((point+Vector2.ONE)*.5)
   surface.add_vertex(Vector3(point.x,0.,point.y)*radius)
 return surface.commit()

func piece(mesh: Mesh, at: Vector3, color: Color) -> MeshInstance3D:
 var material:=StandardMaterial3D.new()
 material.albedo_color=color
 material.roughness=.86
 var art:=MeshInstance3D.new()
 art.position=at
 art.mesh=mesh
 art.material_override=material
 basin.add_child(art)
 return art
