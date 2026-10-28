extends RefCounted
## Fixed-capacity distance-driven footprints. No scene, camera or art dependency.
const CAPACITY := 48
var lifetime := 4.5
var spacing := .62
var elapsed := 0.
var enabled := true
var revision := 0
var cursor := 0
var left_next := true
var carry := 0.
var previous := Vector2.ZERO
var initialized := false
var marks := PackedVector4Array()

func _init() -> void:
	marks.resize(CAPACITY)
	clear()

func clear() -> void:
	for i in CAPACITY: marks[i] = Vector4(1000,1000,-1000,0)
	cursor = 0
	revision += 1
	carry = 0.

func reset_position(at: Vector2) -> void:
	previous = at
	initialized = true
	carry = 0.

func advance(delta: float,at: Vector2,grounded: bool,on_surface: Callable) -> void:
	elapsed += delta
	if not initialized:
		reset_position(at)
		return
	var delta_at := at-previous
	var distance := delta_at.length()
	var start := previous
	previous = at
	if distance>2. or not grounded or not enabled:
		carry = 0.
		return
	if distance<.0001: return
	var direction := delta_at/distance
	var consumed := 0.
	while carry+distance-consumed>=spacing:
		consumed += spacing-carry
		carry = 0.
		var center := start+direction*consumed
		var side := -.12 if left_next else .12
		var foot := center+Vector2(-direction.y,direction.x)*side
		left_next = not left_next
		if on_surface.call(foot):
			marks[cursor] = Vector4(foot.x,foot.y,elapsed,atan2(direction.y,direction.x))
			cursor = (cursor+1)%CAPACITY
			revision += 1
	carry += distance-consumed

func active_count() -> int:
	var count := 0
	for mark in marks:
		if elapsed-mark.z>=0. and elapsed-mark.z<lifetime: count += 1
	return count
