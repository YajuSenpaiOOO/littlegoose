extends Node2D
## A single canvas renderer owns the detached legacy star particles.
const Art = preload("res://scripts/combat/legacy/candy_bullet_art.gd")
var battle: Node3D
var particles: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()
func _ready() -> void:
	rng.randomize()
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
func emit_at(at: Vector3,direction: Vector3) -> void:
	if not Art.particle_trail_enabled or particles.size()>=160: return
	var facing: Vector2 = battle.screen_direction(at,direction)
	particles.append({"at":at,"offset":-facing*2.2,"velocity":-facing*rng.randf_range(5.,12.)+facing.orthogonal()*rng.randf_range(-12.,12.),"age":0.,"life":rng.randf_range(.18,.27),"size":rng.randf_range(4.4,6.4),"angle":rng.randf_range(-.6,.6),"spin":rng.randf_range(-4.,4.)})
func _process(delta: float) -> void:
	for i in range(particles.size()-1,-1,-1):
		var p: Dictionary = particles[i]
		p.age += delta
		if p.age>=p.life: particles.remove_at(i); continue
		p.offset += p.velocity*delta
		p.velocity *= exp(-5.*delta)
		p.angle += p.spin*delta
	queue_redraw()
func _draw() -> void:
	for p in particles:
		if battle.camera.is_position_behind(p.at): continue
		var screen: Vector2 = battle.camera.unproject_position(p.at)
		var gain: float = (battle.camera.unproject_position(p.at+battle.camera.global_basis.x)-screen).length()/battle.Profile.PPM
		var progress: float = p.age/p.life
		var size: float = p.size*(1.-.65*progress)
		draw_set_transform(screen+p.offset*gain,p.angle,Vector2.ONE*gain)
		draw_texture_rect(Art.art.muzzle.textures[0],Rect2(Vector2.ONE*(-size*.5),Vector2.ONE*size),false,Color(1,1,1,(1.-progress)*.85))
