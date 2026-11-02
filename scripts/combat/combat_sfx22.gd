class_name CombatSfx22
extends Object
# 纯合成音效引擎——网页版 js/core/audio.js 的 GDScript 移植（零素材文件）：
# 启动时按网页版配方烘焙出短音效（AudioStreamWAV 16bit 单声道），播放走 8 个
# 轮转 AudioStreamPlayer；同名节流 + 每次播放微随机音高（手感颗粒感）。
# 用法：main._ready 里 Sfx.attach(get_tree())，之后任意处 Sfx.play("shoot")。

const RATE := 44100  # 音效烘焙采样率（高采样率减少方波混叠毛刺）

static var _tree: SceneTree
static var _box: SfxBox
static var _clips := {}
static var _last := {}
static var _gap := {"shoot": 0.045, "hit": 0.04, "kill": 0.08, "crack": 0.05, "thud": 0.09}
static var _hit_combo := 0     # 连击音高叠加：1 秒内连续命中，音调逐发上扬
static var _hit_last := 0.0
static var soft_combat_audio := true # Selected combat palette; preview retains old/new toggle.

static func play_tuantuan(kind: String) -> void:
	play("jelly_"+kind if soft_combat_audio else ("kill" if kind=="down" else "hit"))


class SfxBox:
	extends Node
	# 8 轮转播放器：同帧多音效不互相掐断
	var players: Array[AudioStreamPlayer] = []
	var idx := 0

	func _ready() -> void:
		for i in 8:
			var p := AudioStreamPlayer.new()
			p.volume_db = -8.0
			add_child(p)
			players.append(p)

	func fire(clip: AudioStreamWAV, pitch_mult := 1.0, stable := false) -> void:
		if players.is_empty(): return # attach() enters the tree deferred during startup.
		var p := players[idx % players.size()] as AudioStreamPlayer
		idx += 1
		p.stream = clip
		# 音高连击是主时收窄随机带（±2%），其余保持 ±6% 的自然颗粒感
		p.pitch_scale = (randf_range(0.98, 1.02) if stable else randf_range(0.94, 1.06)) \
				* pitch_mult
		p.play()


static func attach(tree: SceneTree) -> void:
	if _tree != null:
		return
	_tree = tree
	_bake_all()
	_box = SfxBox.new()
	_box.name = "SfxBox"
	tree.root.add_child.call_deferred(_box)  # 普通节点，任何时机入树都正常


static var contact_override242 := Callable()
static func play(name: String, pitch_mult := 1.0) -> void:
	if contact_override242.is_valid() and name in ["hit","jelly_hit","crack","crack_soft"]:
		contact_override242.call(name);return
	if soft_combat_audio:
		if name == "shoot":
			name = "shoot_soft"
		elif name == "crack":
			name = "crack_soft"
	if _tree == null or _box == null or not _clips.has(name):
		return
	var now := Time.get_ticks_msec() / 1000.0
	var gap: float = _gap.get(name, 0.0)
	if gap > 0.0 and _last.has(name) and now - float(_last[name]) < gap:
		return
	_last[name] = now
	var stable := false
	if name == "hit":
		# 连击音高叠加：1.2 秒窗口内连续命中，音调逐发上扬（封顶 +55%）
		_hit_combo = _hit_combo + 1 if now - _hit_last < 1.2 else 1
		_hit_last = now
		pitch_mult *= 1.0 + minf(float(_hit_combo), 10.0) * 0.055
		stable = true  # 音高是主角时随机抖动收窄，不然爬升听不出来
	_box.fire(_clips[name], pitch_mult, stable)


# —— 烘焙 ————————————————————————————————————————————————
static func _material_noise(buf: PackedFloat32Array, dur: float, volume: float) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 77131
	var filtered := 0.0
	var count := mini(buf.size(),int(dur*RATE))
	for i in count:
		filtered = lerpf(filtered,rng.randf_range(-1,1),0.22)
		var k := float(i)/maxf(1,count-1)
		buf[i] += filtered*volume*sin(minf(1,k*25)*PI*0.5)*pow(1-k,2)

static func _bake_material_audio() -> void:
	for name in ["shoot_soft","crack_soft","jelly_hit","jelly_heavy","jelly_down"]:
		var b := PackedFloat32Array()
		var duration := 0.12 if name in ["shoot_soft","jelly_hit"] else (0.2 if name in ["crack_soft","jelly_heavy"] else 0.3)
		b.resize(int(duration*RATE))
		match name:
			"shoot_soft":
				_material_noise(b,0.045,0.11)
				_mix_tone(b,390,190,"sine",0.05,0.035,0,0.002)
			"crack_soft":
				_material_noise(b,0.12,0.22)
				_mix_tone(b,130,65,"sine",0.09,0.08,0,0.002)
			"jelly_hit":
				_material_noise(b,0.075,0.15)
				_mix_tone(b,170,75,"sine",0.09,0.11,0,0.002)
				_mix_tone(b,620,330,"sine",0.045,0.04,0.018,0.002)
			"jelly_heavy":
				_material_noise(b,0.11,0.22)
				_mix_tone(b,100,43,"sine",0.17,0.18,0,0.002)
				_mix_tone(b,440,150,"sine",0.08,0.06,0.025,0.002)
			"jelly_down":
				_material_noise(b,0.16,0.22)
				_mix_tone(b,92,38,"sine",0.24,0.17,0,0.003)
				_mix_tone(b,310,120,"sine",0.08,0.055,0.05,0.002)
		_clips[name] = _to_wav(b)
	_gap.merge({"shoot_soft":0.045,"crack_soft":0.06,"jelly_hit":0.055,"jelly_heavy":0.09,"jelly_down":0.09},true)

# 网页版 tone()：振荡器 + 指数滑频 + 攻击/指数衰减包络
static func _mix_tone(buf: PackedFloat32Array, f: float, f2: float, type: String,
		dur: float, vol: float, when := 0.0, attack := 0.006) -> void:
	var n := int(dur * RATE)
	var start := int(when * RATE)
	var phase := 0.0
	for i in n:
		var k := float(i) / maxf(n - 1, 1)
		var freq := f * pow(f2 / f, k) if f2 > 0.0 and f > 0.0 else f
		phase += freq / RATE
		var ph := fmod(phase, 1.0)
		var s := 0.0
		match type:
			"square": s = 1.0 if ph < 0.5 else -1.0
			"sawtooth": s = ph * 2.0 - 1.0
			"sine": s = sin(phase * TAU)
			"triangle": s = absf(ph * 4.0 - 2.0) - 1.0
		var env := minf((float(i) / RATE) / attack, 1.0) * pow(0.001, k)
		var j := start + i
		if j >= 0 and j < buf.size():
			buf[j] += s * vol * env


# 网页版 noise()：衰减白噪 × 带通（RBJ biquad，恒定峰值增益型）
static func _mix_noise(buf: PackedFloat32Array, dur: float, vol: float,
		freq: float, q := 0.8) -> void:
	var n := int(dur * RATE)
	var w0 := TAU * freq / RATE
	var alpha := sin(w0) / (2.0 * q)
	var a0 := 1.0 + alpha
	var b0 := alpha / a0
	var b1 := 0.0
	var b2 := -alpha / a0
	var a1 := -2.0 * cos(w0) / a0   # a1/a2 也必须归一化——之前漏除导致滤波器
	var a2 := (1.0 - alpha) / a0    # 失稳，噪声变成高频啸叫（"刺耳"的根因）
	var x1 := 0.0
	var x2 := 0.0
	var y1 := 0.0
	var y2 := 0.0
	for i in n:
		var x := randf_range(-1.0, 1.0) * (1.0 - float(i) / maxf(n - 1, 1))
		var y := b0 * x + b1 * x1 + b2 * x2 - a1 * y1 - a2 * y2
		x2 = x1
		x1 = x
		y2 = y1
		y1 = y
		if i < buf.size():
			buf[i] += y * vol


static func _to_wav(buf: PackedFloat32Array) -> AudioStreamWAV:
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.stereo = false
	var bytes := PackedByteArray()
	bytes.resize(buf.size() * 2)
	for i in buf.size():
		bytes.encode_s16(i * 2, int(clampf(buf[i], -1.0, 1.0) * 32767.0))
	wav.data = bytes
	return wav


static func _bake_all() -> void:
	_bake_material_audio()
	# 配方逐条对应网页版 SFX 表
	var b := PackedFloat32Array()
	b.resize(int(0.08 * RATE))
	_mix_tone(b, 860.0, 300.0, "square", 0.07, 0.045)
	_clips["shoot"] = _to_wav(b)

	b = PackedFloat32Array()
	b.resize(int(0.08 * RATE))
	_mix_noise(b, 0.06, 0.15, 1700.0)
	_mix_tone(b, 260.0, 130.0, "square", 0.06, 0.06)
	_clips["hit"] = _to_wav(b)

	b = PackedFloat32Array()
	b.resize(int(0.28 * RATE))
	_mix_noise(b, 0.22, 0.22, 700.0, 0.6)
	_mix_tone(b, 190.0, 48.0, "sawtooth", 0.26, 0.11)
	_clips["kill"] = _to_wav(b)

	b = PackedFloat32Array()
	b.resize(int(0.22 * RATE))
	_mix_tone(b, 210.0, 78.0, "sawtooth", 0.2, 0.13)
	_mix_noise(b, 0.12, 0.13, 420.0)
	_clips["hurt"] = _to_wav(b)

	# 撞碰撞箱碎裂：低沉闷裂（区别于命中的高频"啪"）
	b = PackedFloat32Array()
	b.resize(int(0.12 * RATE))
	_mix_noise(b, 0.09, 0.2, 800.0, 0.6)
	_mix_tone(b, 120.0, 55.0, "triangle", 0.1, 0.09)
	_clips["crack"] = _to_wav(b)

	# 连击阶段提示音：上行三连音（C5-E5-G5，随阶段整体升调）
	b = PackedFloat32Array()
	b.resize(int(0.3 * RATE))
	_mix_tone(b, 523.25, 523.25, "triangle", 0.08, 0.05)
	_mix_tone(b, 659.26, 659.26, "triangle", 0.08, 0.05, 0.07)
	_mix_tone(b, 783.99, 783.99, "triangle", 0.12, 0.05, 0.14)
	_clips["style"] = _to_wav(b)

	# 硬撑心跳：低频双沉闷点（由 battle_ui 每 0.8s 触发一次）
	b = PackedFloat32Array()
	b.resize(int(0.22 * RATE))
	_mix_tone(b, 70.0, 45.0, "sine", 0.18, 0.22)
	_clips["heart"] = _to_wav(b)

	# 散场：长下坠锯齿 + 塌陷噪声
	b = PackedFloat32Array()
	b.resize(int(0.7 * RATE))
	_mix_tone(b, 220.0, 55.0, "sawtooth", 0.6, 0.12)
	_mix_noise(b, 0.4, 0.08, 300.0, 0.5)
	_clips["over"] = _to_wav(b)

	# 三选一确认：短促上行双音
	b = PackedFloat32Array()
	b.resize(int(0.16 * RATE))
	_mix_tone(b, 660.0, 660.0, "triangle", 0.05, 0.055)
	_mix_tone(b, 990.0, 990.0, "triangle", 0.1, 0.05, 0.05)
	_clips["pick"] = _to_wav(b)

	# 冲刺：高频气声 + 上滑正弦（网页版 dash 配方）
	b = PackedFloat32Array()
	b.resize(int(0.16 * RATE))
	_mix_noise(b, 0.13, 0.11, 2500.0, 0.5)
	_mix_tone(b, 480.0, 940.0, "sine", 0.12, 0.05)
	_clips["dash"] = _to_wav(b)

	# 草稿卡落屏：软"拍"（下滑三角 + 一点噪声拍击）
	b = PackedFloat32Array()
	b.resize(int(0.16 * RATE))
	_mix_tone(b, 330.0, 150.0, "triangle", 0.11, 0.14)
	_mix_noise(b, 0.05, 0.06, 1100.0, 0.7)
	_clips["land"] = _to_wav(b)

	# 强化入体：温暖的上行双音微微闪烁
	b = PackedFloat32Array()
	b.resize(int(0.24 * RATE))
	_mix_tone(b, 520.0, 560.0, "sine", 0.1, 0.09)
	_mix_tone(b, 780.0, 830.0, "sine", 0.12, 0.07, 0.06)
	_clips["absorb"] = _to_wav(b)

	# 精英砸地闷响：超低频下坠正弦（95→34Hz）+ 低通噪声冲击——"重量"的声学配方。
	# 低频是最不疲劳的打击感通道：耳朵不刺，胸口有感觉
	b = PackedFloat32Array()
	b.resize(int(0.3 * RATE))
	_mix_tone(b, 95.0, 34.0, "sine", 0.26, 0.30)
	_mix_noise(b, 0.10, 0.16, 260.0, 0.5)
	_clips["thud"] = _to_wav(b)

	# 收集时光沙：细沙"唰"（高频短噪）+ 温暖小升音（沙漏在说"谢谢"）
	b = PackedFloat32Array()
	b.resize(int(0.14 * RATE))
	_mix_noise(b, 0.09, 0.10, 1400.0, 0.6)
	_mix_tone(b, 520.0, 780.0, "sine", 0.12, 0.07, 0.03)
	_clips["sand_take"] = _to_wav(b)

	# 乐器课音符弹：故意不准的双平方波三连音（"很怪的音效"——小学生竖笛）
	# note1 紫(降si打架) / note2 琥珀(米-降米) / note3 青绿(高音抖)
	b = PackedFloat32Array()
	b.resize(int(0.12 * RATE))
	_mix_tone(b, 523.0, 523.0, "square", 0.06, 0.04)
	_mix_tone(b, 554.0, 554.0, "square", 0.08, 0.04, 0.03)
	_clips["note1"] = _to_wav(b)
	_clips["note"] = _clips["note1"]  # 兼容旧调用
	b = PackedFloat32Array()
	b.resize(int(0.12 * RATE))
	_mix_tone(b, 659.0, 659.0, "square", 0.06, 0.04)
	_mix_tone(b, 622.0, 622.0, "square", 0.08, 0.04, 0.03)
	_clips["note2"] = _to_wav(b)
	b = PackedFloat32Array()
	b.resize(int(0.14 * RATE))
	_mix_tone(b, 784.0, 784.0, "square", 0.05, 0.04)
	_mix_tone(b, 830.0, 830.0, "square", 0.09, 0.04, 0.04)
	_clips["note3"] = _to_wav(b)

	# 沙漏倒沙：细沙长流"沙沙"（半秒）+ 末尾一声暖铃（长大了一岁）
	b = PackedFloat32Array()
	b.resize(int(0.6 * RATE))
	_mix_noise(b, 0.5, 0.06, 900.0, 0.55)
	_mix_tone(b, 660.0, 990.0, "sine", 0.18, 0.06, 0.38)
	_clips["sand_pour"] = _to_wav(b)

	# 弹反成功：金属"叮"（打铁版）——起始金属噪声瞬态 + 高频三角急落 + 泛音正弦。
	# 比命中"亮"一档且干脆（短攻击快衰减），成功的奖励音必须一击入耳
	b = PackedFloat32Array()
	b.resize(int(0.15 * RATE))
	_mix_noise(b, 0.025, 0.09, 5000.0, 0.7)
	_mix_tone(b, 2093.0, 1046.0, "triangle", 0.11, 0.13)
	_mix_tone(b, 2637.0, 2637.0, "sine", 0.06, 0.06)
	_clips["parry"] = _to_wav(b)

	# 弹反落空：钝"噗"（短低音 + 闷噪）——whiff 惩罚要听得见，但不能刺
	b = PackedFloat32Array()
	b.resize(int(0.1 * RATE))
	_mix_tone(b, 150.0, 85.0, "triangle", 0.09, 0.1)
	_mix_noise(b, 0.06, 0.08, 320.0, 0.6)
	_clips["parry_whiff"] = _to_wav(b)

	# 弹反起手：极轻的高频气声（输入确认，音量刻意小——不抢成功的"叮"）
	b = PackedFloat32Array()
	b.resize(int(0.07 * RATE))
	_mix_noise(b, 0.05, 0.04, 2800.0, 0.5)
	_clips["parry_on"] = _to_wav(b)

	# 弹弓蓄力：上升音（按住期间的"拉弓"——憋红视觉接力到满蓄）
	b = PackedFloat32Array()
	b.resize(int(0.55 * RATE))
	_mix_tone(b, 220.0, 880.0, "sine", 0.5, 0.07)
	_mix_tone(b, 440.0, 1760.0, "triangle", 0.5, 0.03, 0.1)
	_clips["charge"] = _to_wav(b)

	# 弹弓发射：重炮（低频炮击 + 高频破空）——比普攻重两档的"咻砰"
	b = PackedFloat32Array()
	b.resize(int(0.2 * RATE))
	_mix_tone(b, 300.0, 90.0, "square", 0.14, 0.09)
	_mix_noise(b, 0.12, 0.16, 1400.0, 0.6)
	_mix_tone(b, 900.0, 300.0, "triangle", 0.1, 0.06)
	_clips["slingshot"] = _to_wav(b)

	# 手电筒光束：zap（高频锯齿急落 + 破空噪）——光柱的"咻"
	b = PackedFloat32Array()
	b.resize(int(0.18 * RATE))
	_mix_tone(b, 1800.0, 500.0, "sawtooth", 0.12, 0.05)
	_mix_noise(b, 0.1, 0.08, 2600.0, 0.6)
	_clips["beam"] = _to_wav(b)

	# 弹反接满（连段 3）：重锤"锵"——更长的金属余韵 + 低频尾（超慢镜头的声音侧）
	b = PackedFloat32Array()
	b.resize(int(0.45 * RATE))
	_mix_noise(b, 0.025, 0.1, 5000.0, 0.7)
	_mix_tone(b, 1046.0, 523.0, "triangle", 0.3, 0.13)
	_mix_tone(b, 2093.0, 2093.0, "sine", 0.1, 0.05)
	_mix_tone(b, 262.0, 240.0, "sine", 0.34, 0.09, 0.04)
	_clips["parry_big"] = _to_wav(b)
