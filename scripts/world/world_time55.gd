extends Node
## One time source drives the entire woodland; no per-tree day/night setup.
var world: Node3D
@export var palette: Resource=preload("res://assets/lighting55/woodland_day.tres")
var clock55: RefCounted
var visual_hour := 7.5
var preview := false
var sleeping := false
var focused := true
var dialogue_open := false
var guide: Label
var curtain: ColorRect
var apply_left := 0.
var dust_day_material: ShaderMaterial
var beam_feet: Array[Vector3] = []
var openings: Array[Vector2] = []

func _ready() -> void:
	name="ContinuousWoodlandTime55"
	clock55=preload("res://scripts/world/day_clock55.gd").new(palette)
	visual_hour=clock55.hour
	focused=DisplayServer.window_is_focused()
	world.atmosphere41.focus_material.shader=preload("res://scripts/art/scenic_day55.gdshader")
	world.atmosphere41._set_focus_level(world.atmosphere41.focus_level)
	world.porch49.house_material.shader=preload("res://scripts/art/cottage_day55.gdshader")
	var lantern: Sprite3D=world.woodland_life.lantern_root.get_child(0)
	lantern.material_override.shader=preload("res://scripts/art/lantern_day55.gdshader")
	dust_day_material=world.sun_dust52.batch.material_override
	dust_day_material.shader=preload("res://scripts/art/sun_dust_day55.gdshader")
	# Reuse the five existing ribbons at the nearest baked canopy openings.
	var beams: Node3D=world.atmosphere41.shafts
	for beam in beams.get_children():
		var arrays: Array=beam.mesh.surface_get_arrays(0)
		var low := Vector3(INF,INF,INF)
		var high := Vector3(-INF,-INF,-INF)
		for i in arrays[Mesh.ARRAY_VERTEX].size():
			if arrays[Mesh.ARRAY_TEX_UV][i].y<.999: continue
			low=low.min(arrays[Mesh.ARRAY_VERTEX][i])
			high=high.max(arrays[Mesh.ARRAY_VERTEX][i])
		beam_feet.append((low+high)*.5)
	openings.append(Vector2(-3.8,-3.3))
	for entry in world.porch49.woodland_data.openings:
		var at := Vector2(entry.at[0],entry.at[1])
		if at.distance_to(openings[0])>4.: openings.append(at)
	guide=Label.new()
	guide.position=Vector2(1030,24)
	guide.add_theme_font_size_override("font_size",19)
	guide.add_theme_color_override("font_outline_color",Color(.02,.04,.06,.95))
	guide.add_theme_constant_override("outline_size",5)
	world.label.get_parent().add_child(guide)
	var overlay := CanvasLayer.new()
	overlay.layer=100
	add_child(overlay)
	curtain=ColorRect.new()
	curtain.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	curtain.mouse_filter=Control.MOUSE_FILTER_IGNORE
	curtain.color=Color(0,0,0,0)
	overlay.add_child(curtain)
	apply_look()
	update_guide()

func blocked() -> bool:
	return sleeping or not focused or dialogue_open or world.combat_paused or world.draft_open or world.result_open or world.player_hp<=0.

func _process(delta: float) -> void:
	clock55.advance(delta,blocked() or preview)
	# Visual sampling follows simulation time. Debug jumps also ease through the
	# intermediate hours, rather than crossfading two unrelated screen images.
	visual_hour=move_toward(visual_hour,clock55.hour,delta*9.)
	apply_left-=delta
	if apply_left<=0.:
		apply_left=.08
		apply_look()
		update_guide()

func apply_look() -> void:
	var look: Dictionary=palette.sample(visual_hour)
	var atmosphere: Node3D=world.atmosphere41
	var env: Environment=atmosphere.environment
	env.ambient_light_color=look.ambient
	env.ambient_light_energy=look.air
	env.fog_light_color=look.fog
	env.fog_light_energy=.65
	# Keep the accepted long-distance air; evening is not a near grey fog wall.
	env.fog_depth_begin=24.
	env.fog_depth_end=95.
	world.sun.light_color=look.sun
	world.sun.light_energy=look.energy
	var focus: ShaderMaterial=atmosphere.focus_material
	focus.set_shader_parameter("tone_strength",1.)
	focus.set_shader_parameter("tone_contrast",1.025)
	focus.set_shader_parameter("tone_saturation",look.saturation)
	focus.set_shader_parameter("tone_shadows",look.shadow)
	focus.set_shader_parameter("tone_highlights",look.highlight)
	focus.set_shader_parameter("day_exposure55",look.exposure)
	focus.set_shader_parameter("glow_strength",lerpf(.28,.85,look.lamps) if atmosphere.stage_level==2 else 0.)
	world.porch49.apply_daylight(look.daylight)
	world.porch49.house_material.set_shader_parameter("window_emission55",look.lamps*.85)
	var life: Node3D=world.woodland_life
	life.lantern_light.light_energy=lerpf(.22,1.05,look.lamps)
	life.lantern_root.get_child(0).material_override.set_shader_parameter("glass_energy55",lerpf(.15,1.,look.lamps))
	dust_day_material.set_shader_parameter("day_visibility55",look.dust)
	# The art-directed sun direction stays aligned with the existing baked tree
	# projections. Full moving-sun shadows need a separate projection upgrade.
	atmosphere.shafts.visible=atmosphere.enabled and look.rays>.002
	var at := Vector2(world.hero.position.x,world.hero.position.z)
	var nearby := openings.duplicate()
	nearby.sort_custom(func(a: Vector2,b: Vector2)->bool: return a.distance_squared_to(at)<b.distance_squared_to(at))
	for i in atmosphere.shafts.get_child_count():
		var beam: MeshInstance3D=atmosphere.shafts.get_child(i)
		var center: Vector2=nearby[i]
		beam.position=Vector3(center.x,world.floor_height(center)+.04,center.y)-beam_feet[i]
		var distance_fade := 1.-smoothstep(12.,22.,center.distance_to(at))
		beam.visible=distance_fade>.01
		beam.material_override.set_shader_parameter("strength",look.rays*distance_fade)

func preview_at(hour: float) -> void:
	if sleeping: return
	preview=true
	clock55.hour=clampf(hour,6.,palette.stop_hour)

func resume_natural() -> void:
	preview=false
	clock55.paused=false
	clock55.speed=1.

func can_sleep() -> bool:
	if sleeping or world.combat_paused or world.draft_open or world.result_open or dialogue_open or world.player_hp<=0. or world.wave_state=="fighting": return false
	return Vector2(world.hero.position.x,world.hero.position.z).distance_to(Vector2(-4.7,-2.8))<3.6

func sleep_to_morning() -> bool:
	if not can_sleep(): return false
	sleeping=true
	var controls: bool=world.hero.controls_enabled
	world.hero.controls_enabled=false
	world.hero.locomotion=Vector2.ZERO
	world.hero.combat_impulse=Vector2.ZERO
	world.hero.velocity=Vector3.ZERO
	world.combat_paused=true
	var fade := create_tween()
	fade.tween_property(curtain,"color:a",1.,.5)
	await fade.finished
	clock55.sleep_to_morning()
	resume_natural()
	visual_hour=clock55.hour
	world.player_hp=100.
	apply_look()
	var reveal := create_tween()
	reveal.tween_property(curtain,"color:a",0.,.7)
	await reveal.finished
	world.combat_paused=false
	world.hero.controls_enabled=controls
	sleeping=false
	update_guide()
	return true

func handle_input(event: InputEvent) -> bool:
	if not event is InputEventKey or not event.pressed or event.echo: return false
	if sleeping: return true
	if event.alt_pressed:
		match event.physical_keycode:
			KEY_1: preview_at(8.)
			KEY_2: preview_at(12.)
			KEY_3: preview_at(18.)
			KEY_4: preview_at(22.)
			KEY_0: resume_natural()
			KEY_T:
				preview=false
				clock55.paused=false
				clock55.speed=120. if clock55.speed==1. else 1.
			KEY_P:
				preview=false
				clock55.paused=not clock55.paused
			_: return false
		update_guide()
		return true
	if event.physical_keycode in [KEY_ENTER,KEY_KP_ENTER] and can_sleep():
		sleep_to_morning()
		return true
	return false

func update_guide() -> void:
	var mode := "自然流动" if clock55.speed==1. else "120倍预览"
	if preview: mode="时段预览 · 已停表"
	elif clock55.paused: mode="已暂停"
	elif clock55.at_deep_night(): mode="夜深了 · 回小屋休息可进入次日"
	elif blocked(): mode="暂歇 · 时间暂停"
	guide.text="第%d天 · %s · %s\n%s\nAlt+1 晨光 / 2 正午 / 3 落日 / 4 夜晚\nAlt+T 加速 · Alt+P 暂停 · Alt+0 恢复自然\nCtrl+F4 林路 · F3 小屋"%[clock55.day,clock55.caption(),clock55.period(),mode]
	if can_sleep(): guide.text+="\nEnter 在小屋休息，次日06:30醒来"
	if sleeping: guide.text="晚安……"

func _notification(what: int) -> void:
	if what==NOTIFICATION_WM_WINDOW_FOCUS_OUT: focused=false
	elif what==NOTIFICATION_WM_WINDOW_FOCUS_IN: focused=true
