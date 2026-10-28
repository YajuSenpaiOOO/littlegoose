extends "res://scripts/world/woodland101_probe.gd"
func run() -> void:
 var sample := Sample101.new();root.add_child(sample)
 while not sample.woodland_ready101: await physics_frame
 await settle72(20);sample.label.get_parent().hide();sample.frames66.panel.hide()
 sample.details101.audio.set_enabled(false)
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 var d: Node3D=sample.details101
 verify(d.butterflies.multimesh.mesh.surface_get_array_len(0)==12,"butterfly mesh has two hinged wing panels")
 var error := 0.
 for prop in d.props: error=maxf(error,absf(prop.position.y-sample.floor_height(Vector2(prop.position.x,prop.position.z))-.004))
 verify(error<.002,"root ornaments sit on the unchanged actual terrain")
 var g: Vector2=sample.meadow.landmarks.grove
 var original_distance: float=sample.camera_distance
 sample.camera_distance=9.;sample._update_camera(0.,true)
 await shot99(sample,g+Vector2(-6.5,8.2),"root_microgarden")
 await shot99(sample,g+Vector2(8.7,2.8),"path_edge")
 sample.camera_distance=original_distance;sample._update_camera(0.,true)
 await shot99(sample,g+Vector2(0,2.5),"park_day")
 sample.time55.preview_at(18.);sample.time55.visual_hour=18.;sample.time55.apply_look()
 await shot99(sample,g+Vector2(0,2.5),"park_sunset")
 sample.time55.preview_at(22.);sample.time55.visual_hour=22.;sample.time55.apply_look()
 await shot99(sample,g+Vector2(5,-1),"park_night")
 verify(not d.active.has(true),"final version hides butterfly wings at night")
 sample.time55.preview_at(12.);sample.time55.visual_hour=12.;sample.time55.apply_look()
 sample._teleport15(sample.meadow.landmarks.home);await settle72(30)
 d.audio.set_enabled(true);d.audio.bird_wait=0.;var calls: int=d.audio.bird_events;await settle72(15)
 verify(d.audio.bird_events==calls,"bird cues do not trigger when the hero is outside their radius")
 var data := {"checks":checks,"failures":failures,"ground_error":error,"pebbles":d.pebbles.multimesh.instance_count,"grass":d.grass.multimesh.instance_count}
 var file := FileAccess.open("res://docs/woodland101-visual-validation.json",FileAccess.WRITE);file.store_string(JSON.stringify(data,"\t"))
 print("WOODLAND101_VISUAL ",JSON.stringify(data));quit(0 if failures.is_empty() else 1)
