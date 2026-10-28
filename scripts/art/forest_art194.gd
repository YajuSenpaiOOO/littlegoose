extends "res://scripts/art/forest_art193.gd"
const DRESS194=preload("res://scripts/world/forest_dressing181.gd")
var nook194: Sprite3D
var cat194: Sprite3D
var cat_seat194 := Vector3.ZERO
var plant_records194: Array[Dictionary]=[]
var trunk_bodies194: Array[StaticBody3D]=[]
var pop_at194 := Vector2(6.5,4.4)
var pop_board194: Sprite3D
var pop_spider194: Sprite3D
var pop_words194: Label3D
var pop_base194 := Vector3.ZERO
var pop_age194 := -1.
var pop_cooldown194 := 0.
var pop_armed194 := true
var pop_count194 := 0
func silhouette182(visual: Sprite3D) -> void:
 # Small handwork props already have a fitted contact shadow. Do not stack
 # another full silhouette over it, or add a cylindrical caster later.
 if visual.texture==preload("res://assets/forest188/yarn_craft_corner_pixel.png"): return
 super.silhouette182(visual)
func _ready() -> void:
 super._ready()
 hammock_cat189.hide()
 for rope in ropes193: rope.queue_free()
 ropes193.clear()
 make_nook194();plant_borders194();make_pop194()
func ground194(p: Vector2) -> Vector3:
 return Vector3(p.x,world.floor_height(PLAN.CENTER+p),p.y)
func lane_distance194(p: Vector2) -> float:
 var distance := PLAN.path_sample(p).x
 for i in range(1,DRESS194.TRAIL.size()):
  distance=minf(distance,Geometry2D.get_closest_point_to_segment(p,DRESS194.TRAIL[i-1],DRESS194.TRAIL[i]).distance_to(p))
 return distance
func safe194(p: Vector2) -> bool:
 var at := PLAN.CENTER+p;var y: float=world.floor_height(at)
 if y>PLAN.TOP+.12 or lane_distance194(p)<1.55 or PLAN.in_flight(p): return false
 for offset in [Vector2(.3,0),Vector2(-.3,0),Vector2(0,.3),Vector2(0,-.3)]:
  if absf(world.floor_height(at+offset)-y)>.16: return false
 var dx: float=(world.floor_height(at+Vector2(.2,0))-world.floor_height(at-Vector2(.2,0)))/.4
 var dz: float=(world.floor_height(at+Vector2(0,.2))-world.floor_height(at-Vector2(0,.2)))/.4
 return Vector3(-dx,1.,-dz).normalized().y>.92
func make_nook194() -> void:
 var p := Vector2(7.6,-5.)
 nook194=cutout181(preload("res://assets/forest194/twin_tree_hammock.png"),ground194(p)-Vector3.UP*.025,4.8,Vector2(.54,1.),true)
 nook194.name="TwinTreeHammock194";nook194.modulate=Color(.78,.85,.91)
 # Feet stay on the lowland floor. No raised stone disk or invisible trunk caster.
 for offset in [-1.25,1.25]:
  var foot := p+Vector2(offset,0.)
  var shape := CylinderShape3D.new();shape.radius=.26;shape.height=1.5
  var trunk := body(shape,ground194(foot)+Vector3.UP*.75);trunk.name="HammockPhysicalTrunk194";trunk_bodies194.append(trunk)
  contact182(foot,1.25,.65)
 var seat: Vector3=painted_point193(nook194,Vector2(.565,.765))+world.camera.global_basis.z*.045
 cat194=cutout181(preload("res://assets/forest194/sleepy_cat.png"),to_local(seat),1.12,Vector2(.50,.97),true)
 cat194.name="SleepingPlushCat194";cat194.modulate=Color(.60,.60,.60);cat_seat194=cat194.position
 var hook: Vector3=painted_point193(nook194,Vector2(.81,.53))+world.camera.global_basis.z*.08
 var lantern := cutout181(preload("res://assets/forest184/hanging_lantern.png"),to_local(hook),.63,Vector2(.5,0.))
 lantern.name="HammockNookLantern194"
func reactive194(texture: Texture2D,p: Vector2,width: float,tint: Color) -> void:
 if not safe194(p): return
 var plant := cutout181(texture,ground194(p)-Vector3.UP*.02,width,Vector2(.5,1.),true)
 plant.name="LayeredBorderPlant194";plant.modulate=tint
 var bounds := opaque_bounds181(texture)
 var material := ShaderMaterial.new();material.shader=preload("res://scripts/art/forest_flower189.gdshader")
 material.set_shader_parameter("paint",texture)
 material.set_shader_parameter("flower_y",Vector2(float(bounds.position.y)/texture.get_height(),float(bounds.end.y)/texture.get_height()))
 plant.material_override=material;plant.extra_cull_margin=.4
 flowers189.append({"visual":plant,"push":Vector3.ZERO})
 plant_records194.append({"node":plant,"local":p})
func plant_borders194() -> void:
 var atlas: Array=world.forest87._textures87("woodland_plants87")
 var anchors := [Vector2(19.,6.4),Vector2(18.,-.2),Vector2(15.5,3.8),Vector2(14.,10.8),Vector2(10.3,11.),Vector2(7.,9.2),Vector2(6.8,3.5),Vector2(4.3,6.5),Vector2(1.,1.3),Vector2(3.8,-1.8),Vector2(7.,-8.2),Vector2(10.5,-6.2)]
 for index in anchors.size():
  var anchor: Vector2=anchors[index]
  for i in 5:
   var angle := float(i)*2.399+index*.4
   var p := anchor+Vector2(cos(angle),sin(angle))*(.35+float(i%3)*.28)
   var texture: Texture2D=preload("res://assets/forest188/lilac_ground_clump_pixel.png") if i==4 else atlas[(i+index)%3]
   reactive194(texture,p,.68+float((i+index)%4)*.21,Color(.63,.69,.80) if i<2 else Color(.76,.75,.86))
func make_pop194() -> void:
 pop_base194=ground194(pop_at194)
 var plants: Array=world.forest87._textures87("woodland_plants87")
 reactive194(plants[0],pop_at194+Vector2(.1,.1),1.6,Color(.62,.69,.75))
 pop_board194=cutout181(preload("res://assets/forest181/ghost_kitten.png"),pop_base194,.82,Vector2(.5,1.))
 pop_board194.name="ShyGhostPuppet194";pop_board194.hide()
 pop_spider194=cutout181(preload("res://assets/spider170/idle.png"),pop_base194,.58,Vector2(.5,1.),true)
 pop_spider194.name="PuppetOperator194";pop_spider194.hide()
 pop_words194=Label3D.new();pop_words194.text="呜喵！";pop_words194.font_size=30;pop_words194.pixel_size=.006
 pop_words194.billboard=BaseMaterial3D.BILLBOARD_ENABLED;pop_words194.modulate=Color("f3dfdc");pop_words194.outline_modulate=Color("44334e");pop_words194.outline_size=7
 pop_words194.position=pop_base194+Vector3.UP*1.65;add_child(pop_words194);pop_words194.hide()
func trigger_pop194() -> bool:
 if not pop_armed194 or pop_cooldown194>0. or pop_age194>=0.: return false
 pop_age194=0.;pop_armed194=false;pop_cooldown194=18.;pop_count194+=1;return true
func update_pop194(delta: float) -> void:
 pop_cooldown194=maxf(0.,pop_cooldown194-delta)
 var distance: float=Vector2(world.hero.position.x,world.hero.position.z).distance_to(PLAN.CENTER+pop_at194)
 if distance>5. and pop_cooldown194<=0.: pop_armed194=true
 if distance<2.5 and world.wave_state!="fighting": trigger_pop194()
 if pop_age194<0.: return
 pop_age194+=delta
 var t := pop_age194
 pop_board194.visible=t>.60 and t<2.65
 pop_spider194.visible=t>1.55 and t<3.3
 pop_words194.visible=t>.97 and t<1.85
 var rise := smoothstep(.60,.95,t)*(1.-smoothstep(2.05,2.65,t))
 pop_board194.position=pop_base194+Vector3.UP*(-.25+rise*.95)-world.camera.global_basis.z*.035
 pop_board194.rotation.z=smoothstep(1.5,2.,t)*.24
 pop_spider194.position=pop_base194-world.camera.global_basis.x*.45+world.camera.global_basis.z*.14+Vector3.UP*(absf(sin((t-1.55)*8.))*.045)
 if t>3.35:
  pop_age194=-1.;pop_board194.hide();pop_spider194.hide();pop_words194.hide()
func _process(delta: float) -> void:
 super._process(delta)
 if is_instance_valid(cat194):
  cat194.position=cat_seat194+world.camera.global_basis.x*(sin(world.clock*1.25)*.012)+Vector3.UP*sin(world.clock*2.5)*.006
  cat194.rotation.z=sin(world.clock*1.25)*.018
 if is_instance_valid(pop_board194): update_pop194(delta)
