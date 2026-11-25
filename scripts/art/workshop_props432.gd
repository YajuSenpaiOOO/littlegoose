extends Node3D

const TIN = preload("res://assets/workshop432/cookie-tin.png")
const TIN_INK = preload("res://scripts/art/workshop_tin432.gdshader")
const JOURNAL_AT := Vector3(-.60,.974,.10)
const JOURNAL_SPREAD := Vector2(.76,.449)
const PAGE_TURN:=preload("res://scripts/combat/workshop_page_turn432.gd")
const TIN_AT := Vector3(.26,.905,.082)
const LANDING := TIN_AT+Vector3(.045,.088,.075)
var room: Node3D
var pen: Node3D
var paper: Node3D
var lid: Node3D
var book: Node3D
var journal_spread: MeshInstance3D
var journal_leaf: PAGE_TURN
var flecks: Array[MeshInstance3D]=[]
var marks: Array[MeshInstance3D]=[]
var animation: Tween
var finished:=false

func build(helper: Node3D) -> void:
 room=helper
 build_tin()
 build_book()

func build_tin() -> void:
 var tin:=Node3D.new()
 tin.name="CookieTin"
 tin.position=TIN_AT
 add_child(tin)
 var stripe:=ShaderMaterial.new()
 stripe.shader=TIN_INK
 stripe.set_shader_parameter("paint",TIN)
 var lid_ink:=stripe.duplicate() as ShaderMaterial
 lid_ink.set_shader_parameter("lid",true)
 room.cylinder(tin,Vector3(0,.03,0),.299,.06,"263e69")
 var liner:=ShaderMaterial.new()
 liner.shader=preload("res://scripts/art/workshop_liner432.gdshader")
 liner.set_shader_parameter("paper",preload("res://assets/workshop432/goose-diary-pages.png"))
 room.cylinder(tin,Vector3(0,.066,0),.285,.015,"c6a87a").material_override=liner
 band(tin,.303,.012,.185,0.,stripe)
 var folds:=liner.duplicate() as ShaderMaterial
 folds.set_shader_parameter("fluted",true)
 band(tin,.282,.075,.18,.006,folds,true)
 rim(tin,Vector3(0,.018,0),.306)
 rim(tin,Vector3(0,.184,0),.306)
 lid=Node3D.new()
 lid.name="Lid"
 tin.add_child(lid)
 set_lid_open(0.)
 room.cylinder(lid,Vector3(0,-.004,0),.310,.029,"334970")
 rim(lid,Vector3(0,.014,0),.311)
 var face_mesh:=SurfaceTool.new()
 face_mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 48:
  for p in [Vector2.ZERO,Vector2.from_angle(TAU*i/48.),Vector2.from_angle(TAU*(i+1)/48.)]:
   face_mesh.set_uv(p*.5+Vector2(.5,.5))
   face_mesh.set_normal(Vector3.UP)
   face_mesh.add_vertex(Vector3(p.x*.300,.012,p.y*.300))
 room.shape(lid,face_mesh.commit(),Vector3.ZERO,lid_ink)

func set_lid_open(amount: float) -> void:
 var angle:=deg_to_rad(68.)*amount
 var open_z:=-.305-.307*cos(deg_to_rad(68.))
 lid.position=Vector3(.035*amount,lerpf(.200,.184,amount)+.307*sin(angle),open_z*amount)
 lid.rotation.x=angle

func band(parent: Node3D,radius: float,bottom: float,top: float,flute: float,material: Material,inward:=false) -> void:
 var strip:=SurfaceTool.new()
 strip.begin(Mesh.PRIMITIVE_TRIANGLES)
 var order:=[Vector2(0,0),Vector2(1,1),Vector2(1,0),Vector2(0,0),Vector2(0,1),Vector2(1,1)]
 if not inward:order.reverse()
 for i in 72:
  for corner: Vector2 in order:
   var u:=(i+corner.x)/72.
   var a:=u*TAU
   var y:=lerpf(top,bottom,corner.y)
   var r:=radius+cos(a*24.)*flute
   var normal:=Vector3(sin(a),0.,cos(a))
   strip.set_uv(Vector2(u,corner.y))
   strip.set_normal(-normal if inward else normal)
   strip.add_vertex(Vector3(normal.x*r,y,normal.z*r))
 room.shape(parent,strip.commit(),Vector3.ZERO,material)

func rim(parent: Node3D,at: Vector3,radius: float) -> void:
 var roll:=TorusMesh.new()
 roll.inner_radius=radius-.022
 roll.outer_radius=radius
 roll.rings=48
 roll.ring_segments=10
 var brass:=room.material("c69a54").duplicate() as StandardMaterial3D
 brass.metallic=.31
 brass.roughness=.49
 room.shape(parent,roll,at,brass)

func build_book() -> void:
 book=Node3D.new()
 book.name="GooseDiary"
 book.position=JOURNAL_AT
 book.rotation_degrees.y=-9.
 add_child(book)
 var spread_mesh:=PlaneMesh.new()
 spread_mesh.size=JOURNAL_SPREAD
 var spread_ink:=StandardMaterial3D.new()
 spread_ink.albedo_texture=load("res://assets/workshop432/journal-spread-scrapbook.png")
 spread_ink.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA_SCISSOR
 spread_ink.alpha_scissor_threshold=.24
 spread_ink.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
 spread_ink.disable_fog=true
 journal_spread=room.shape(self,spread_mesh,JOURNAL_AT+Vector3.UP*.076,spread_ink)
 journal_spread.rotation.y=book.rotation.y
 journal_leaf=PAGE_TURN.new()
 journal_leaf.attach(journal_spread,JOURNAL_SPREAD)
 journal_spread.hide()
 var cover: MeshInstance3D=room.box(book,Vector3.ZERO,Vector3(.65,.040,.47),"71485c")
 cover.rotation_degrees.x=13.
 var ink:=StandardMaterial3D.new()
 ink.albedo_texture=load("res://assets/workshop432/goose-diary-pages.png")
 ink.albedo_color=Color(.80,.76,.73)
 ink.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
 ink.roughness=.93
 for side in [-1.,1.]:
  var leaf:=Node3D.new()
  leaf.position=Vector3(side*.152,.037,0)
  leaf.rotation_degrees=Vector3(13.,0.,side*8.)
  book.add_child(leaf)
  room.box(leaf,Vector3.ZERO,Vector3(.302,.041,.433),"d3bc94")
  var page_mesh:=PlaneMesh.new()
  page_mesh.size=Vector2(.302,.432)
  var half:=ink.duplicate() as StandardMaterial3D
  half.uv1_scale.x=.5
  half.uv1_offset.x=0. if side<0. else .5
  room.shape(leaf,page_mesh,Vector3(0,.022,0),half)
  if side>0.:
   for i in 3:
    var line: MeshInstance3D=room.box(leaf,Vector3(-.087,.023,-.030+i*.048),Vector3(.14-i*.024,.003,.008),"927292")
    line.scale.x=.001
    marks.append(line)
 pen=Node3D.new()
 pen.position=Vector3(.19,.075,.17)
 pen.rotation_degrees=Vector3(70.,10.,-23.)
 book.add_child(pen)
 room.cylinder(pen,Vector3.UP*.077,.008,.145,"a16957")
 room.cylinder(pen,Vector3.UP*.008,.002,.029,"be9263",.009)
 var feather: MeshInstance3D=room.ellipsoid(pen,Vector3(.018,.161,0),Vector3(.077,.166,.013),"eee3c7")
 feather.rotation_degrees.z=-19.
 var glow:=room.material("ffe5a4").duplicate() as StandardMaterial3D
 glow.emission_enabled=true
 glow.emission=Color("f6b955")
 glow.emission_energy_multiplier=.52
 paper=star(self,JOURNAL_AT+Vector3(.13,.11,0),.084,glow)
 paper.hide()
 for i in 7:
  var fleck: MeshInstance3D=room.ellipsoid(self,Vector3.ZERO,Vector3.ONE*.022,"ffe5a4")
  fleck.material_override=glow
  fleck.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  fleck.hide()
  flecks.append(fleck)

func star(parent: Node3D,at: Vector3,radius: float,material: Material) -> MeshInstance3D:
 var star_mesh:=SurfaceTool.new()
 star_mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 10:
  var a:=TAU*i/10.-PI*.5
  var b:=TAU*(i+1)/10.-PI*.5
  var p:=Vector2.from_angle(a)*radius*(1. if i%2==0 else .54)
  var q:=Vector2.from_angle(b)*radius*(.54 if i%2==0 else 1.)
  for point in [Vector3(0,0,.021),Vector3(p.x,-p.y,0),Vector3(q.x,-q.y,0),
               Vector3(0,0,-.013),Vector3(q.x,-q.y,0),Vector3(p.x,-p.y,0)]:
   star_mesh.set_smooth_group(-1)
   star_mesh.add_vertex(point)
 star_mesh.generate_normals()
 return room.shape(parent,star_mesh.commit(),at,material)

func show_journal_spread(active:bool) -> void:
 journal_spread.visible=active
 book.visible=not active

func tint_journal_paper(tone:Color) -> void:
 journal_spread.material_override.albedo_color=tone
 journal_leaf.set_tone(tone)

func write_memory() -> void:
 if animation and animation.is_running():return
 var rest:=pen.transform
 finished=false
 for mark in marks:mark.scale.x=.001
 animation=create_tween()
 animation.tween_property(pen,"rotation_degrees",Vector3(-16.,0.,-22.),.19)
 for i in marks.size():
  var across:=Vector3(.065,.093-i*.011,-.046+i*.048)
  animation.tween_property(pen,"position",across,.11)
  animation.tween_property(pen,"position",across+Vector3(.126-i*.024,0,0),.22)
  animation.parallel().tween_property(marks[i],"scale:x",1.,.23)
 animation.tween_callback(func() -> void:
  finished=true
  paper.show()
  for fleck in flecks:fleck.show())
 animation.tween_method(fly,0.,1.,.97)
 animation.parallel().tween_property(pen,"transform",rest,.34)
 animation.tween_callback(finish_flight)
 animation.tween_interval(.85)
 animation.tween_callback(func() -> void:finished=false)

func fly(progress: float) -> void:
 var from:=JOURNAL_AT+Vector3(.13,.13,0)
 paper.position=from.lerp(LANDING,progress)+Vector3(0,sin(progress*PI)*.46,sin(progress*PI)*.09)
 paper.rotation=Vector3(progress*.7,progress*TAU*.76,progress*2.4)
 paper.scale=Vector3.ONE*lerpf(.67,1.,sin(progress*PI))
 for i in flecks.size():
  var delay:=clampf(progress-float(i)*.034,0.,1.)
  var wake:=from.lerp(LANDING,delay)+Vector3(0,sin(delay*PI)*.46,sin(delay*PI)*.09)
  var spin:=i*2.399963+progress*5.
  flecks[i].position=wake+Vector3(cos(spin),sin(spin),.32)*(.032+i*.012)
  flecks[i].scale=Vector3.ONE*(.012+sin(spin)*.004)

func finish_flight() -> void:
 paper.hide()
 for fleck in flecks:fleck.hide()
