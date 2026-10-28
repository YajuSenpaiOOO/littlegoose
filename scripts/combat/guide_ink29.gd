extends Node2D
## Screen-width paper thread: charcoal contrast edge, warm hairline, small end tick.
var battle: Node3D
var source: Node3D
func _process(_delta: float) -> void: queue_redraw()
func _draw() -> void:
	if not is_instance_valid(source) or not source.visible or battle.aim_guide_mode!=0: return
	if not source.path_ready: return
	var camera: Camera3D=battle.camera
	if camera.is_position_behind(source.line_origin) or camera.is_position_behind(source.line_end): return
	var a: Vector2=camera.unproject_position(source.line_origin)
	var b: Vector2=camera.unproject_position(source.line_end)
	var span := b-a
	var length := span.length()
	if length<12.: return
	var direction := span/length
	var side := direction.orthogonal()
	var blocked: bool=not source.path_hit.is_empty() and not source.reached_target
	var color := Color(.98,.88,.66) if not blocked else Color(1.,.59,.37)
	var strength := .72 if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) else .48
	var start := a+direction*7.
	var end := b-direction*5.
	for i in 12:
		var t := (float(i)+.5)/12.
		var fade := .55+.45*pow(absf(t*2.-1.),2.)
		var p := start.lerp(end,float(i)/12.)
		var q := start.lerp(end,float(i+1)/12.)
		draw_line(p,q,Color(.055,.075,.055,.33*fade),2.7,true)
		draw_line(p,q,Color(color,strength*fade),1.05,true)
	# One quiet terminal mark; no glowing sphere or animated dashed laser.
	if blocked:
		draw_line(b-side*3.5,b+side*3.5,Color(.06,.075,.055,.65),3.1,true)
		draw_line(b-side*3.5,b+side*3.5,Color(color,.95),1.3,true)
	else:
		draw_circle(b,2.5,Color(.06,.075,.055,.42),true,-1.,true)
		draw_circle(b,1.25,Color(color,.92),true,-1.,true)
		if source.reached_target:
			draw_arc(b,4.3,PI*.15,PI*.85,12,Color(color,.58),1.,true)
	var spread: float=battle.weapon_spread_radians()
	if spread>0.:
		var ray: Vector3=(source.line_end-source.line_origin).normalized()
		for sign in [-1.,1.]:
			var tip: Vector3=source.line_origin+ray.rotated(Vector3.UP,spread*sign)*source.line_origin.distance_to(source.line_end)
			draw_line(start,camera.unproject_position(tip),Color(color,.13),.8,true)
