extends "res://scripts/combat/jelly_fx31.gd"
const MAX_BITS := 64
var bits: Array[Dictionary]=[]
var sugar: MultiMeshInstance3D
var sugar_shadows: MultiMeshInstance3D
var bounces := 0
var settlements := 0

func _ready() -> void:
	super._ready()
	var quad := QuadMesh.new()
	quad.size=Vector2(1,208./144.)
	var ink := ShaderMaterial.new()
	ink.shader=preload("res://scripts/combat/sugar_piece32.gdshader")
	var texture: Texture2D=preload("res://assets/perfect_dodge_v1/animated/a_starcut_parts_v1.png")
	ink.set_shader_parameter("sheet",texture)
	ink.set_shader_parameter("region",Vector4(1209./texture.get_width(),158./texture.get_height(),144./texture.get_width(),208./texture.get_height()))
	sugar=_batch(quad,ink,MAX_BITS)
	var plane := PlaneMesh.new()
	plane.size=Vector2.ONE
	var shadow_ink := ShaderMaterial.new()
	shadow_ink.shader=preload("res://scripts/combat/jelly_ground31.gdshader")
	sugar_shadows=_batch(plane,shadow_ink,MAX_BITS)

func break_sugar(at: Vector3,direction: Vector3) -> void:
	var backward := -Vector3(direction.x,0,direction.z).normalized()
	if backward.length_squared()<.1: backward=Vector3.RIGHT
	var side := backward.cross(Vector3.UP)
	for i in 4:
		if bits.size()>=MAX_BITS: break
		var main := i<2
		bits.append({"at":at,"velocity":backward*rng.randf_range(1.3,2.8)+side*(1. if i%2==0 else -1.)*rng.randf_range(.8,2.)+Vector3.UP*rng.randf_range(1.4,2.4),"age":0.,"size":rng.randf_range(.18,.24) if main else rng.randf_range(.045,.075),"angle":rng.randf_range(-PI,PI),"spin":rng.randf_range(-9.,9.),"bounce":false,"settled":false,"rest":0.,"life":rng.randf_range(.55,.85),"main":main})

func clear() -> void:
	super.clear()
	bits.clear(); bounces=0; settlements=0
	for batch in [sugar,sugar_shadows]:
		if is_instance_valid(batch): batch.multimesh.visible_instance_count=0

func _process(delta: float) -> void:
	super._process(delta)
	if battle.combat_paused: return
	# Bounded integration handles long frames and detects slopes at each step.
	var remaining := minf(delta,.25)
	while remaining>0.:
		var step := minf(remaining,1./120.)
		for i in range(bits.size()-1,-1,-1):
			var bit: Dictionary=bits[i]
			bit.age+=step
			if bit.settled:
				bit.rest+=step
				if bit.rest>=bit.life: bits.remove_at(i)
				continue
			bit.velocity.y-=9.5*step
			bit.at+=bit.velocity*step
			bit.angle+=bit.spin*step
			var at: Vector3=bit.at
			var floor_y: float=battle.floor_height(Vector2(at.x,at.z))+.028
			if at.y<=floor_y:
				bit.at.y=floor_y
				var normal: Vector3=battle.floor_normal(Vector2(at.x,at.z))
				if bit.main and not bit.bounce:
					bit.bounce=true; bounces+=1
					bit.velocity=Vector3(bit.velocity).bounce(normal)*.28
					bit.spin*=.45
				else:
					bit.settled=true; settlements+=1
					bit.velocity=Vector3.ZERO
			if bit.age>2.: bits.remove_at(i)
		remaining-=step
	_sync_sugar()

func _sync_sugar() -> void:
	if not is_instance_valid(sugar): return
	sugar.multimesh.visible_instance_count=bits.size()
	sugar_shadows.multimesh.visible_instance_count=bits.size()
	for i in bits.size():
		var bit: Dictionary=bits[i]
		var basis: Basis=battle.camera.global_basis*Basis(Vector3.BACK,bit.angle)
		if bit.settled:
			var normal: Vector3=battle.floor_normal(Vector2(bit.at.x,bit.at.z))
			var right := Vector3.RIGHT.slide(normal).normalized()
			basis=Basis(right,normal.cross(right),normal).rotated(normal,bit.angle)
		var fade: float=1.-smoothstep(bit.life*.5,bit.life,bit.rest) if bit.settled else 1.
		sugar.multimesh.set_instance_transform(i,Transform3D(basis.scaled(Vector3(bit.size,bit.size,bit.size)),bit.at))
		sugar.multimesh.set_instance_color(i,Color(1.,.94,.85,fade))
		var ground_at: Vector3=bit.at
		ground_at.y=battle.floor_height(Vector2(ground_at.x,ground_at.z))+.025
		sugar_shadows.multimesh.set_instance_transform(i,_ground_transform(ground_at,bit.size*1.3,bit.angle))
		sugar_shadows.multimesh.set_instance_color(i,Color(.16,.18,.12,.22*fade))
