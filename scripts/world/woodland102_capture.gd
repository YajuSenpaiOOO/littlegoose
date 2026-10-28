extends "res://scripts/world/woodland102_probe.gd"
func run() -> void:
 var sample := Sample102.new();root.add_child(sample)
 while not sample.woodland_ready102: await physics_frame
 await settle72(30);sample.label.get_parent().hide();sample.frames66.panel.hide();sample.details101.audio.set_enabled(false)
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 var g: Vector2=sample.meadow.landmarks.grove;var d: Node3D=sample.details101
 var bed := true
 for i in 24:
  for j in range(i+1,24): bed=bed and absf(d.leaf_states102[i].bed-d.leaf_states102[j].bed)>.001
 verify(bed,"each leaf in a pile has a distinct resting layer to avoid coplanar flicker")
 var unique := {}
 for texture in d.leaf_textures102: unique[str(texture.region)]=true
 verify(unique.size()==6,"six leaf types use six distinct alpha-separated atlas regions")
 var old_distance: float=sample.camera_distance;sample.camera_distance=6.;sample._update_camera(0.,true)
 await shot99(sample,g+Vector2(14.2,-.2),"upright_mushrooms")
 await shot99(sample,g+Vector2(10.4,1.),"single_pinecones")
 await shot99(sample,g+Vector2(12.6,.8),"leaf_pile_before")
 var before: Array[Vector2]=[]
 for leaf in d.leaf_states102: before.append(leaf.at)
 sample.hero.controls_enabled=true;sample.hero.wish=Vector2.UP;await settle72(45);sample.hero.wish=Vector2.ZERO;await settle72(90)
 var moved := 0
 for i in before.size():
  if d.leaf_states102[i].at.distance_to(before[i])>.06: moved+=1
 verify(moved>5,"actual walking disperses several leaves and leaves the pile changed")
 await shot99(sample,g+Vector2(12.6,.8),"leaf_pile_after")
 sample.camera_distance=9.;sample._update_camera(0.,true)
 await shot99(sample,g+sample.PARK99.from_stair99(Vector2(sample.PARK99.STAIR_X,-.9)),"solid_stairs")
 sample.camera_distance=old_distance;sample._update_camera(0.,true)
 sample.time55.preview_at(18.);sample.time55.visual_hour=18.;sample.time55.apply_look();await shot99(sample,g+Vector2(0,2.5),"park_sunset")
 sample.time55.preview_at(22.);sample.time55.visual_hour=22.;sample.time55.apply_look();await shot99(sample,g+Vector2(12.6,.8),"interactive_night")
 var data := {"checks":checks,"failures":failures,"dispersed_leaves":moved}
 var file := FileAccess.open("res://docs/woodland102-visual-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"));print("VISUAL102 ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
