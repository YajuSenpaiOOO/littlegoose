extends RefCounted
const TOTAL := 6
const CAP := 3
var spawned := 2
var defeated := 0
var final_called := false
var retry_left := 0.
var seconds := 0.
var replacements := 0
func target_count() -> int:return TOTAL if defeated>=3 else (4 if defeated>=1 else 2)
func complete() -> bool:return defeated==TOTAL and spawned==TOTAL
func needs_entry(alive: int) -> bool:return spawned<target_count() and alive<CAP and retry_left<=0.
func entered() -> bool:
 var final=spawned>=4 and not final_called
 if final:final_called=true
 spawned+=1;retry_left=1.1;return final
func cancelled() -> void:
 spawned=maxi(defeated,spawned-1);replacements+=1;retry_left=.8
func snapshot() -> Dictionary:return {"total":TOTAL,"spawned":spawned,"defeated":defeated,"seconds":seconds,"replacement_entries":replacements,"final_called":final_called}
