extends "res://scripts/art/paper_stage332.gd"

var homes334: Array[Vector3] = []
var courier334: Sprite3D
var parcel334: Sprite3D
var rope334: MeshInstance3D

func _ready() -> void:
 super._ready()
 for cannon in cannons326: homes334.append(cannon.position)
 courier334 = handler313.duplicate() as Sprite3D
 courier334.material_override = handler313.material_override.duplicate()
 add_child(courier334)
 courier334.rotation = Vector3.ZERO
 courier334.hide()
 parcel334 = make_shell326(Vector3.ZERO)
 parcel334.hide()
 rope334 = make_ring327()
 rope334.hide()

func reset_battle314() -> void:
 clear_rebuild334()
 super.reset_battle314()

func clear_rebuild334() -> void:
 for i in homes334.size():
  cannons326[i].position = homes334[i]
  cannons326[i].scale = Vector3.ONE
  cannons326[i].rotation.z = 0.
 if is_instance_valid(courier334): courier334.hide()
 if is_instance_valid(parcel334): parcel334.hide()
 if is_instance_valid(rope334): rope334.hide()

func _process(delta: float) -> void:
 super._process(delta)
 if battle.combat_paused or battle.fall314>=0.: return
 for i in homes334.size():
  if battle.repair_left331[i]>0.:
   repair_pose331(i,false)
   cannons326[i].position = homes334[i]
   cannons326[i].visible = true
 if battle.rebuild_index334>=0:
  sample_rebuild334(battle.rebuild_index334,battle.rebuild_age334)

func sample_rebuild334(index: int, t: float) -> void:
 var cannon := cannons326[index]
 var home := homes334[index]
 var catch := home+cannon.basis*Vector3(0.,605.*cannon.pixel_size,0.)+Vector3.UP*.65
 var high := home+Vector3.UP*6.5
 courier334.show()
 parcel334.hide()
 var attachment := home+Vector3.UP*1.15
 var frame: Dictionary = handler_drift313[int(t/.22)%handler_drift313.size()]
 courier334.texture = frame.texture
 courier334.material_override.albedo_texture = frame.texture
 courier334.pixel_size = frame.pixel_size*.8
 var size := courier334.texture.get_size()
 courier334.offset = Vector2(size.x*.5-frame.foot[0],frame.foot[1]-size.y*.5)
 cannon.visible = t<1.9 or t>=4.6
 if t<.9:
  repair_pose331(index,false)
  courier334.position = high.lerp(catch,smoothstep(0.,.9,t))
 elif t<1.9:
  repair_pose331(index,false)
  var lift := smoothstep(.9,1.9,t)*5.5
  cannon.position = home+Vector3.UP*lift
  attachment = cannon.position+Vector3.UP*1.15
  courier334.position = catch+Vector3.UP*lift
 elif t<3.5:
  if reaction_left313<=0.: director_pose313(0 if t<2.4 else (1 if t<2.9 else 2))
  var support := girl.transform*Vector3(0.,125.*visual.pixel_size,.29)+Vector3(1.1,1.7,.1)
  courier334.visible = t>=2.5
  courier334.position = (support+Vector3.UP*5.).lerp(support,smoothstep(2.5,3.5,t))
 elif t<4.6:
  if reaction_left313<=0.: director_pose313(3)
  var hand := girl.transform*Vector3(0.,(297.-172.)*visual.pixel_size,.29)
  var catcher := hand+Vector3(1.1,1.7,.1)
  courier334.position = catcher
  parcel334.show()
  var f := smoothstep(3.5,4.3,t)
  parcel334.position = hand.lerp(catcher-Vector3.UP*.3,f)+Vector3.UP*sin(PI*f)*.4
  attachment = parcel334.position
 else:
  repair_pose331(index,true)
  cannon.material_override.albedo_color = Color(.7,.7,.7)
  var p := smoothstep(4.6,6.65,t)
  var hand := girl.position+Vector3(1.1,1.5,.2)
  cannon.position = hand.lerp(home,p)+Vector3.UP*sin(PI*p)*.7
  cannon.scale = Vector3.ONE*lerpf(.25,1.,smoothstep(4.6,5.1,t))
  attachment = cannon.position+Vector3.UP*(1.15*cannon.scale.y)
  courier334.position = attachment+Vector3.UP*.65
  if t>=6.65:
   cannon.position = home
   courier334.position += Vector3.UP*smoothstep(6.65,7.,t)*5.
 if (t>=.9 and t<1.9) or (t>=4.6 and t<6.65):
  attachment = cannon.transform*Vector3(0.,605.*cannon.pixel_size,0.)
  courier334.position = attachment+Vector3.UP*.65
 courier334.rotation.z = sin(t*4.)*.06
 # Rope follows the displayed cannon's top and the courier's animated foot.
 rope334.visible = courier334.visible and ((t>=.9 and t<1.9) or (t>=4.3 and t<6.65))
 var mesh := rope334.mesh as ImmediateMesh
 mesh.clear_surfaces()
 if rope334.visible:
  mesh.surface_begin(Mesh.PRIMITIVE_LINES)
  mesh.surface_set_color(Color(.9,.8,.6))
  mesh.surface_add_vertex(attachment)
  mesh.surface_add_vertex(courier334.position)
  mesh.surface_end()
 # Missing / airborne scenery has no invisible blocking volume. On return,
 # existing sync waits for the hero to leave the footprint before solidifying.
 sync_scenery322()
