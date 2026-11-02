extends RefCounted
const PERIOD := .5
const WINDOW := .08
var time := 0.
var last := 0
var reserved := {} # A premature tap commits this beat to normal; no reroll by spamming.
var events: Array[Dictionary]=[]
var perfects := 0
var normals := 0
func reset() -> void:
 time=0.;last=0;reserved.clear();events.clear();perfects=0;normals=0
func emit_beat(beat: int,perfect: bool) -> void:
 if beat<=last:return
 last=beat;reserved.erase(beat)
 events.append({"beat":beat,"perfect":perfect,"gain":1.4 if perfect else 1.})
 if perfect:perfects+=1
 else:normals+=1
func press() -> void:
 var nearest=maxi(1,roundi(time/PERIOD))
 if absf(time-nearest*PERIOD)<=WINDOW+.000001:
  if nearest>last and not reserved.has(nearest):emit_beat(nearest,true)
 else:
  var upcoming=maxi(1,floori(time/PERIOD)+1)
  if upcoming>last:reserved[upcoming]=true
func step(delta: float,held: bool,allowed: bool) -> void:
 time+=delta
 var due=floori((time-WINDOW-.000001)/PERIOD)
 if due<=last:return
 # No catch-up volleys after a hitch, guard or dodge.
 var beat=due
 var requested=held or reserved.has(beat)
 if allowed and requested:emit_beat(beat,false)
 else:last=beat
 for old in reserved.keys():
  if int(old)<=last:reserved.erase(old)
func drain() -> Array[Dictionary]:
 var result=events.duplicate();events.clear();return result
