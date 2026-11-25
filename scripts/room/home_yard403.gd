extends Node3D
# Bounded native geometry, no legacy world builders, terrain bake or combat scene.
var kit: Node3D
var facade403: Node3D
func build403(room: Node3D) -> void:
 kit=room;name="LocalYard403"
 var ground:=PlaneMesh.new();ground.size=Vector2(38,30)
 var grass:=StandardMaterial3D.new();grass.albedo_color=Color("889571");grass.roughness=1.
 kit.shape(self,ground,Vector3(0,-.018,17.7),grass).cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 kit.collider(self,Vector3(0,-.17,17.7),Vector3(38,.30,30))
 # Exterior ground only starts beyond the wood threshold at z=2.7.
 for side in [-1.,1.]:
  kit.box(self,Vector3(side*4.5,-.045,3.45),Vector3(6.8,.07,1.5),"7e8966")
 var stone:=StandardMaterial3D.new();stone.albedo_texture=preload("res://assets/garden45/slate.png");stone.albedo_color=Color("b1b1a0");stone.roughness=1.
 for i in 9:
  var path:=BoxMesh.new();path.size=Vector3(2.0 if i==0 else 1.55,.065,.70)
  var node=kit.shape(self,path,Vector3(0 if i==0 else sin(i*1.7)*.16,-.018,3.10+float(i)*.87),stone)
  node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
 # These shallow stones are decorative over the continuous level ground collider.
 for side in [-1.,1.]:
  for i in 10:
   var z:=3.0+float(i)*1.45
   kit.box(self,Vector3(side*7.8,.53,z),Vector3(.14,1.06,.14),"8c7554")
  for y in [.35,.75]:kit.box(self,Vector3(side*7.8,y,9.55),Vector3(.10,.11,13.4),"a58b63")
  kit.collider(self,Vector3(side*7.8,.7,9.5),Vector3(.22,1.4,14.0))
  # Close the narrow strips beside the house; the distant map is not loaded.
  kit.collider(self,Vector3(side*7.1,.7,2.64),Vector3(1.45,1.4,.16))
  for y in [.35,.75]:kit.box(self,Vector3(side*7.1,y,2.64),Vector3(1.45,.11,.12),"a58b63")
 for side in [-1.,1.]:
  kit.box(self,Vector3(side*4.4,.4,16.3),Vector3(6.6,.13,.12),"a58b63")
  kit.box(self,Vector3(side*4.4,.8,16.3),Vector3(6.6,.13,.12),"a58b63")
 kit.collider(self,Vector3(0,.7,16.5),Vector3(16.,1.4,.2))
 for side in [-1.,1.]:
  for i in 7:
   var x: float=side*(1.8+float(i)*.72)
   flower403(Vector3(x,0,3.45+float(i%2)*.55),"pink" if i%2==0 else "blue",.65)
  for i in 6:flower403(Vector3(side*(6.4+float(i%2)*.5),0,6.+float(i)*1.25),"blue" if i%2==0 else "pink",.75)
 # Clear occupied volumes: planter boxes and a bench use their visible geometry.
 for side in [-1.,1.]:
  kit.box(self,Vector3(side*5.6,.28,4.5),Vector3(1.7,.56,.80),"8b7252")
  kit.collider(self,Vector3(side*5.6,.28,4.5),Vector3(1.7,.56,.80))
  flower403(Vector3(side*5.6,.57,4.5),"pink",1.3)
 kit.box(self,Vector3(-5.1,.50,9.6),Vector3(2.3,.14,.65),"a58960")
 for x in [-6.,-4.2]:kit.box(self,Vector3(x,.23,9.6),Vector3(.12,.46,.5),"826d4d")
 kit.collider(self,Vector3(-5.1,.35,9.6),Vector3(2.3,.70,.65))
 facade403=Node3D.new();facade403.name="ExteriorCutaway403";add_child(facade403)
 # A structural facade with a real opening. Interior collision stays unchanged.
 for side in [-1.,1.]:
  kit.box(facade403,Vector3(side*3.75,1.95,2.77),Vector3(5.3,3.15,.16),"d2b997")
  for x in [side*1.12,side*6.12]:kit.box(facade403,Vector3(x,1.8,2.9),Vector3(.19,3.6,.25),"73563b")
 kit.box(facade403,Vector3(0,3.15,2.77),Vector3(2.06,.9,.16),"d2b997")
 kit.box(facade403,Vector3(0,2.62,2.94),Vector3(2.35,.15,.27),"73563b")
 var st:=SurfaceTool.new();st.begin(Mesh.PRIMITIVE_TRIANGLES)
 for i in 48:
  var x0: float=-6.3+12.6*float(i)/48.;var x1: float=-6.3+12.6*float(i+1)/48.
  var y0: float=room.frame399.outer399(x0)+.12;var y1: float=room.frame399.outer399(x1)+.12
  for p in [Vector3(x0,y0,3.0),Vector3(x1,y1,-4.65),Vector3(x1,y1,3.0),Vector3(x0,y0,3.0),Vector3(x0,y0,-4.65),Vector3(x1,y1,-4.65)]:st.add_vertex(p)
  for p in [Vector3(x0,3.5,3.02),Vector3(x1,y1,3.02),Vector3(x0,y0,3.02),Vector3(x0,3.5,3.02),Vector3(x1,3.5,3.02),Vector3(x1,y1,3.02)]:st.add_vertex(p)
 st.generate_normals();var roof: StandardMaterial3D=kit.material("785c45");roof.cull_mode=BaseMaterial3D.CULL_DISABLED
 kit.shape(facade403,st.commit(),Vector3.ZERO,roof)
 for side in [-1.,1.]:
  var lamp:=OmniLight3D.new();lamp.position=Vector3(side*1.45,1.9,3.2);lamp.light_color=Color("ffe1a3");lamp.light_energy=.35;lamp.omni_range=2.5;add_child(lamp)
  kit.box(facade403,lamp.position,Vector3(.15,.26,.15),"c9ac6d")
func flower403(at: Vector3,color: String,height: float) -> void:
 var sprite:=Sprite3D.new();sprite.texture=load("res://assets/courtyard_v1/Bush_"+color+"_flowers1.png")
 sprite.pixel_size=height/float(sprite.texture.get_height());sprite.offset.y=sprite.texture.get_height()*.5;sprite.position=at;sprite.rotation_degrees.x=-25.
 sprite.alpha_cut=SpriteBase3D.ALPHA_CUT_DISCARD;sprite.shaded=true;sprite.texture_filter=BaseMaterial3D.TEXTURE_FILTER_NEAREST_WITH_MIPMAPS
 # Small flower clumps are non-blocking, receiving and casting their own cutout shadow.
 sprite.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_ON;add_child(sprite)
