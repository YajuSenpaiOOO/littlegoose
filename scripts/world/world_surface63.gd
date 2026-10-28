extends "res://scripts/world/world_surface21.gd"
## Wider hub footprint, deliberately keeping the station square and heights fixed.
const HUB_RADII63 := Vector2(10.,8.8)

func _init() -> void:
	super._init()
	var hub: Vector2=landmarks.junction
	for entry in named_routes:
		var controls: PackedVector2Array=entry.controls
		match entry.name:
			"junction_ring":
				controls.clear()
				for i in 49:
					var angle := TAU*float(i)/48.
					controls.append(hub+Vector2(sin(angle)*HUB_RADII63.x,cos(angle)*HUB_RADII63.y))
				entry.controls=controls
				entry.points=controls
				entry.radius=1.2
				continue
			"junction_to_station":
				controls=PackedVector2Array([hub+Vector2(0,-8.8),hub+Vector2(2.8,-12.),hub+Vector2(-1.5,-15.2),landmarks.station+Vector2(0,4.5),landmarks.station+Vector2(0,1.35)])
			"home_to_junction":
				while controls.size()>2 and ((controls[-1]-hub)/HUB_RADII63).length()<1.15: controls.resize(controls.size()-1)
				controls.append(hub+Vector2(0,8.8))
			"junction_to_grove", "junction_to_shore":
				var start := hub+Vector2(-10.,0.) if entry.name=="junction_to_grove" else hub+Vector2(10.,0.)
				while controls.size()>2 and ((controls[0]-hub)/HUB_RADII63).length()<1.15: controls.remove_at(0)
				controls.insert(0,start)
		entry.controls=controls
		entry.points=_smooth(controls)
	_reindex_routes()

func is_open_ground(at: Vector2) -> bool:
	return ((at-landmarks.junction)/(HUB_RADII63+Vector2(2.7,2.7))).length()<1. or super.is_open_ground(at)
