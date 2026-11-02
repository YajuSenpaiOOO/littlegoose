extends Node3D
## Bounded instanced effects. Air, contact shadow and residue share actual XZ ground.
const MAX_DROPS := 48
const MAX_MARKS := 48
var battle: Node3D
var drops: Array[Dictionary]=[]
var marks: Array[Dictionary]=[]
var rng := RandomNumberGenerator.new()
var airborne: MultiMeshInstance3D
var ground: MultiMeshInstance3D
var shadows: MultiMeshInstance3D
var landed := 0
var hit_clip: AudioStreamWAV
var landing_clip: AudioStreamWAV
var voices: Array[AudioStreamPlayer]=[]
var voice_index := 0
var landing_gate := 0.
var elapsed := 0.
var stereo_clips: Dictionary={}

func _ready() -> void:
	rng.seed=310031
	var sphere := SphereMesh.new()
	sphere.radius=.5; sphere.height=1.; sphere.radial_segments=8; sphere.rings=4
	var color := StandardMaterial3D.new()
	color.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	color.vertex_color_use_as_albedo=true
	airborne=_batch(sphere,color,MAX_DROPS)
	var plane := PlaneMesh.new()
	plane.size=Vector2.ONE
	var ink := ShaderMaterial.new()
	ink.shader=preload("res://scripts/combat/jelly_ground31.gdshader")
	ground=_batch(plane,ink,MAX_MARKS)
	shadows=_batch(plane,ink,MAX_DROPS)
	# Dry contact + low body + small elastic tail, kept separate from sugar crack.
	var samples := PackedFloat32Array()
	samples.resize(int(.16*battle.Audio.RATE))
	battle.Audio._material_noise(samples,.035,.22)
	battle.Audio._mix_tone(samples,210,70,"sine",.10,.24,0.,.001)
	battle.Audio._mix_tone(samples,720,280,"sine",.07,.10,.012,.002)
	battle.Audio._mix_tone(samples,115,190,"sine",.07,.07,.075,.004)
	hit_clip=battle.Audio._to_wav(samples)
	samples=PackedFloat32Array(); samples.resize(int(.085*battle.Audio.RATE))
	battle.Audio._material_noise(samples,.045,.09)
	battle.Audio._mix_tone(samples,170,65,"sine",.075,.10,0.,.002)
	landing_clip=battle.Audio._to_wav(samples)
	for clip in [hit_clip,landing_clip]:
		stereo_clips[clip.get_instance_id()]=[_stereo(clip,-.3),_stereo(clip,0.),_stereo(clip,.3)]
	for i in 8:
		var voice := AudioStreamPlayer.new()
		add_child(voice); voices.append(voice)

func _stereo(source: AudioStreamWAV,pan: float) -> AudioStreamWAV:
	var clip := AudioStreamWAV.new()
	clip.format=AudioStreamWAV.FORMAT_16_BITS
	clip.mix_rate=source.mix_rate; clip.stereo=true
	var input := source.data
	var output := PackedByteArray()
	output.resize(input.size()*2)
	var angle := (pan+1.)*PI*.25
	for i in input.size()/2:
		var value := input.decode_s16(i*2)
		output.encode_s16(i*4,int(value*cos(angle)))
		output.encode_s16(i*4+2,int(value*sin(angle)))
	clip.data=output
	return clip

func _batch(mesh: Mesh,material: Material,capacity: int) -> MultiMeshInstance3D:
	var node := MultiMeshInstance3D.new()
	node.multimesh=MultiMesh.new()
	node.multimesh.transform_format=MultiMesh.TRANSFORM_3D
	node.multimesh.use_colors=true
	node.multimesh.mesh=mesh
	node.multimesh.instance_count=capacity
	node.multimesh.visible_instance_count=0
	node.material_override=material
	node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(node)
	return node

func play_contact(at: Vector3,finishing: bool) -> void:
	_play(hit_clip,at,-4. if finishing else -6.,.87 if finishing else rng.randf_range(.97,1.03))
	if finishing: battle.Audio.play_tuantuan("down")

func _play(clip: AudioStreamWAV,at: Vector3,volume: float,pitch := 1.) -> void:
	if (clip==hit_clip or clip==landing_clip) and battle.has_method("music_contact242") and battle.music_contact242("material"):
		return
	var voice := voices[voice_index%voices.size()]
	voice_index+=1
	# Listener is the playable hero, not the distant perspective camera. Keep the
	# transient readable; modest attenuation only, independent of wheel zoom.
	var distance: float=battle.hero.global_position.distance_to(at)
	var screen: Vector2=battle.camera.unproject_position(at)
	var half: float=battle.get_viewport().get_visible_rect().size.x*.5
	var side := -1 if screen.x<half*.75 else (1 if screen.x>half*1.25 else 0)
	voice.stream=stereo_clips[clip.get_instance_id()][side+1]
	voice.volume_db=volume+3.-clampf(distance*.28,0.,5.)
	voice.pitch_scale=pitch
	voice.play()

func burst(at: Vector3,direction: Vector3,finishing: bool) -> void:
	var forward := Vector3(direction.x,0,direction.z).normalized()
	if forward.length_squared()<.1: forward=Vector3.RIGHT
	var side := forward.cross(Vector3.UP)
	for i in (5 if finishing else 2):
		if drops.size()>=MAX_DROPS: break
		var size := rng.randf_range(.13,.19)*(1.25 if finishing else 1.)
		drops.append({"at":at,"velocity":forward*rng.randf_range(1.1,2.2)+side*rng.randf_range(-1.6,1.6)+Vector3.UP*rng.randf_range(1.8,3.),"age":0.,"size":size})

func clear() -> void:
	drops.clear(); marks.clear(); landed=0; elapsed=0.; landing_gate=0.
	for batch in [airborne,ground,shadows]:
		if is_instance_valid(batch): batch.multimesh.visible_instance_count=0
	for voice in voices: voice.stop()

func _process(delta: float) -> void:
	if battle.combat_paused: return
	elapsed+=delta
	for i in range(marks.size()-1,-1,-1):
		marks[i].age+=delta
		if marks[i].age>=marks[i].life: marks.remove_at(i)
	for i in range(drops.size()-1,-1,-1):
		var drop: Dictionary=drops[i]
		drop.age+=delta
		drop.velocity.y-=9.*delta
		drop.at+=drop.velocity*delta
		var floor_y: float=battle.floor_height(Vector2(drop.at.x,drop.at.z))
		if drop.at.y<=floor_y+drop.size*.35 or drop.age>1.4:
			drop.at.y=floor_y+.033
			if marks.size()>=MAX_MARKS: marks.pop_front()
			marks.append({"at":drop.at,"size":drop.size*rng.randf_range(2.3,3.2),"age":0.,"life":rng.randf_range(1.6,2.6),"angle":rng.randf_range(-PI,PI)})
			landed+=1
			if elapsed>=landing_gate:
				landing_gate=elapsed+.10
				_play(landing_clip,drop.at,-15.)
			drops.remove_at(i)
	_sync()

func _ground_transform(at: Vector3,size: float,angle: float) -> Transform3D:
	var normal: Vector3=battle.floor_normal(Vector2(at.x,at.z))
	var right := Vector3.RIGHT.slide(normal).normalized()
	var basis := Basis(right,normal,right.cross(normal)).rotated(normal,angle)
	return Transform3D(basis.scaled(Vector3(size,1,size*.72)),at)

func _sync() -> void:
	airborne.multimesh.visible_instance_count=drops.size()
	shadows.multimesh.visible_instance_count=drops.size()
	for i in drops.size():
		var drop: Dictionary=drops[i]
		airborne.multimesh.set_instance_transform(i,Transform3D(Basis.IDENTITY.scaled(Vector3(drop.size,drop.size*1.35,drop.size)),drop.at))
		airborne.multimesh.set_instance_color(i,Color(.65,.96,.79))
		var at: Vector3=drop.at
		at.y=battle.floor_height(Vector2(at.x,at.z))+.026
		shadows.multimesh.set_instance_transform(i,_ground_transform(at,drop.size*1.5,0.))
		shadows.multimesh.set_instance_color(i,Color(.12,.24,.17,.22))
	ground.multimesh.visible_instance_count=marks.size()
	for i in marks.size():
		var mark: Dictionary=marks[i]
		var fade: float=1.-smoothstep(mark.life*.55,mark.life,mark.age)
		ground.multimesh.set_instance_transform(i,_ground_transform(mark.at,mark.size,mark.angle))
		ground.multimesh.set_instance_color(i,Color(.54,.85,.64,.66*fade))
