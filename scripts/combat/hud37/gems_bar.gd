
extends Control
# 宝石条（血量/决心值通用）：菱形宝石 + 按比例抽干 + 碎裂飞溅动画。
# 绘制宝石与碎片，保留比例填充与程序驱动的碎裂运动。
# warning=true 时每颗宝石向外扩散自己的轮廓（脱战警示），整条亮度脉动。

const COL_WARN := Color(1, 0.45, 0.5)
const UI_ART = preload("res://scripts/combat/hud37/ui_art.gd")

var gem_count := 10
var bar_width := 360.0
var displayed := 100.0
var target := 100.0
var max_value := 100.0
var warning := false

var _fragments: Array = []
var _warn_t := 0.0
var _shake_t := 0.0            # 受击整条抖动（幅度可按伤害档位调节）
var _shake_amp := 0.0
var _off := Vector2.ZERO       # 抖动偏移（_draw 全程应用）
var _breaking: Dictionary = {}
var _initialized := false


func setup(count: int, width: float) -> void:
	gem_count = count
	bar_width = width
	custom_minimum_size = Vector2(width, 44)
	size = custom_minimum_size


# 受击抖动：strength = 伤害档位（普通 1.0，强敌按伤害放大，上限 3）
func hit_shake(strength := 1.0) -> void:
	_shake_t = 0.25
	_shake_amp = 7.0 * clampf(strength, 0.5, 3.0)


func set_value(cur: float, max_v: float) -> void:
	max_value = maxf(max_v, 0.01)
	target = clampf(cur, 0.0, max_value)
	if not _initialized:
		_initialized = true
		displayed = target
	else:
		displayed = clampf(displayed, 0.0, max_value)


func gem_value() -> float:
	return max_value / gem_count


func _gem_fill(i: int, hp: float) -> float:
	var per := gem_value()
	return clampf((hp - i * per) / per, 0.0, 1.0)


func _process(delta: float) -> void:
	for index in _breaking.keys():
		_breaking[index] -= delta
		if _breaking[index] <= 0.0:
			_breaking.erase(index)
	# 平滑抽干；跨过清空线 -> 碎裂
	if displayed > target:
		var before := displayed
		displayed = maxf(target, displayed - delta * 40.0)
		for i: int in gem_count:
			if _gem_fill(i, displayed) <= 0.0 and _gem_fill(i, before) > 0.0:
				_shatter(i)
	elif displayed < target:
		# 返决心：宝石逐颗亮回来（+1 颗约 0.1s，连续赚有"回血波"的观感）
		displayed = minf(target, displayed + delta * 10.0)
	# 受击抖动（衰减到 0）
	if _shake_t > 0.0:
		_shake_t -= delta
		var k := maxf(_shake_t / 0.25, 0.0)
		_off = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)) * _shake_amp * k
		queue_redraw()
	elif _off != Vector2.ZERO:
		_off = Vector2.ZERO
		queue_redraw()
	if warning:
		_warn_t += delta
		modulate.a = 0.78 + 0.22 * sin(_warn_t * 12.0)
	queue_redraw()
	# 碎片物理
	var alive: Array = []
	for f: Dictionary in _fragments:
		if f.delay > 0.0:
			f.delay = maxf(0.0, f.delay - delta)
			alive.append(f)
			continue
		f.life -= delta
		if f.life <= 0.0:
			continue
		f.vel.y += 260.0 * delta
		f.pos += f.vel * delta
		f.rot += f.vrot * delta
		alive.append(f)
	_fragments = alive
	if not alive.is_empty():
		queue_redraw()


func _shatter(i: int) -> void:
	_breaking[i] = 0.12
	var c := _gem_center(i)
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for k: int in 6:
		var a := rng.randf_range(0.0, TAU)
		_fragments.append({
			"art": "shard_large" if k % 2 == 0 else "shard_small",
			"size": rng.randf_range(7.0, 12.0),
			"delay": 0.12,
			"pos": c + Vector2(rng.randf_range(-6, 6), rng.randf_range(-6, 6)),
			"vel": Vector2(cos(a), sin(a) - 0.6) * rng.randf_range(60.0, 150.0),
			"rot": rng.randf_range(0.0, TAU),
			"vrot": rng.randf_range(-7.0, 7.0),
			"life": rng.randf_range(0.4, 0.6),
		})


func _gem_center(i: int) -> Vector2:
	var cell := bar_width / gem_count
	return Vector2(i * cell + cell * 0.5, size.y * 0.5)


func _gem_half(i: int) -> Vector2:
	var cell := bar_width / gem_count
	var hw := (cell - 5.0) * 0.5
	return Vector2(hw, minf(hw * 0.95, size.y * 0.5 - 3.0))


func _diamond(cx: float, cy: float, hw: float, hh: float) -> PackedVector2Array:
	return PackedVector2Array([Vector2(cx, cy - hh), Vector2(cx + hw, cy),
			Vector2(cx, cy + hh), Vector2(cx - hw, cy)])


func _draw() -> void:
	draw_set_transform(_off, 0.0)  # 受击抖动整体偏移
	for i: int in gem_count:
		var c := _gem_center(i)
		var hw := _gem_half(i).x
		var hh := _gem_half(i).y
		var fill := _gem_fill(i, displayed)
		var state := "gem"
		if _breaking.has(i):
			state = "crack_one" if float(_breaking[i]) > 0.065 else "crack_two"
			fill = 1.0
		var rect := Rect2(c - Vector2(hw, hh), Vector2(hw * 2.0, hh * 2.0))
		UI_ART.draw_gem(self, rect, fill, Color.WHITE, false, state)
	# 脱战警示：每颗宝石向外扩散自己的轮廓（错相波浪）
	if warning:
		var t := Time.get_ticks_msec() / 1000.0
		for i: int in gem_count:
			var p := fmod(t * 1.4 + i * 0.13, 1.0)
			var c := _gem_center(i)
			var hw := _gem_half(i).x * (1.0 + p * 0.6)
			var hh := _gem_half(i).y * (1.0 + p * 0.6)
			var d := _diamond(c.x, c.y, hw, hh)
			draw_polyline(PackedVector2Array([d[0], d[1], d[2], d[3], d[0]]),
					Color(COL_WARN, 0.6 * (1.0 - p)), 1.6)
	# 碎片
	for f: Dictionary in _fragments:
		if f.delay > 0.0:
			continue
		draw_set_transform(f.pos, f.rot)
		var a: float = clampf(f.life / 0.3, 0.0, 1.0)
		var tex := UI_ART.texture(str(f.art))
		var extent := Vector2(float(f.size), float(f.size) * tex.get_height() / tex.get_width())
		draw_texture_rect(tex, Rect2(-extent * 0.5, extent), false, Color(1, 1, 1, a))
	draw_set_transform(Vector2.ZERO, 0.0)
