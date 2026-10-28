extends Control
var battle: Node3D
var bursts: Array[Dictionary] = []
var marker := 0.

func impact(at: Vector3,down: bool) -> void:
	bursts.append({"at":at,"age":0.,"down":down})
	marker = .13

func _process(delta: float) -> void:
	delta = minf(delta,.04)
	if not battle.combat_paused:
		marker = maxf(0.,marker-delta)
		for i in range(bursts.size()-1,-1,-1):
			bursts[i].age += delta
			if bursts[i].age>.23: bursts.remove_at(i)
	queue_redraw()

func _draw() -> void:
	if not battle.combat_ready: return
	var cursor := get_local_mouse_position()
	var selected = battle.hover_enemy
	var color := Color("bfeec5") if is_instance_valid(selected) else Color("ffe4ac")
	_draw_cursor(cursor,color)
	if marker>0.:
		for v in [Vector2(1,1),Vector2(-1,1),Vector2(1,-1),Vector2(-1,-1)]:
			draw_line(cursor+v*7.,cursor+v*12.,Color(1,1,.9,marker/.13),2.,true)
	for burst in bursts:
		var screen: Vector2 = battle.camera.unproject_position(burst.at)
		var t: float = burst.age/.23
		var size := 22. if burst.down else 15.
		for i in 6:
			var direction := Vector2.from_angle(float(i)*TAU/6.+.3)
			draw_line(screen+direction*(3.+t*size),screen+direction*(7.+t*size),Color(1.,.9,.62,1.-t),2.,false)

func _draw_cursor(cursor: Vector2,color: Color) -> void:
	draw_arc(cursor,5.,0,TAU,20,color,1.5,true)
	for v in [Vector2.RIGHT,Vector2.DOWN]:
		draw_line(cursor+v*8.,cursor+v*13.,color,1.5,true)
		draw_line(cursor-v*8.,cursor-v*13.,color,1.5,true)
