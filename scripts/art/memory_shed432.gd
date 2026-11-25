extends Node3D

const PROPS = preload("res://scripts/art/workshop_props432.gd")
const PAVING = preload("res://scripts/art/workshop_paving432.gd")
const GRAPEVINE = preload("res://assets/workshop432/grapevine.png")
const TIMBER = preload("res://scripts/room/timber_frame399.gd")
var lens: Camera3D
var focus_far:=6.
var focus_blend:=0.
var dolly:=0.
var overhead:=0.
var journal_overhead:=0.
const OVERHEAD_ROOF := 1<<18
const POV_ACTOR_LAYER := 1<<19
var pov_ink: ShaderMaterial
var props: PROPS
var lantern:OmniLight3D
var lantern_glass:StandardMaterial3D
var tabletop_fill:OmniLight3D

func build(home: Node3D) -> void:
 var house: Node3D=home.house
 var room: Node3D=home.room
 var wood: StandardMaterial3D=house.wood
 var plank:=wood.duplicate() as StandardMaterial3D
 plank.albedo_color=Color("b99c7b")
 PAVING.new().build(self,home)
 var frame:=TIMBER.new()
 add_child(frame)
 var arch: Array[Vector2]=[]
 for i in 17:
  var x:=lerpf(-1.43,1.43,float(i)/16.)
  arch.append(Vector2(x,2.13+.53*(1.-pow(x/1.43,2.))))
 for x in [-1.43,1.43]:
  for z in [-.93,.76]:
   var at:=Vector3(x,1.04,z)
   house.block(self,at,Vector3(.18,2.18,.18),wood)
   house.block(self,Vector3(x,.11,z),Vector3(.25,.31,.25),house.stone).layers=OVERHEAD_ROOF
   room.collider(self,at,Vector3(.23,2.18,.23))
   house.beam(self,Vector3(x,1.71,z),Vector3(x*.77,2.30,z),.10,.12,wood)
 for z in [-.93,.76]:
  frame.beam399(arch,.13,.15,z,"PergolaArch").material_override=wood
 for i in [0,3,6,8,10,13,16]:
  var point:=arch[i]
  house.block(self,Vector3(point.x,point.y+.05,-.086),Vector3(.085,.09,1.98),plank)
 for z in [-.94,.78]:
  var vine: Sprite3D=house.card(self,GRAPEVINE,Vector3(0,1.72,z),.99,false)
  vine.rotation_degrees.x=0.
  vine.flip_h=z<0.
  vine.modulate=Color(.77,.87,.72)
  vine.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
 var canopy: Sprite3D=house.card(self,GRAPEVINE,Vector3(0,2.48,-.93),1.68,false)
 canopy.rotation_degrees.x=78.
 canopy.scale.x=.60
 canopy.modulate=Color(.73,.84,.67)
 canopy.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_DOUBLE_SIDED
 for visual in find_children("*","GeometryInstance3D",true,false):
  if visual.position.y>1. or visual.get_parent()==frame:
   visual.layers=OVERHEAD_ROOF

 var bench:=Node3D.new()
 bench.name="SortingBench"
 bench.position=Vector3(0,0,-.51)
 add_child(bench)
 for x in [-.93,.93]:
  for z in [-.28,.28]:
   house.block(bench,Vector3(x,.375,z),Vector3(.115,.86,.119),wood)
 house.block(bench,Vector3(0,.74,.29),Vector3(2.08,.13,.08),wood)
 pov_ink=ShaderMaterial.new()
 pov_ink.shader=preload("res://scripts/art/workshop_table432.gdshader")
 pov_ink.set_shader_parameter("grain",wood.albedo_texture)
 house.block(bench,Vector3(0,.852,0),Vector3(2.24,.105,.77),pov_ink)
 room.collider(bench,Vector3(0,.41,0),Vector3(2.23,.95,.76))

 props=PROPS.new()
 bench.add_child(props)
 props.build(room)

 var lamp:=Vector3(0,2.26,.05)
 room.cylinder(self,lamp+Vector3.UP*.23,.012,.24,"77553b")
 room.cylinder(self,lamp+Vector3.UP*.095,.083,.091,"77553b",.05)
 var globe: MeshInstance3D=room.cylinder(self,lamp,.065,.14,"e7bd75")
 lantern_glass=globe.material_override.duplicate() as StandardMaterial3D
 lantern_glass.emission_enabled=true
 lantern_glass.emission=Color("ffb45f")
 globe.material_override=lantern_glass
 room.cylinder(self,lamp-Vector3.UP*.079,.075,.039,"77553b")
 for corner in [Vector2(-1,-1),Vector2(1,-1),Vector2(1,1),Vector2(-1,1)]:
  var rib:=lamp+Vector3(corner.x*.046,0.,corner.y*.046)
  room.box(self,rib,Vector3(.011,.143,.011),"735135")
 lantern=OmniLight3D.new()
 lantern.name="PergolaLanternLight"
 lantern.position=lamp-Vector3.UP*.12
 lantern.light_color=Color("ffc18c")
 lantern.omni_range=3.25
 lantern.omni_attenuation=1.15
 add_child(lantern)
 tabletop_fill=OmniLight3D.new()
 tabletop_fill.name="PergolaTableBounce"
 tabletop_fill.position=Vector3(.22,1.43,-.46)
 tabletop_fill.light_color=Color("ffc29a")
 tabletop_fill.omni_range=1.62
 tabletop_fill.omni_attenuation=1.40
 add_child(tabletop_fill)
 update_lamp(1.)
 build_view()

func update_lamp(daylight:float) -> void:
 lantern.light_energy=lerpf(3.35,1.30,daylight)
 lantern_glass.emission_energy_multiplier=lerpf(2.25,.48,daylight)
 tabletop_fill.light_energy=lerpf(1.18,.16,daylight)
 pov_ink.set_shader_parameter("lamp_bounce",lerpf(.26,.045,daylight))

func worktop_tone(outdoor:Color,daylight:float) -> Color:
 return outdoor.lerp(Color(1.07,.95,.80),lerpf(.76,.36,daylight))

func journal_light_tone(outdoor: Color,daylight: float) -> Color:
 # The paper is unshaded for legibility across page turns. Match the table's
 # lantern by blending in local amber fill while retaining the time of day.
 var lamplight:=Color(1.13,1.01,.90)
 return outdoor.lerp(lamplight,lerpf(.72,.85,daylight))

func at_journal(at: Vector3) -> bool:
 return to_local(at).x<-.21

func build_view() -> void:
 lens=Camera3D.new()
 lens.fov=39.
 add_child(lens)

func update_view(delta: float,enabled: bool,source: Camera3D,assembling:=false,reading:=false) -> void:
 if not enabled and dolly<=0.:return
 if enabled and not lens.current:lens.make_current()
 dolly=move_toward(dolly,float(enabled),delta/.64)
 var ease:=smoothstep(0.,1.,dolly)
 var distance:=5.0*maxf(1.,1.60*get_viewport().get_visible_rect().size.y/get_viewport().get_visible_rect().size.x)
 var eye:=to_global(Vector3(-.92,2.56,distance))
 var framing_point:=to_global(Vector3(0,1.26,-.12))
 var frame:=Transform3D(Basis.IDENTITY,eye).looking_at(framing_point)
 overhead=move_toward(overhead,float(assembling),delta/(.78 if assembling else .55))
 journal_overhead=move_toward(journal_overhead,float(reading),delta/(.78 if reading else .55))
 var journal_blend:=smoothstep(0.,1.,journal_overhead)
 var blend:=smoothstep(0.,1.,overhead)
 var tin: Vector3=props.to_global(props.TIN_AT)
 var center:=tin+Vector3(.235,0,-.16)
 var base:=source.global_transform.interpolate_with(frame,ease)
 if blend>0.:
  var eye_top:=center+Vector3(0,1.57,.33)
  var moving_eye:=base.origin.lerp(eye_top,blend)
  var base_focus:=base.origin-base.basis.z*base.origin.distance_to(framing_point)
  # Keep the table in shot as the optical axis turns down toward the tin.
  var focus:=base_focus.lerp(center,blend)
  base=Transform3D(Basis.IDENTITY,moving_eye).looking_at(focus,Vector3.UP.lerp(Vector3.FORWARD,blend))
 if journal_blend>0.:
  var spread:MeshInstance3D=props.journal_spread
  var focus:=spread.global_position+spread.global_basis.x*.042+spread.global_basis.z*.029
  var viewport:=get_viewport().get_visible_rect().size
  var aspect:=viewport.x/viewport.y
  var extent:=maxf(props.JOURNAL_SPREAD.y/.77,props.JOURNAL_SPREAD.x/(aspect*.79))
  var height:=extent/(2.*tan(deg_to_rad(39.)*.5))
  var reading_eye:=focus+Vector3.UP*height
  var start_focus:=base.origin-base.basis.z*base.origin.distance_to(framing_point)
  var up:=Vector3.UP.lerp(-spread.global_basis.z,journal_blend)
  base=Transform3D(Basis.IDENTITY,base.origin.lerp(reading_eye,journal_blend)).looking_at(start_focus.lerp(focus,journal_blend),up)
 props.show_journal_spread(journal_blend>.43)
 blend=maxf(blend,journal_blend)
 lens.global_transform=base
 lens.fov=lerpf(lerpf(source.fov,39.,ease),39.,blend)
 lens.set_cull_mask_value(19,blend<.56)
 lens.set_cull_mask_value(20,blend<.64)
 focus_blend=ease*(1.-smoothstep(.06,.42,blend))
 focus_far=distance+.86
 if not enabled and dolly<=0. and lens.current:source.make_current()

func journal_paper_rect() -> Rect2:
 var half:Vector2=props.JOURNAL_SPREAD*.5
 var spread:MeshInstance3D=props.journal_spread
 var first:=lens.unproject_position(spread.to_global(Vector3(-half.x,0.,-half.y)))
 var last:=lens.unproject_position(spread.to_global(Vector3(half.x,0.,half.y)))
 return Rect2(first,last-first).abs()


