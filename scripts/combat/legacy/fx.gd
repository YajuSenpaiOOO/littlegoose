extends Object
# 一次性柔圆粒子蓬（网页版 poof 的移植）——全部战斗特效共用一个出口：
# 受击火星 / 死亡白烟 / 弹幕碎裂 / 出土泥土。颜色、方向、数量参数化；at 用全局坐标。
#
# 实测教训（fx_render_test / fx_bisect* / fx_matrix / real_game_probe 系列）：
#   1. 无贴图的 CPUParticles2D 只有 1px 小方块，画面里几乎不可见（51 vs 334 粉像素）；
#   2. 一次性粒子在物理回调里入树会"节点在、就是不画"（子弹 _physics_process
#      死亡瞬间生成火星，实测像素 0；call_deferred / timer(0) / 跑腿节点 _process
#      均绕不开）。而普通 Node2D 在物理回调里入树渲染完全正常（弹幕本尊就是）。
#   → 所以最终实现放弃 CPUParticles2D，用"小圆点 Sprite2D + Tween"手写粒子蓬，
#     与弹幕同机制，任何上下文都稳定渲染。

static var _dot_tex: ImageTexture
static var _burst_live := 0        # 存活粒子预算：超限削减新粒子（特效风暴=帧率崩塌源，
const BURST_BUDGET := 380          # 第七幕水环齐放曾把全场动画拖成"只剩平移"）


static func _dot() -> ImageTexture:
	# 方形碎块（制作人钦点：早期那种方粒子，不是软圆雾）；缺角 1px 增加碎块感
	if _dot_tex == null:
		var img := Image.create(8, 8, false, Image.FORMAT_RGBA8)
		img.fill(Color(1, 1, 1, 1))
		for c: Vector2i in [Vector2i(0, 0), Vector2i(7, 0), Vector2i(0, 7), Vector2i(7, 7)]:
			img.set_pixel(c.x, c.y, Color(1, 1, 1, 0))
		_dot_tex = ImageTexture.create_from_image(img)
	return _dot_tex


# UI 侧粒子（草稿流/入体光点）与战斗粒子共用同一张方形碎块纹理
static func dot_texture() -> ImageTexture:
	return _dot()


static func burst(parent: Node, at: Vector2, n: int, vmin: float, vmax: float,
		col: Color, dir := Vector2.ZERO, life := 0.4,
		scale_min := 0.5, scale_max := 0.9, gravity := Vector2.ZERO) -> void:
	var room := maxi(BURST_BUDGET - _burst_live, 0)
	if room == 0:
		return  # 预算见底：宁可少一蓬粒子也不掉帧（掉帧=全场动画停摆）
	n = mini(n, room)
	var base := dir if dir != Vector2.ZERO else Vector2(0, -1)
	for i in n:
		var dot := Sprite2D.new()
		dot.texture = _dot()
		dot.modulate = col
		dot.z_index = 20
		dot.scale = Vector2.ONE * randf_range(scale_min, scale_max)
		parent.add_child(dot)
		dot.position = at
		dot.reset_physics_interpolation()  # 项目开全局 2D 插值：不重置会先闪现在原点再飞过来
		_burst_live += 1
		dot.tree_exited.connect(func() -> void: _burst_live -= 1, CONNECT_ONE_SHOT)
		var vel := base.rotated(randf_range(-1.5, 1.5)) * randf_range(vmin, vmax)
		var end_pos := at + vel * life + gravity * life * life * 0.5
		var tw := dot.create_tween()
		tw.set_parallel(true)
		tw.tween_property(dot, "position", end_pos, life) \
				.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		tw.tween_property(dot, "modulate:a", 0.0, life)
		tw.chain().tween_callback(func() -> void:
			dot.queue_free())  # 括号必须带：写 dot.queue_free 是方法引用不是调用（静默 no-op），
		# 上一版因此泄漏了全部粒子（nodes 每秒上千地涨到 2 万+——制作人实测）


# 地面痕迹：命中点留两粒暗色碎屑，停一会儿再淡出（给战场留"打过的痕迹"）
static func mark(parent: Node, at: Vector2, col: Color) -> void:
	for i in 2:
		var dot := Sprite2D.new()
		dot.texture = _dot()
		dot.modulate = Color(col.darkened(0.45), 0.55)
		dot.z_index = 1  # 地皮之上、弹幕之下
		dot.scale = Vector2.ONE * randf_range(0.3, 0.55)
		dot.rotation = randf_range(0.0, TAU)
		parent.add_child(dot)
		dot.position = at + Vector2(randf_range(-7.0, 7.0), randf_range(-7.0, 7.0))
		dot.reset_physics_interpolation()
		var tw := dot.create_tween()
		tw.tween_interval(2.2)
		tw.tween_property(dot, "modulate:a", 0.0, 1.2)
		tw.tween_callback(dot.queue_free)


# 击杀扩散环：白环从怪身上扩开（网页版 killEnemy 的 effects ring 同款）
static func ring(parent: Node, at: Vector2, col := Color(1, 1, 1, 0.9),
		life := 0.22) -> void:
	var ring_node := Ring.new()
	ring_node.col = col
	ring_node.life = life
	ring_node.z_index = 20
	parent.add_child(ring_node)
	ring_node.global_position = at
	ring_node.reset_physics_interpolation()  # 同 burst：防插值瞬移闪光


class Ring:
	extends Node2D
	var r0 := 6.0
	var r1 := 44.0
	var col := Color(1, 1, 1, 0.9)
	var life := 0.22
	var t := 0.0

	func _process(delta: float) -> void:
		t += delta
		queue_redraw()
		if t >= life:
			queue_free()

	func _draw() -> void:
		var k := clampf(t / life, 0.0, 1.0)
		var r := lerpf(r0, r1, 1.0 - pow(1.0 - k, 2.0))  # ease-out 扩散
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 32,
				Color(col.r, col.g, col.b, col.a * (1.0 - k)), 2.0)
