extends RefCounted
## Simulation time is independent of rendering, battle waves and wall-clock time.
var palette: Resource
var hour := 7.5
var day := 1
var speed := 1.
var paused := false

func _init(settings: Resource) -> void:
	palette=settings
	hour=palette.start_hour

func advance(seconds: float,blocked := false) -> void:
	if blocked or paused or seconds<=0.: return
	hour=minf(palette.stop_hour,hour+seconds*speed*(palette.stop_hour-6.)/(palette.day_minutes*60.))

func at_deep_night() -> bool: return hour>=palette.stop_hour

func sleep_to_morning() -> void:
	day+=1
	hour=palette.wake_hour

func caption() -> String:
	var minute := int(hour*60.)
	return "%02d:%02d"%[minute/60,minute%60]

func period() -> String:
	if hour<9.: return "晨光"
	if hour<15.: return "白昼"
	if hour<17.2: return "午后"
	if hour<19.: return "落日"
	if hour<21.: return "暮蓝"
	return "深夜"
