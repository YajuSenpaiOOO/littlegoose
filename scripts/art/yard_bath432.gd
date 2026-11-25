extends Node3D

const YARD = preload("res://scripts/world/yard_layout432.gd")
const FIELDSTONE=preload("res://assets/workshop432/pergola-fieldstone.png")
const SURFACES=preload("res://assets/bath432/surface-atlas.png")
const TOWELS=preload("res://assets/bath432/wall-towels.png")
const RACK_FINISHES=preload("res://assets/bath432/rack-atlas.png")
const VIEW_FOOTPRINT := Rect2(-1.625,-1.30,3.25,3.35)
const VIEW_ENTER_MARGIN := .95
const VIEW_EXIT_MARGIN := 1.48

var house:Node3D
var room:Node3D
var wood:Material
var roof_finish:StandardMaterial3D
var basin_finish:StandardMaterial3D
var plaster_finish:ShaderMaterial
var brick_finish:ShaderMaterial
var well:Node3D
var pendant:SpotLight3D
var pendant_glass:StandardMaterial3D
var bath_lamp_fill:OmniLight3D
var steam:MeshInstance3D
var steam_density:=0.
var lens:Camera3D
var view_amount:=0.
var view_engaged:=false
var view_dwell:=0.
var closeup_amount:=0.
var curtain_material:ShaderMaterial
var front_curtain_material:ShaderMaterial
var peek_amount:=0.:
 set(value):
  peek_amount=value
  front_curtain_material.set_shader_parameter("peek",value)
var curtain_ties:Array[MeshInstance3D]=[]
var curtain_motion:Tween
var curtain_closed:=false
var curtain_amount:=0.:
 set(value):
  curtain_amount=value
  curtain_material.set_shader_parameter("drawn",value)
  front_curtain_material.set_shader_parameter("drawn",value)
  for tie in curtain_ties:tie.visible=value<.10

func build(home:Node3D) -> void:
 house=home.house
 room=home.room
 wood=house.wood
 build_finishes()
 build_shelter()
 build_lamp()
 build_steam()
 build_rack()
 build_well(home.world)
 lens=Camera3D.new()
 lens.name="BathExteriorCamera"
 lens.set_cull_mask_value(20,false)
 add_child(lens)
 for at:Vector2 in YARD.BATH_PATH:
  var world_at:=Vector3(at.x,home.world.open_ground432(at)+.014,at.y)
  var local:=to_local(world_at)
  var stone:MeshInstance3D=room.cylinder(self,local,.24,.038,"a99b80")
  stone.scale.z=.73

func build_finishes() -> void:
 var atlas:=SURFACES.get_image()
 var half:=atlas.get_size()/2
 var swatches:Array[ImageTexture]=[]
 for cell in [Vector2i.ZERO,Vector2i(1,0),Vector2i(0,1),Vector2i.ONE]:
  var inset:=Rect2i(cell*half+Vector2i(5,5),half-Vector2i(10,10))
  if cell==Vector2i(0,1):
   # Start and end the repeat at overlaps in the painted tile pattern.
   inset.position.y=half.y+roundi(half.y*.24)
   inset.size.y=roundi(half.y*.67)
  var swatch:=atlas.get_region(inset)
  swatch.generate_mipmaps()
  swatches.append(ImageTexture.create_from_image(swatch))
 plaster_finish=wall_finish(swatches[0],Vector2(.45,.58),Color(.95,.89,.80))
 brick_finish=wall_finish(swatches[1],Vector2(1.65,1.90),Color(.91,.90,.87))
 plaster_finish.set_shader_parameter("exposed_bricks",swatches[1])
 plaster_finish.set_shader_parameter("has_exposed_bricks",true)
 roof_finish=StandardMaterial3D.new()
 roof_finish.albedo_texture=swatches[2]
 roof_finish.albedo_color=Color(.86,.87,.89)
 roof_finish.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
 roof_finish.roughness=.90
 basin_finish=StandardMaterial3D.new()
 basin_finish.albedo_texture=swatches[3]
 basin_finish.texture_filter=BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
 basin_finish.roughness=.46
 basin_finish.cull_mode=BaseMaterial3D.CULL_DISABLED

func wall_finish(texture:Texture2D,repeats:Vector2,tint:Color) -> ShaderMaterial:
 var finish:=ShaderMaterial.new()
 finish.shader=preload("res://scripts/art/bath_wall432.gdshader")
 finish.set_shader_parameter("finish",texture)
 finish.set_shader_parameter("repeats",repeats)
 finish.set_shader_parameter("tint",Vector3(tint.r,tint.g,tint.b))
 return finish

func build_shelter() -> void:
 var size:=YARD.BATH_PAD.size
 house.block(self,Vector3(0,-.10,0),Vector3(size.x,.23,size.y),house.stone)
 var slab:=PlaneMesh.new()
 slab.size=size
 var stone:=StandardMaterial3D.new()
 stone.albedo_texture=FIELDSTONE
 stone.albedo_color=Color(.84,.82,.78)
 stone.roughness=.95
 room.shape(self,slab,Vector3.UP*.019,stone)
 room.collider(self,Vector3(0,-.085,0),Vector3(size.x,.20,size.y))
 for x in [-1.50,1.50]:
  for z in [-1.13,1.12]:
   var height:=2.43 if z<0. else 2.12
   var post:=Vector3(x,height*.5,z)
   house.block(self,post,Vector3(.17,height,.17),wood)
   house.block(self,Vector3(x,.10,z),Vector3(.25,.20,.25),house.stone)
   room.collider(self,post,Vector3(.21,height,.21))
 for z in [-1.14,1.13]:
  var height:=2.38 if z<0. else 2.10
  house.block(self,Vector3(0,height,z),Vector3(3.20,.15,.18),wood)
 var back:=Vector3(0,1.,-1.18)
 house.block(self,back,Vector3(2.98,2.00,.13),plaster_finish)
 room.collider(self,back,Vector3(2.98,2.00,.14))
 var side:=Vector3(1.51,.97,-.03)
 house.block(self,side,Vector3(.13,1.94,2.25),plaster_finish)
 room.collider(self,side,Vector3(.14,1.94,2.25))
 house.block(self,Vector3(0,.16,-1.09),Vector3(2.96,.30,.035),brick_finish)
 house.block(self,Vector3(1.42,.16,-.03),Vector3(.035,.30,2.24),brick_finish)
 var towels:Sprite3D=house.card(self,TOWELS,Vector3(-.03,.98,-1.067),.66,false)
 towels.name="WallTowels"
 towels.rotation_degrees.x=0.
 for i in 19:
  house.block(self,Vector3(-1.41+i*.156,2.17,-1.17),Vector3(.045,.32,.066),wood)
 var roof_base:MeshInstance3D=house.block(self,Vector3(0,2.32,0),Vector3(3.54,.095,2.97),wood)
 roof_base.rotation.x=.126
 roof_tiles(self,Vector3(0,2.372,0),Vector2(3.53,2.97),13).rotation.x=.126
 house.block(self,Vector3(0,2.00,1.08),Vector3(2.92,.034,.034),room.material("97836b"))
 build_curtains()

func roof_tiles(parent:Node3D,at:Vector3,size:Vector2,courses:int) -> MeshInstance3D:
 var surface:=SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 var segments:=courses*8
 for i in segments:
  for corner:Vector2 in [Vector2.ZERO,Vector2.RIGHT,Vector2.ONE,Vector2.ZERO,Vector2.ONE,Vector2.DOWN]:
   var u:float=(i+corner.x)/segments
   var height:float=.011+.055*pow(sin(fposmod(u*courses,1.)*PI),1.4)
   surface.set_uv(Vector2(u*courses/5.,corner.y*size.y/1.44))
   surface.add_vertex(Vector3((u-.5)*size.x,height,(corner.y-.5)*size.y))
 surface.generate_normals()
 var tiles:MeshInstance3D=room.shape(parent,surface.commit(),at,roof_finish)
 tiles.name="PaintedClayTiles"
 return tiles

func build_lamp() -> void:
 var hood:=Vector3(-.42,1.92,.04)
 room.cylinder(self,hood+Vector3.UP*.23,.016,.35,"65473a")
 room.cylinder(self,hood,.191,.14,"956048",.074)
 var bulb:MeshInstance3D=room.cylinder(self,hood-Vector3.UP*.07,.113,.07,"ffe1a9",.085)
 pendant_glass=bulb.material_override.duplicate() as StandardMaterial3D
 pendant_glass.emission_enabled=true
 pendant_glass.emission=Color("ffad60")
 bulb.material_override=pendant_glass
 pendant=SpotLight3D.new()
 pendant.name="BathPendantLight"
 pendant.position=hood-Vector3.UP*.116
 pendant.rotation.x=-PI*.5
 pendant.light_color=Color("ffb36e")
 pendant.spot_range=2.5
 pendant.spot_angle=51.
 pendant.spot_attenuation=1.05
 pendant.spot_angle_attenuation=.85
 pendant.shadow_enabled=false
 add_child(pendant)
 bath_lamp_fill=OmniLight3D.new()
 bath_lamp_fill.name="LampBounce"
 bath_lamp_fill.position=Vector3(-.24,1.36,-.16)
 bath_lamp_fill.light_color=Color("ffac67")
 bath_lamp_fill.omni_range=2.62
 bath_lamp_fill.omni_attenuation=1.25
 add_child(bath_lamp_fill)
 update_lamp(1.)

func update_lamp(daylight:float) -> void:
 pendant.light_energy=lerpf(4.2,1.15,daylight)
 bath_lamp_fill.light_energy=lerpf(1.32,.12,daylight)
 pendant_glass.emission_energy_multiplier=lerpf(2.45,.54,daylight)

func build_steam() -> void:
 var mesh:=QuadMesh.new()
 mesh.size=Vector2(1.38,1.38)
 var ink:=ShaderMaterial.new()
 ink.shader=preload("res://scripts/art/bath_steam432.gdshader")
 steam=room.shape(self,mesh,Vector3(.07,.92,-.15),ink)
 steam.name="BathSteam"
 steam.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 steam.hide()

func set_steam(density:float) -> void:
 if is_equal_approx(density,steam_density):return
 steam_density=density
 steam.visible=density>.025
 steam.material_override.set_shader_parameter("density",density)

func build_curtains() -> void:
 var gingham:=Shader.new()
 gingham.code="""
shader_type spatial;
render_mode cull_disabled;
uniform float drawn = 0.0;
uniform float peek = 0.0;
void vertex() {
 float side = sign(VERTEX.x);
 VERTEX.x = mix(VERTEX.x, side * (1.46 - 1.49 * UV.x), drawn);
 float cloth_lag = sin(drawn * PI) * UV.x * UV.y;
 VERTEX.x += side * 0.10 * cloth_lag;
 VERTEX.z += side * 0.018 * drawn + 0.055 * cloth_lag;
 // Let the two hems overlap below the face, hiding the portrait's lower edge.
 float lower_fold = 1.0 - smoothstep(0.21, 0.405, UV.y);
 float opening = (smoothstep(0.0, 0.22, UV.y) * 0.79 + 0.21) * lower_fold;
 float pull = peek * pow(UV.x, 3.2) * opening;
 VERTEX.x += side * (side < 0.0 ? 0.31 : 0.66) * pull;
 VERTEX.z += 0.047 * pull;
 NORMAL.x *= mix(1.0, 0.24, drawn);
 NORMAL = normalize(NORMAL);
}
void fragment() {
 vec2 threads = UV * vec2(6.0, 10.0);
 vec2 edge = max(fwidth(threads), vec2(0.001));
 vec2 bands = smoothstep(vec2(0.5) - edge, vec2(0.5) + edge, fract(threads));
 vec3 fabric = mix(vec3(0.85, 0.80, 0.68), vec3(0.29, 0.42, 0.54), 0.34 * (bands.x + bands.y));
 float fold = cos(UV.x * TAU * 3.0) * 0.075;
 float hem = max(smoothstep(0.977, 0.987, UV.x), smoothstep(0.971, 0.979, UV.y));
 float stitch = (1.0 - smoothstep(0.002, 0.007, abs(UV.x - 0.970))) *
                 smoothstep(0.16, 0.38, fract(UV.y * 94.0));
 ALBEDO = fabric * (1.0 + fold - 0.18 * hem) + vec3(0.12, 0.10, 0.07) * stitch;
 ROUGHNESS = 0.94;
}
"""
 curtain_material=ShaderMaterial.new()
 curtain_material.shader=gingham
 front_curtain_material=curtain_material.duplicate() as ShaderMaterial
 add_curtain_panels(self,front_curtain_material)
 var side_rail:=Node3D.new()
 side_rail.position=Vector3(-.41,0.,-.02)
 side_rail.rotation.y=-PI*.5
 side_rail.scale.x=.79
 add_child(side_rail)
 house.block(side_rail,Vector3(0,2.,1.08),Vector3(2.92,.034,.034),room.material("97836b"))
 add_curtain_panels(side_rail,curtain_material)

func add_curtain_panels(parent:Node3D,cloth:ShaderMaterial) -> void:
 for side in [-1.,1.]:
  var mesh:=SurfaceTool.new()
  mesh.begin(Mesh.PRIMITIVE_TRIANGLES)
  for row in 40:
   for column in 10:
    for corner in [Vector2.ZERO,Vector2.RIGHT,Vector2.ONE,Vector2.ZERO,Vector2.ONE,Vector2.DOWN]:
     var u:float=(column+corner.x)*.10
     var v:float=(row+corner.y)/40.
     var pinch:=exp(-pow((v-.58)*6.,2.))
     var width:=lerpf(.40,.14,pinch)
     mesh.set_uv(Vector2(u,v))
     mesh.add_vertex(Vector3(side*(1.46-u*width),1.98-v*1.86,1.095+.025*cos(u*TAU*3.)))
  mesh.generate_normals()
  var panel:MeshInstance3D=room.shape(parent,mesh.commit(),Vector3.ZERO,cloth)
  panel.custom_aabb=AABB(Vector3(-1.5,.11,1.05),Vector3(3.,1.9,.16))
  panel.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
  curtain_ties.append(house.block(parent,Vector3(side*1.38,.90,1.109),Vector3(.17,.044,.088),room.material("a28969")))

func set_curtain(closed:bool,duration:=.75) -> void:
 curtain_closed=closed
 if curtain_motion:curtain_motion.kill()
 if duration<=0.:
  curtain_amount=float(closed)
  return
 curtain_motion=create_tween()
 curtain_motion.tween_property(self,"curtain_amount",float(closed),duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func update_view(delta:float,allowed:bool,at:Vector3,source:Camera3D) -> void:
 var local:=to_local(at)
 var ground:=Vector2(local.x,local.z)
 var edge_distance:=ground.distance_to(ground.clamp(VIEW_FOOTPRINT.position,VIEW_FOOTPRINT.end))
 var current_camera:=get_viewport().get_camera_3d()
 var can_frame:=allowed and (current_camera==source or current_camera==lens)
 if view_engaged:
  view_engaged=can_frame and edge_distance<VIEW_EXIT_MARGIN
 else:
  view_dwell=view_dwell+delta if can_frame and edge_distance<VIEW_ENTER_MARGIN else 0.
  view_engaged=view_dwell>=.15
  if view_engaged:view_dwell=0.
 if not view_engaged and current_camera!=lens:
  view_amount=0.
  return
 view_amount=move_toward(view_amount,float(view_engaged),delta/.63)
 if view_amount<=0.:
  if lens.current:source.make_current()
  return
 var zoom:=smoothstep(0.,1.,view_amount)
 var viewport:=get_viewport().get_visible_rect().size
 var distance:=5.30*maxf(1.,1.6*viewport.y/maxf(1.,viewport.x))
 var eye:=to_global(Vector3(-.12,2.04,distance))
 var focus:=to_global(Vector3(.17,1.03,.15))
 var close_distance:=1.47*maxf(1.,1.48*viewport.y/maxf(1.,viewport.x))
 eye=eye.lerp(to_global(Vector3(.13,1.62,1.11+close_distance)),closeup_amount)
 focus=focus.lerp(to_global(Vector3(.13,1.57,1.03)),closeup_amount)
 var frame:=Transform3D(Basis.IDENTITY,eye).looking_at(focus)
 lens.global_transform=source.global_transform.interpolate_with(frame,zoom)
 lens.fov=lerpf(source.fov,39.5,zoom)
 if not lens.current:lens.make_current()

func build_rack() -> void:
 var shelf:=Node3D.new()
 shelf.name="OutsideBucketRack"
 shelf.position=YARD.BATH_RACK
 add_child(shelf)
 for x in [-.33,.33]:
  for z in [-.27,.27]:
   house.block(shelf,Vector3(x,.52,z),Vector3(.078,1.07,.079),wood)
 for y in [.22,1.06]:
  house.block(shelf,Vector3(0,y,0),Vector3(.81,.075,.67),wood)
 house.block(shelf,Vector3(.04,1.91,-.05),Vector3(.92,.085,.90),wood).rotation.z=-.16
 roof_tiles(shelf,Vector3(.04,1.955,-.05),Vector2(.94,.91),4).rotation.z=-.16
 house.block(shelf,Vector3(.37,1.42,-.29),Vector3(.08,.95,.08),wood)
 room.collider(shelf,Vector3(0,.53,0),Vector3(.82,1.12,.67))
 var atlas:=RACK_FINISHES.get_image()
 var half:=atlas.get_size()/2
 var finishes:Array[ImageTexture]=[]
 for cell in [Vector2i.ZERO,Vector2i(1,0),Vector2i(0,1),Vector2i.ONE]:
  var swatch:=atlas.get_region(Rect2i(cell*half+Vector2i(6,6),half-Vector2i(12,12)))
  swatch.generate_mipmaps()
  finishes.append(ImageTexture.create_from_image(swatch))
 build_bucket(shelf,finishes[0])
 build_mug(shelf,Vector3(-.218,1.098,.10),finishes[1],"WhiteGooseMug")
 build_mug(shelf,Vector3(-.034,1.098,.13),finishes[2],"BlackGooseMug")
 build_thermos(shelf,finishes[3])

func build_bucket(shelf:Node3D,texture:Texture2D) -> void:
 var bucket:=Node3D.new()
 bucket.name="GalvanizedBucket"
 bucket.position=Vector3(-.05,.258,.034)
 shelf.add_child(bucket)
 var zinc:=StandardMaterial3D.new()
 zinc.albedo_texture=texture
 zinc.albedo_color=Color(.86,.88,.89)
 zinc.metallic=.13
 zinc.roughness=.57
 zinc.cull_mode=BaseMaterial3D.CULL_DISABLED
 open_vessel(bucket,.153,.207,.284,zinc)
 ring(bucket,Vector3.UP*.278,.187,.211,zinc)
 ring(bucket,Vector3.UP*.03,.150,.163,zinc)
 var bail:=PackedVector3Array()
 for i in 19:
  var theta:=float(i)/18.*PI
  bail.append(Vector3(cos(theta)*.201,.217+sin(theta)*.197,.088*sin(theta)))
 handle(bucket,bail,.007,zinc)
 for x in [-.193,.193]:
  room.ellipsoid(bucket,Vector3(x,.230,.009),Vector3(.034,.045,.03),"88817a")

func build_mug(shelf:Node3D,at:Vector3,decal:Texture2D,object_name:String) -> void:
 var mug:=Node3D.new()
 mug.name=object_name
 mug.position=at
 shelf.add_child(mug)
 var enamel:=ShaderMaterial.new()
 enamel.shader=preload("res://scripts/art/bath_enamel432.gdshader")
 enamel.set_shader_parameter("decal",decal)
 open_vessel(mug,.061,.071,.143,enamel)
 var blue:StandardMaterial3D=room.material("324e68")
 ring(mug,Vector3.UP*.142,.060,.074,blue)
 var grip:=PackedVector3Array()
 for i in 13:
  var theta:=lerpf(-PI*.5,PI*.5,float(i)/12.)
  grip.append(Vector3(.061+cos(theta)*.047,.076+sin(theta)*.043,0.))
 handle(mug,grip,.010,blue)

func build_thermos(shelf:Node3D,texture:Texture2D) -> void:
 var flask:=Node3D.new()
 flask.name="CorkThermos"
 flask.position=Vector3(.169,1.098,-.047)
 shelf.add_child(flask)
 var painted:=StandardMaterial3D.new()
 painted.albedo_texture=texture
 painted.roughness=.58
 room.cylinder(flask,Vector3.UP*.146,.086,.292,"57746e",.079).material_override=painted
 room.cylinder(flask,Vector3.UP*.311,.079,.062,"57746e",.049).material_override=painted
 room.cylinder(flask,Vector3.UP*.346,.051,.03,"9e9274")
 room.cylinder(flask,Vector3.UP*.374,.037,.037,"9e693f",.046).material_override=wood
 ring(flask,Vector3.UP*.022,.077,.091,room.material("665f50"))
 handle(flask,PackedVector3Array([
  Vector3(.069,.269,0.),Vector3(.116,.267,0.),Vector3(.136,.245,0.),
  Vector3(.144,.210,0.),Vector3(.141,.149,0.),Vector3(.124,.122,0.),
  Vector3(.084,.115,0.)
 ]),.010,painted)

func open_vessel(parent:Node3D,bottom:float,top:float,height:float,ink:Material) -> void:
 var shell:=CylinderMesh.new()
 shell.bottom_radius=bottom
 shell.top_radius=top
 shell.height=height
 shell.radial_segments=32
 shell.cap_top=false
 room.shape(parent,shell,Vector3.UP*(height*.5),ink)
 # Model the inner wall and a real recessed floor, so the open rim reads from above.
 var inner:=CylinderMesh.new()
 inner.bottom_radius=bottom-.007
 inner.top_radius=top-.008
 inner.height=height-.011
 inner.radial_segments=32
 inner.cap_top=false
 var interior:=StandardMaterial3D.new()
 interior.albedo_color=Color("bfb3a0") if ink is ShaderMaterial else Color("777670")
 interior.roughness=.59
 interior.cull_mode=BaseMaterial3D.CULL_FRONT
 room.shape(parent,inner,Vector3.UP*(height*.5+.004),interior)
 room.cylinder(parent,Vector3.UP*.014,bottom-.004,.019,"c5b8a5" if ink is ShaderMaterial else "777670")

func handle(parent:Node3D,path:PackedVector3Array,radius:float,ink:Material) -> void:
 var surface:=SurfaceTool.new()
 surface.begin(Mesh.PRIMITIVE_TRIANGLES)
 for step in path.size()-1:
  for side in 8:
   for corner:Vector2i in [Vector2i.ZERO,Vector2i.DOWN,Vector2i.ONE,Vector2i.ZERO,Vector2i.ONE,Vector2i.RIGHT]:
    var index:=step+corner.x
    var tangent:Vector3=(path[mini(index+1,path.size()-1)]-path[maxi(index-1,0)]).normalized()
    var normal:=Vector3.BACK.rotated(tangent,(side+corner.y)*TAU/8.)
    surface.set_normal(normal)
    surface.set_uv(Vector2(float(index)/(path.size()-1),(side+corner.y)/8.))
    surface.add_vertex(path[index]+normal*radius)
 room.shape(parent,surface.commit(),Vector3.ZERO,ink)

func build_well(world:Node3D) -> void:
 well=Node3D.new()
 well.name="YardWell"
 well.position=to_local(Vector3(YARD.BATH_WELL.x,world.open_ground432(YARD.BATH_WELL),YARD.BATH_WELL.y))
 add_child(well)
 for y in [.12,.32,.53]:
  ring(well,Vector3.UP*y,.39,.58,house.stone)
 room.cylinder(well,Vector3.UP*.20,.43,.03,"374b4a")
 for x in [-.56,.56]:
  house.block(well,Vector3(x,.75,0),Vector3(.115,1.49,.13),wood)
 house.block(well,Vector3(0,1.44,0),Vector3(1.30,.135,.14),wood)
 house.block(well,Vector3(0,1.09,0),Vector3(1.15,.065,.065),wood)
 room.cylinder(well,Vector3(.04,.79,0),.011,.57,"a49471")
 var body:=StaticBody3D.new()
 body.collision_layer=1
 body.collision_mask=0
 var collision:=CollisionShape3D.new()
 var shape:=CylinderShape3D.new()
 shape.height=.65
 shape.radius=.61
 collision.shape=shape
 collision.position.y=.325
 body.add_child(collision)
 well.add_child(body)

func ring(parent:Node3D,at:Vector3,inner:float,outer:float,material:Material) -> void:
 var mesh:=TorusMesh.new()
 mesh.inner_radius=inner
 mesh.outer_radius=outer
 mesh.rings=28
 mesh.ring_segments=10
 room.shape(parent,mesh,at,material)
