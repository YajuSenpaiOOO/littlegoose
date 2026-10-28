extends "res://scripts/combat/tuantuan31.gd"
var soft_ink: ShaderMaterial
var dent_age := 10.
var contact_uv := Vector2(.5,.5)
var screen_push := Vector2.RIGHT
var tuft := 0.
var tuft_velocity := 0.
var landing_count := 0

func _ready() -> void:
	super._ready()
	soft_ink=ShaderMaterial.new()
	soft_ink.shader=preload("res://scripts/combat/soft_body32.gdshader")
	_render_legacy(visual.position.y)

func receive_hit(damage: float,direction: Vector3) -> void:
	if dead: return
	var contact := impact_contact if impact_contact.is_finite() else global_position+Vector3.UP*.65-direction.normalized()*.3
	dent_age=0.
	screen_push=battle.screen_direction(global_position,direction)*Vector2(1,-1)
	super.receive_hit(damage,direction)
	var local := visual.to_local(contact)
	var size := visual.texture.get_size()
	contact_uv=Vector2(size.x*.5+local.x/visual.pixel_size-visual.offset.x,size.y*.5+visual.offset.y-local.y/visual.pixel_size)/size
	if visual.flip_h: contact_uv.x=1.-contact_uv.x
	contact_uv=contact_uv.clamp(Vector2(.1,.1),Vector2(.9,.9))
	tuft_velocity-=screen_push.x*1.3
	_render_legacy(visual.position.y)

func _physics_process(delta: float) -> void:
	if battle.combat_paused: return
	_step_soft_response(delta)
	var was_hopping := hopping
	super._physics_process(delta)
	if was_hopping and not hopping and not dead and battle.enhanced_feedback:
		landing_count+=1
		squeeze=minf(.16,squeeze+.075)
		squeeze_velocity=-.25
		tuft_velocity+=.25
		_render_legacy(0.)

func _step_soft_response(delta: float) -> void:
	dent_age+=delta
	var remaining := minf(delta,.1)
	while remaining>0.:
		var step := minf(remaining,1./120.)
		tuft_velocity+=(-125.*tuft-12.*tuft_velocity)*step
		tuft=clampf(tuft+tuft_velocity*step,-.10,.10)
		remaining-=step

func _render_legacy(lift: float) -> void:
	super._render_legacy(lift)
	if soft_ink==null: return
	if not battle.enhanced_feedback or not battle.material_feedback:
		visual.material_override=null
		return
	visual.material_override=soft_ink
	var size := visual.texture.get_size()
	# Values come from each pose's own anchor and visible dimensions.
	var key := "idle"
	if dead: key="hit" if defeat_age<.065 else "defeated"
	elif hit_left>0.: key="hit"
	elif landing_left>0.: key="landing"
	elif hopping: key="anticipation" if hop_clock<.045 else "airborne"
	var entry: Dictionary=poses[key]
	var span := Vector2(float(entry.visible_width),float(entry.visible_height))/24./(size*visual.pixel_size)
	soft_ink.set_shader_parameter("art",visual.texture)
	soft_ink.set_shader_parameter("tint",Color(visual.modulate,1.-visual.transparency))
	soft_ink.set_shader_parameter("body_span",span)
	soft_ink.set_shader_parameter("foot_y",float(entry.foot[1])/size.y)
	soft_ink.set_shader_parameter("contact_uv",contact_uv)
	soft_ink.set_shader_parameter("push",screen_push)
	soft_ink.set_shader_parameter("dent",.085*exp(-dent_age*19.) if not dead else 0.)
	soft_ink.set_shader_parameter("head_lag",tuft)
