extends "res://scripts/combat/fixed_stage164.gd"
var panels165: Array[Dictionary]=[]
var textures165 := {}
func ground_shader164() -> Shader: return preload("res://scripts/combat/paper_page165.gdshader")
func _ready() -> void:
 super._ready();name="PopUpRecessBook165"
 var regions: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://assets/popup_stage165/regions.json"))
 for id in ["rear","left","right","edge"]:
  var r: Array=regions[id]
  var image := preload("res://scripts/combat/imported_image172.gd").read("res://assets/popup_stage165/"+id+".png").get_region(Rect2i(r[0],r[1],r[2],r[3]));image.generate_mipmaps()
  textures165[id]=ImageTexture.create_from_image(image)
 add_panel165("rear",5.2,Vector2(0.,.84),.05,true)
 add_panel165("left",2.7,Vector2(-.77,.36),.18,true)
 add_panel165("right",2.65,Vector2(.77,.42),.30,true)
 for i in 16:
  var a := TAU*float(i)/16.+.10
  add_panel165("edge",.85+float(i%3)*.10,Vector2(cos(a),sin(a))*(.97+.015*sin(a*3.)),.14+float(i%4)*.04,false)
func add_panel165(id: String,width: float,local: Vector2,delay: float,tall: bool) -> void:
 var face := Sprite3D.new();face.texture=textures165[id];face.pixel_size=width/face.texture.get_width();face.offset.y=face.texture.get_height()*.5
 setup_sprite164(face)
 root164.add_child(face);battle._add_actor_shadow(face,face)
 var back := Sprite3D.new();back.texture=face.texture;back.pixel_size=face.pixel_size;back.offset=face.offset;setup_sprite164(back)
 back.modulate=Color("e8d6b5");root164.add_child(back)
 panels165.append({"id":id,"face":face,"back":back,"local":local,"delay":delay,"tall":tall,"base":Vector3.ZERO,"frame":Basis.IDENTITY,"fold":-PI*.5,"fade":1.,"placed":false})
func request161() -> bool:
 if not super.request161(): return false
 var right := Vector3(battle.camera.global_basis.x.x,0.,battle.camera.global_basis.x.z).normalized()
 var forward := -Vector3(battle.camera.global_basis.z.x,0.,battle.camera.global_basis.z.z).normalized()
 var frame := Basis(right,Vector3.UP,right.cross(Vector3.UP)).orthonormalized()
 for panel in panels165:
  var p: Vector3=anchor164+(right*panel.local.x+forward*panel.local.y)*RADIUS164
  p.y=battle.floor_height(Vector2(p.x,p.z))+.035
  panel.base=p;panel.frame=frame;panel.fade=1.;panel.fold=-PI*.5;panel.placed=absf(p.y-anchor164.y)<1.
  panel.face.visible=panel.placed;panel.back.visible=panel.placed
 # Existing windmills become accents in the gaps rather than a complete ring.
 for i in props164.size():
  if i>=3: props164[i].pole.hide();props164[i].rotor.hide()
 update_panels165(0.)
 return true
func covers_actor165(panel: Dictionary,actor: Vector3) -> bool:
 var face: Sprite3D=panel.face
 var camera: Camera3D=battle.camera
 var middle: Vector3=panel.base+Vector3.UP*(face.texture.get_height()*face.pixel_size*.5)
 if camera.global_position.distance_squared_to(actor)<=camera.global_position.distance_squared_to(middle): return false
 if camera.is_position_behind(actor): return false
 var width: float=face.texture.get_width()*face.pixel_size
 var height: float=face.texture.get_height()*face.pixel_size
 var p := camera.unproject_position(face.to_global(Vector3(-width*.5,0.,0.)))
 var bounds := Rect2(p,Vector2.ZERO)
 for local in [Vector3(width*.5,0.,0.),Vector3(-width*.5,height,0.),Vector3(width*.5,height,0.)]: bounds=bounds.expand(camera.unproject_position(face.to_global(local)))
 return bounds.grow(-4.).has_point(camera.unproject_position(actor))
func update_panels165(delta: float) -> void:
 var dt := 0. if battle.combat_paused else delta
 for panel in panels165:
  if not panel.placed: continue
  var t := smoothstep(panel.delay,panel.delay+.60,float_age162)
  var fold: float=-PI*.5*(1.-t)+sin(t*PI)*.12
  if left161<=0.: fold=-PI*.5*smoothstep(0.,.65,tail161)
  panel.fold=fold
  var basis: Basis=panel.frame*Basis(Vector3.RIGHT,fold)
  panel.face.global_transform=Transform3D(basis,panel.base)
  panel.back.global_transform=Transform3D(basis.scaled(Vector3(1.012,1.01,1.)),panel.base-basis.z*.022)
  var covered := false
  if panel.tall and t>.5:
   covered=covers_actor165(panel,battle.hero.get_global_transform_interpolated().origin+Vector3.UP*.65)
   if not covered:
    for enemy in battle.enemies:
     if is_instance_valid(enemy) and not enemy.dead and enemy.is_visible_in_tree() and covers_actor165(panel,enemy.hit_area.global_position): covered=true;break
  panel.fade=lerpf(panel.fade,.23 if covered else 1.,1.-exp(-dt*13.))
  var alpha: float=strength161()*panel.fade
  panel.face.modulate.a=alpha;panel.back.modulate.a=alpha
func _process(delta: float) -> void:
 super._process(delta)
 if is_instance_valid(root164) and root164.visible: update_panels165(delta)
