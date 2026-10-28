extends RefCounted
var masks: Dictionary = {}

func plane_point(camera: Camera3D,point: Vector2,height: float) -> Vector3:
	var origin := camera.project_ray_origin(point)
	var ray := camera.project_ray_normal(point)
	if absf(ray.y)<.0001: return Vector3.INF
	var t := (height-origin.y)/ray.y
	return origin+ray*t if t>0. else Vector3.INF

func sprite_contains(camera: Camera3D,point: Vector2,sprite: Sprite3D) -> bool:
	# Test the visible card, not a sphere floating somewhere inside it.
	var texture := sprite.texture
	if not masks.has(texture):
		var bitmap := BitMap.new()
		bitmap.create_from_image_alpha(texture.get_image(),.2)
		masks[texture] = bitmap
	var origin := camera.project_ray_origin(point)
	var ray := camera.project_ray_normal(point)
	if absf(ray.z)<.0001: return false
	var t := (sprite.global_position.z-origin.z)/ray.z
	if t<=0.: return false
	var local := origin+ray*t-sprite.global_position
	var pixel := Vector2i(floori(local.x/(sprite.pixel_size*sprite.scale.x)+texture.get_width()*.5-sprite.offset.x),floori(texture.get_height()*.5+sprite.offset.y-local.y/(sprite.pixel_size*sprite.scale.y)))
	return Rect2i(Vector2i.ZERO,texture.get_size()).has_point(pixel) and masks[texture].get_bitv(pixel)

func sweep_circle(a: Vector2,b: Vector2,center: Vector2,radius: float) -> float:
	var start := a-center
	if start.length_squared()<=radius*radius: return 0.
	var v := b-a
	var aa := v.length_squared()
	if aa<.000001: return INF
	var bb := 2.*start.dot(v)
	var cc := start.length_squared()-radius*radius
	var discriminant := bb*bb-4.*aa*cc
	if discriminant<0.: return INF
	var t := (-bb-sqrt(discriminant))/(2.*aa)
	return t if t>=0. and t<=1. else INF
