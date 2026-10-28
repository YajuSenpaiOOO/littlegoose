extends "res://scripts/world/world_surface85.gd"
## A western shoulder branches from the rear woodland shelf. Never an arena rim.
func upper_front73(x: float) -> float:
	var old := super.upper_front73(x)
	var blend := smoothstep(-80.,-73.,x)*(1.-smoothstep(-30.,-23.,x))
	# Two forward headlands and a recessed saddle, all continuing to the north.
	var front := -65.5+2.5*exp(-pow((x+65.)/5.8,2.))+3.7*exp(-pow((x+44.)/6.5,2.))
	front-=2.4*exp(-pow((x+55.)/4.3,2.))
	return lerpf(old,front,blend)

func west_edge90(z: float) -> float:
	return landmarks.grove.x-25.5+1.1*sin(z*.19)+3.1*exp(-pow((z-landmarks.grove.y+5.)/7.,2.))

func height_at(x: float,z: float,enabled: bool) -> float:
	var h := super.height_at(x,z,enabled)
	if not enabled or landmarks.is_empty() or x> -27. or z> -27. or z< -83.: return h
	var at := Vector2(x,z)
	var field := ((at-Vector2(landmarks.grove))/FIELD_RADII76).length()
	var protect := smoothstep(1.03,1.20,field)*smoothstep(1.7,3.6,route_distance(at))
	# Replace the old single smooth upper shoulder with connected rock benches.
	var front := upper_front73(x)
	var d := z-front
	var exposure := maxf(exp(-pow((x+68.)/4.5,2.)),maxf(exp(-pow((x+47.)/4.5,2.)),exp(-pow((x+29.)/3.5,2.))))
	var shoulder := lerpf(5.2,.95,exposure)
	var wide := 1.-smoothstep(-3.8,3.8,d)
	var old_upper := wide+((1.-smoothstep(-shoulder,shoulder,d))-wide)*smoothstep(1.8,3.5,route_distance(at))
	var fold := .26*sin(x*.73)+.15*sin(x*1.21)
	# A dominant face with only two local shelves, rather than horizontal tiers.
	var bench := .23*exp(-pow((x+64.)/3.7,2.))+.18*exp(-pow((x+40.)/3.4,2.))
	var stepped := (1.-bench)*(1.-smoothstep(-.90,.85,d+fold))
	stepped+=bench*(1.-smoothstep(-3.3,-2.35,d-fold*.45))
	var outcrop := maxf(exp(-pow((x+65.)/6.5,2.)),exp(-pow((x+43.)/7.,2.)))
	var new_upper := lerpf(1.-smoothstep(-4.7,4.7,d),stepped,outcrop*.94)
	var regional := (1.-smoothstep(-28.,-13.,x))*smoothstep(-83.,-79.,z)
	h+=(UPPER72-MAIN72)*(new_upper*protect-old_upper)*regional
	# Broad western top has an open connection to the high forest behind it.
	# It tapers down south of the entry; it does not curve round the battle field.
	var west := 1.-smoothstep(-1.3,1.45,x-west_edge90(z))
	west*=1.-smoothstep(landmarks.grove.y+5.,landmarks.grove.y+15.,z)
	var west_level := lerpf(4.55,UPPER72,1.-smoothstep(-71.,-59.,z))
	h=maxf(h,lerpf(MAIN72,west_level,west*protect))
	return h

func is_open_ground(at: Vector2) -> bool:
	if at.x< -28. and at.y< -27.:
		if normal_at(at.x,at.y,true).y<.93: return true
		# Keep a view onto each outcrop. Trees grow on tops and in the saddle.
		for x in [-65.,-43.]:
			if absf(at.x-x)<4.8 and absf(at.y-upper_front73(at.x))<5.5: return true
		if absf(at.x-west_edge90(at.y))<2.5: return true
	return super.is_open_ground(at)

func _terrain_divisions19(rect: Rect2,ids: Array[int]) -> int:
	if rect.intersects(Rect2(Vector2(-81.,-78.),Vector2(55.,52.))): return 64
	return super._terrain_divisions19(rect,ids)
