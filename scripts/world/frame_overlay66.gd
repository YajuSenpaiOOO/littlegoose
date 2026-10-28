extends CanvasLayer
## Wall-clock samples include stalls even when engine delta is capped.
const CAPACITY := 4096
var world: Node3D
var panel: PanelContainer
var readout: Label
var samples := PackedVector2Array()
var cursor := 0
var count := 0
var previous_tick := 0
var refresh_left := 0.
var focused := true
var last_spike := "尚无 >33ms 慢帧"
var average_ms := 0.
var worst_ms := 0.
var slow_count := 0

func _ready() -> void:
	name="FrameMonitor66"
	layer=90
	samples.resize(CAPACITY)
	panel=PanelContainer.new()
	panel.position=Vector2(20,100)
	panel.mouse_filter=Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color=Color(.025,.045,.06,.80)
	style.corner_radius_top_left=6; style.corner_radius_top_right=6
	style.corner_radius_bottom_left=6; style.corner_radius_bottom_right=6
	style.content_margin_left=12; style.content_margin_right=12
	style.content_margin_top=7; style.content_margin_bottom=7
	panel.add_theme_stylebox_override("panel",style)
	add_child(panel)
	readout=Label.new()
	readout.mouse_filter=Control.MOUSE_FILTER_IGNORE
	readout.add_theme_font_size_override("font_size",17)
	panel.add_child(readout)
	readout.text="FPS 采样中……\nCtrl+F9 显隐 · Ctrl+F10 清零"

func context() -> String:
	var nearest := "home"
	var distance := INF
	var at := Vector2(world.hero.global_position.x,world.hero.global_position.z)
	for key in world.meadow.landmarks:
		var d: float=at.distance_squared_to(world.meadow.landmarks[key])
		if d<distance: nearest=key; distance=d
	return "%s (%.1f, %.1f) · %s"%[world.region_names.get(nearest,nearest),at.x,at.y,world.time55.clock55.caption()]

var band_state66 := -1

func add_sample(now: float,elapsed_ms: float) -> void:
	samples[cursor]=Vector2(now,elapsed_ms)
	cursor=(cursor+1)%CAPACITY
	count=mini(count+1,CAPACITY)
	if elapsed_ms>33.3: last_spike="%.1fms · %s"%[elapsed_ms,context()]

func refresh(now: float) -> void:
	var total := 0.
	var recent := 0
	worst_ms=0.; slow_count=0
	for i in count:
		var entry := samples[(cursor-1-i+CAPACITY)%CAPACITY]
		var age: float=now-entry.x
		if age>10.: break
		worst_ms=maxf(worst_ms,entry.y)
		if entry.y>33.3: slow_count+=1
		if age<=1.: total+=entry.y; recent+=1
	average_ms=total/maxi(recent,1)
	var fps: int=int(round(1000./maxf(average_ms,.1))) if recent>0 else 0
	readout.text="%d FPS  ·  %.1f ms/帧%s\n近10秒最慢 %.1fms · >33ms %d帧\n最近慢帧：%s\nCtrl+F9 显隐 · Ctrl+F10 清零"%[fps,average_ms," · 后台暂停采样" if not focused else "",worst_ms,slow_count,last_spike]
	# The tint only carries a coarse band; skip identical recolours.
	var band66 := 2 if average_ms>33.3 else (1 if average_ms>20. else 0)
	if band66!=band_state66:
		band_state66=band66
		readout.modulate=Color(1.,.78,.64) if average_ms>33.3 else (Color(1.,.91,.68) if average_ms>20. else Color(.86,.95,.90))

func clear_samples() -> void:
	cursor=0; count=0; previous_tick=0
	last_spike="尚无 >33ms 慢帧"
	refresh_left=0.

func _process(delta: float) -> void:
	var tick := Time.get_ticks_usec()
	if not focused: previous_tick=0; return
	if previous_tick!=0: add_sample(tick/1000000.,(tick-previous_tick)/1000.)
	previous_tick=tick
	refresh_left-=delta
	if refresh_left<=0.:
		refresh_left=.5
		refresh(tick/1000000.)

func _notification(what: int) -> void:
	if what==NOTIFICATION_WM_WINDOW_FOCUS_OUT:
		focused=false; previous_tick=0
		if is_instance_valid(readout): refresh(Time.get_ticks_usec()/1000000.)
	elif what==NOTIFICATION_WM_WINDOW_FOCUS_IN:
		focused=true; previous_tick=0
