extends "res://scripts/art/bat_faces223.gd"
var fall224 := false
var fall_age224 := 0.
var down224: Texture2D
var down_layout224: Dictionary
var start_at224 := Vector2.ZERO
var ground_at224 := Vector2.ZERO
var bat_start224: Array[Vector3]=[]
var contact_scale224 := Vector3.ONE
func _ready() -> void:
 super._ready();name="SisterSoftLanding224"
 contact_scale224=contact.scale
 down224=load("res://assets/sister224/collapsed_B.png")
 down_layout224=JSON.parse_string(FileAccess.get_file_as_string("res://assets/sister224/layout.json"))
func reset_fall224() -> void:
 fall224=false;fall_age224=0.;bat_start224.clear()
 if is_instance_valid(contact):contact.scale=contact_scale224
 if ready222:frame222=-2;pose222(-1)
func start_fall224() -> void:
 fall224=true;fall_age224=0.;start_at224=rig_at
 # Extended boots move toward the foreground as she slides off the low sling.
 ground_at224=start_at224+Vector2(.45,.9)
 bat_start224.clear()
 for bat in bats:bat_start224.append(bat.global_position)
func place220(at: Vector2,height: float,delta: float) -> void:
 super.place220(at,height,delta)
 if fall224:
  fall_age224+=delta
  var sign224=1. if lost220==0 else -1.
  swing206=sign224*.24*smoothstep(0.,.28,fall_age224)
func _process(delta: float) -> void:
 super._process(delta)
 if not fall224 or bat_start224.size()!=2:return
 var t=fall_age224;var camera_basis: Basis=world.camera.global_basis
 var sign224=1. if lost220==0 else -1.
 var tilt=sign224*.24*smoothstep(0.,.28,t)
 var fold=lerpf(1.,.18,smoothstep(.28,.78,t))
 hammock.global_basis=(Basis(camera_basis.z,tilt)*camera_basis).scaled_local(Vector3(1.,fold,1.))
 hammock.global_position=ground(start_at224)+Vector3.UP*lerpf(.20,.04,smoothstep(.28,.78,t))
 var slide=smoothstep(.28,.75,t)
 var foot=ground(start_at224).lerp(ground(ground_at224),slide)
 if t<.65:
  set_card(seated,foot+Vector3.UP*lerpf(.18,.02,slide),Vector2.ZERO)
  seated.global_basis=Basis(camera_basis.z,tilt*.65)*camera_basis
 else:
  var anchor=Vector2(down_layout224.anchor[0],down_layout224.anchor[1])
  seated.texture=down224;seated.pixel_size=original_pixel222;seated.set_meta("anchor205",anchor)
  var size=down224.get_size();seated.offset=Vector2(size.x*.5-anchor.x,anchor.y-size.y*.5)
  (seated.material_override as ShaderMaterial).set_shader_parameter("paint",down224)
  set_card(seated,foot+Vector3.UP*.015,Vector2.ZERO)
  var breath=sin(elapsed*TAU/3.4)*.006
  var settle=1.-sin(clampf((t-.65)/.3,0.,1.)*PI)*.025 if t<.95 else 1.
  seated.scale=Vector3(1.-breath*.5,(1.+breath)*settle,1.)
 contact.global_position=ground(ground_at224)+Vector3.UP*.025
 contact.scale=Vector3(1.3,1.,1.15);contact_ink.set_shader_parameter("strength",.16)
 for i in 2:
  var bat=bats[i]
  var uv=Vector2(.089,.091) if i==0 else Vector2(.922,.091)
  var hook=pixel_point(hammock,textures.hammock.get_size()*uv)
  if i==lost220:
   var rest=ground(ground_at224+Vector2(-.65 if i==0 else .65,.10))+Vector3.UP*.20
   bat.global_position=bat_start224[i].lerp(rest,smoothstep(.18,.85,t))
   bat.global_basis=Basis(camera_basis.z,(-1. if i==0 else 1.)*PI*.5*smoothstep(.18,.85,t))*camera_basis
  elif t<.75:
   bat.global_position=hook;bat.global_basis=camera_basis
  else:
   var hover=ground(ground_at224+Vector2(.9,.0))+Vector3.UP*(1.0+sin(elapsed*5.)*.035)
   hover+=camera_basis.x*sin(elapsed*2.2)*.06
   bat.global_position=hook.lerp(hover,smoothstep(.75,1.3,t));bat.global_basis=camera_basis
  # Detaching changes both visual position and its coherent foot-depth proxy.
  var ink: ShaderMaterial=bat.material_override
  ink.set_shader_parameter("foot199",Vector3(bat.global_position.x,world.floor_height(Vector2(bat.global_position.x,bat.global_position.z)),bat.global_position.z))
