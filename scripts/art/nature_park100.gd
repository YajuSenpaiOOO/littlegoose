extends "res://scripts/art/nature_park99.gd"
var seat_body100: AnimatableBody3D
var seat_anchor100: Marker3D
var angle100 := 0.
var angular_speed100 := 0.
var length100 := 2.5
var bump_cooldown100 := 0.
var bump_count100 := 0
var max_angle100 := 0.
func _swing97() -> void:
	var visual: Sprite3D=world.swing_tree99.visual
	var foot := Vector2(1000.,1230.)
	for pixel in [Vector2(411.,700.),Vector2(548.,713.)]:
		anchors99.append(visual.global_position+Vector3((pixel.x-foot.x)*visual.pixel_size,(foot.y-pixel.y)*visual.pixel_size,.025))
	swing_origin97=(anchors99[0]+anchors99[1])*.5
	swing97=Node3D.new();swing97.name="TouchSwing100";swing97.position=swing_origin97;add_child(swing97)
	var ground_y: float=world.floor_height(Vector2(swing_origin97.x,swing_origin97.z))
	var seat_y := ground_y+.68-swing_origin97.y;length100=-seat_y
	for anchor in anchors99:
		var top := anchor-swing_origin97
		_cylinder97(top,Vector3(top.x,seat_y+.06,top.z),.022,rope97,false,swing97)
	var span := absf(anchors99[1].x-anchors99[0].x)
	seat_body100=AnimatableBody3D.new();seat_body100.name="SwingSeatCollision100"
	# This transform is advanced by _physics_process, not an idle animation.
	seat_body100.sync_to_physics=false
	seat_body100.collision_layer=2;seat_body100.collision_mask=0;seat_body100.position=Vector3(0,seat_y,0)
	swing97.add_child(seat_body100)
	_box97(Vector3.ZERO,Vector3(span+.32,.15,.55),wood97,false,seat_body100)
	var shape := BoxShape3D.new();shape.size=Vector3(span+.32,.15,.55)
	var collider := CollisionShape3D.new();collider.shape=shape;seat_body100.add_child(collider)
	seat_anchor100=Marker3D.new();seat_anchor100.name="FutureSittingAnchor100";seat_anchor100.position.y=.10;seat_body100.add_child(seat_anchor100)
func kick100(direction: float,strength := 1.) -> void:
	angular_speed100=clampf(angular_speed100-direction*.8*clampf(strength,.1,1.5),-1.1,1.1)
	bump_count100+=1;bump_cooldown100=.4
func _process(_delta: float) -> void: pass
func _physics_process(delta: float) -> void:
	if not is_instance_valid(seat_body100): return
	bump_cooldown100=maxf(0.,bump_cooldown100-delta)
	if bump_cooldown100<=0. and is_instance_valid(world.hero):
		var wish: Vector2=world.hero.movement_input()
		if wish.length()>.1:
			for i in world.hero.get_slide_collision_count():
				if world.hero.get_slide_collision(i).get_collider()==seat_body100:
					kick100(wish.y if absf(wish.y)>.15 else wish.x*.25);break
	if absf(angle100)+absf(angular_speed100)<.0002:
		angle100=0.;angular_speed100=0.
	else:
		angular_speed100+=(-9.8/maxf(length100,.5)*sin(angle100)-1.6*angular_speed100)*delta
		angle100=clampf(angle100+angular_speed100*delta,-.42,.42)
		if absf(angle100)>=.42: angular_speed100*=-.25
	max_angle100=maxf(max_angle100,absf(angle100));swing97.rotation.x=angle100
