extends "res://scripts/art/paper_stage330.gd"

var sweep_mesh331: MeshInstance3D
var finale_burst331 := false

func _ready() -> void:
 super._ready()
 sweep_mesh331 = make_ring327()

func reset_battle314() -> void:
 super.reset_battle314()
 finale_burst331 = false
 for cannon in cannons326: cannon.rotation.z = 0.
 if is_instance_valid(sweep_mesh331): sweep_mesh331.hide()

func shell331(at: Vector3, heading: Vector2) -> Sprite3D:
 var sprite := projectile330(false,at)
 sprite.pixel_size *= .30/.78
 orient_shell331(sprite,at,heading)
 return sprite

func orient_shell331(sprite: Sprite3D, at: Vector3, heading: Vector2) -> void:
 var from: Vector2 = battle.camera.unproject_position(at)
 var to: Vector2 = battle.camera.unproject_position(at+Vector3(heading.x,0.,heading.y))
 sprite.rotation.z = -(to-from).angle()+PI*.5

func segment331(mesh: ImmediateMesh, a: Vector2, b: Vector2, width: float, color: Color) -> void:
 var side := (b-a).orthogonal().normalized()*width*.5
 for point in [a-side,a+side,b-side,b-side,a+side,b+side]:
  mesh.surface_set_color(color)
  mesh.surface_add_vertex(sweep_mesh331.to_local(Vector3(point.x,battle.floor_height(point)+.045,point.y)))

func sweep_cue331(stream: Dictionary) -> void:
 if not is_instance_valid(sweep_mesh331): return
 var mesh := sweep_mesh331.mesh as ImmediateMesh
 mesh.clear_surfaces()
 sweep_mesh331.visible = not stream.is_empty()
 if stream.is_empty(): return
 var foot := Vector2(stream.at.x,stream.at.z)
 var aim: Vector2 = stream.aim
 var side: float = stream.side
 var charging: bool = stream.age<0.
 mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
 if charging:
  for angle in [-.48,.48]:
   var edge := aim.rotated(angle)
   segment331(mesh,foot+edge*.9,foot+edge*8.,.045,Color(1.,.77,.35,.24))
 var t := clampf((float(stream.age)+.8)/.8,0.,1.) if charging else clampf(float(stream.fired)/23.,0.,1.)
 var angle := lerpf(-.48,.48,t)*side
 var heading := aim.rotated(angle)
 segment331(mesh,foot+heading*.8,foot+heading*2.4,.09,Color(1.,.8,.38,.7))
 # Moving chevron communicates the sweep direction during the windup.
 var tip := foot+heading*2.4
 segment331(mesh,tip,tip-heading*.35+heading.orthogonal()*.22,.08,Color(1.,.8,.38,.7))
 segment331(mesh,tip,tip-heading*.35-heading.orthogonal()*.22,.08,Color(1.,.8,.38,.7))
 mesh.surface_end()

func repair_pose331(index: int, intact: bool) -> void:
 var cannon := cannons326[index]
 cannon.texture = cannon_frames326[0 if intact else 1]
 cannon.offset = Vector2(443.5-(454. if intact else 410.),825.-443.5)
 cannon.scale = Vector3.ONE
 cannon.rotation.z = 0.

func enable_cannons326(enabled: bool) -> void:
 super.enable_cannons326(enabled)
 if not enabled and battle.get("finale_cannons331") == true:
  for cannon in cannons326: cannon.show()

func _process(delta: float) -> void:
 super._process(delta)
 if battle.combat_paused or battle.fall314>=0.: return
 for i in cannons326.size():
  var left: float = battle.repair_left331[i]
  if left<=0.: continue
  var warming := left<1.
  repair_pose331(i,warming)
  cannons326[i].scale = Vector3.ONE*(lerpf(.7,1.,1.-left) if warming else .94)
  cannons326[i].rotation.z = sin(Time.get_ticks_msec()*.045)*.025 if warming else 0.
  cannons326[i].material_override.albedo_color = Color(.8,.7,.62) if warming else Color(.48,.43,.43)

func collapse314(elapsed: float) -> void:
 super.collapse314(elapsed)
 if not battle.finale_cannons331: return
 for cannon in cannons326:
  cannon.show()
  cannon.rotation.z = sin(elapsed*35.)*.055 if elapsed<1.12 else 0.
 if elapsed>=1.12 and not finale_burst331:
  finale_burst331 = true
  for i in cannons326.size():
   repair_pose331(i,false)
   var at := muzzle330(i)
   battle.structure_contact326(at,Vector3.UP,true)
   var burst := make_blast327(Vector2(at.x,at.z),1.8)
   get_tree().create_timer(.55).timeout.connect(burst.root.queue_free)
