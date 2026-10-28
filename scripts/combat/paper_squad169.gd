extends "res://scripts/combat/paper_float162.gd"
## One aircraft per emitting goose; each keeps only that source's weighted specs.
var source_rate169 := 1.
func spacing150() -> float: return super.spacing150()/maxf(.1,source_rate169)
func launch146(packet: Dictionary,origin: Vector3,target: Vector3,gain := 1.,replay := false) -> void:
 if packet.get("single_goose169",false):
  var saved_rate := source_rate169;source_rate169=float(packet.get("source_rate169",1.))
  super.launch146(packet,origin,target,gain,replay);source_rate169=saved_rate;return
 var groups := {}
 for spec in packet.specs:
  var source := int(spec.get("goose_source168",0))
  if not groups.has(source): groups[source]=[]
  groups[source].append(spec.duplicate(true))
 var sources: Array=groups.keys();sources.sort()
 var origins: Array[Vector3]=battle.skills110.origins110()
 for source in sources:
  var own: Dictionary=packet.duplicate(true);own.specs=groups[source];own.single_goose169=true;own.goose_source169=source
  own.source_rate169=float(packet.get("source_rates169",{}).get(source,1.))
  var correction := float(packet.get("source_angles169",{}).get(source,0.))
  for spec in own.specs: spec.angle=float(spec.angle)-correction
  var from: Vector3=origins[source] if source>=0 and source<origins.size() else origin
  var saved := source_rate169;source_rate169=own.source_rate169
  super.launch146(own,from,target,gain,replay);source_rate169=saved
  var flight: Dictionary=planes149[-1]
  flight.goose_source169=source
  flight.source_rate169=own.source_rate169
  flight.source_interval169=float(packet.get("source_intervals169",{}).get(source,battle.attack_cooldown()))
