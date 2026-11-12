extends RefCounted
const TOTAL := 15
const CAP := 5
const WAVES := [3,4,5]
var spawned := 3
var defeated := 0
var final_called := false
var retry_left := 0.
var seconds := 0.
var replacements := 0
var wave := 0
var target := 3
var incoming := 0
func target_count() -> int:return target
func live_cap() -> int:return 5 if wave==WAVES.size() else 4
func complete() -> bool:return spawned==TOTAL and defeated==TOTAL
func needs_entry(alive: int) -> bool:
 if spawned==target and incoming==0 and wave<WAVES.size() and alive<=2:
  target+=WAVES[wave];wave+=1
 return spawned<target and alive<live_cap() and retry_left<=0.
func entered() -> bool:
 var final=wave==WAVES.size() and not final_called
 if final:final_called=true
 spawned+=1;retry_left=.65;return final
func cancelled() -> void:
 spawned=maxi(defeated,spawned-1);replacements+=1;retry_left=.8
func snapshot() -> Dictionary:return {"total":TOTAL,"spawned":spawned,"defeated":defeated,"seconds":seconds,"wave":wave,"reinforcement_batches":WAVES,"cap":live_cap(),"pending":target-spawned,"replacement_entries":replacements,"final_called":final_called}
