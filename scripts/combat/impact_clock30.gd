extends RefCounted
## Legacy main.gd semantics: latest writer wins; real-time deadline only extends.
## Deferred cues are cancellable on restart/pause, unlike unowned async callbacks.
var events: Array[Dictionary]=[]
var until := 0.
var current := 1.
func add(scale: float,duration: float,delay := 0.,group := "") -> void:
	var now := Time.get_ticks_msec()/1000.
	events.append({"scale":clampf(scale,.01,1.),"start":now+delay,"end":now+delay+duration,"group":group})
	events.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return a.start<b.start)
func cancel_pending(group: String) -> void:
	events=events.filter(func(event: Dictionary) -> bool: return event.get("group","")!=group)
func tick(at_time := -1.) -> float:
	var now := at_time if at_time>=0. else Time.get_ticks_msec()/1000.
	while not events.is_empty() and now>=events[0].start:
		var event: Dictionary=events.pop_front()
		current=event.scale
		until=maxf(until,event.end)
	if now>=until: current=1.; until=0.
	Engine.time_scale=current
	return current
func clear() -> void:
	events.clear()
	until=0.; current=1.
	Engine.time_scale=1.
