extends "res://scripts/combat/memory_kit346.gd"

const MATERIAL_IDS := ["twigs","gel119","homework_paper","water_seed","water_baby"]
const LAYER_LIMIT := 10
const RADIUS := 132.
const FEATURED := ["paper_plane","slingshot","three_player"]
const BOUNCY_BALL := "bouncy_ball"
const SLINGSHOT_TWIGS := 1
const PLANE_PAPER:=1
const SNACK_WATER:=1
const TIN_LINES := {
 "boarding_school":"把三个小伙伴都叫来！今晚谁也别急着睡。",
 "hero_moment":"按 Q 搭起小舞台。都看好了，这次我来当主角！",
 "pillow_hut":"蹲一会儿，就能搭个枕头小屋躲进去。",
 "balloon_sword":"气球剑黏在身上，迈步就会慢一点。",
 "paper_plane":"把弹幕折进纸飞机，让它飞到瞄准的地方。",
 "slingshot":"把皮筋拉紧再松手，一发重弹能穿过去！",
 "flashlight":"按 Q 拿出被窝里的手电筒，射出一道贯穿光束。",
 "snack":"一撞上去，大水宝宝就分成小水珠弹开！",
 "paper_racer":"小赛车跑起来了！走得更快，弹反时还能把对方弹开。",
 "exercise":"闪身溜过去，在身后留一串舞步星星。",
 "eye_exercise":"眨眨眼，弹幕发得更快，还会稍微跟过去一点。",
 "forest_fireboy":"召唤一个实力只有本体 40% 的小黑鹅。\n——小黑鹅对突然出现的使魔很从容，她只是想告诉你它只有她的 40%。",
 "three_player":"召唤两个实力和「可爱程度」都只有本体 40% 的小黑鹅。\n——小黑鹅本人是这么强调的。",
 "music_class":"你是音游大手子，按到 Perfect 有奖励！",
 "red_banner":"闪避时留下一面旗。下一次攻击，旗里的小鹅会帮忙。",
 "homework":"按 Q 翻开笔记，把最近几轮攻击再演一遍。",
 "distract":"一边听课一边画小人，弹幕也多走一路。",
 "cup_phone":"接通纸杯电话，小黑鹅就能出动，到处找演员。",
 "east_west":"猜猜会翻到什么？这一页还没写完。",
 "bouncy_ball":"打出去的弹丸还能再弹一下。小心，它又回来啦！"
}
var tin_layers: Array=[]
var twigs := 0
var homework_paper:=0
var tuantuan_unlocked:=false
var water_seed:=0
var water_baby:=0
var bath_ready_at:=-1.
var last_saved_time:=-1.
var last_saved_health:=-1.
var manual_save:=false
var discovered_materials: Dictionary={}

func remember_materials() -> void:
 for id in MATERIAL_IDS:
  if int(get(id))>0:discovered_materials[id]=true

func tin_line(id:String) -> String:
 return TIN_LINES.get(id,card(id).get("line",""))

func load_from(path:String) -> void:
 super.load_from(path)
 set_bouncy_ball(bool(unlocked.get(BOUNCY_BALL,false)))
 var config:=ConfigFile.new()
 var saved: Variant=[]
 twigs=0
 homework_paper=0
 tuantuan_unlocked=bool(unlocked.get(BOUNCY_BALL,false))
 if config.load(path)==OK:
  saved=config.get_value("tin","layers",[])
  var saved_twigs:Variant=config.get_value("materials","twigs",0)
  if saved_twigs is int:twigs=clampi(saved_twigs,0,999999)
  var saved_paper:Variant=config.get_value("materials","homework_paper",0)
  if saved_paper is int:homework_paper=clampi(saved_paper,0,999999)
  # The inherited preview loader grants a starter plane even if stock was zero.
  var saved_stock:Variant=config.get_value("memories","owned",{})
  if saved_stock is Dictionary and saved_stock.get("paper_plane",-1)==0 and "paper_plane" not in equipped:
   owned["paper_plane"]=0
   crafted["paper_plane"]=0
  if saved_stock is Dictionary and saved_stock.get("snack",-1)==0 and "snack" not in equipped:
   owned["snack"]=0
   crafted["snack"]=0
  tuantuan_unlocked=tuantuan_unlocked or bool(config.get_value("encounters","tuantuan_unlocked",false))
 else:
  owned["paper_plane"]=0
  crafted["paper_plane"]=0
  owned["snack"]=0
  crafted["snack"]=0
  equipped.assign(equipped.filter(func(id:String):return id not in ["paper_plane","snack"]))
 discovered_materials.clear()
 water_seed=0
 water_baby=0
 bath_ready_at=-1.
 last_saved_time=-1.
 last_saved_health=-1.
 if config.has_section("life"):
  water_seed=clampi(int(config.get_value("life","water_seed",0)),0,999999)
  water_baby=clampi(int(config.get_value("life","water_baby",0)),0,999999)
  bath_ready_at=float(config.get_value("life","bath_ready_at",-1.))
  last_saved_time=float(config.get_value("life","time",-1.))
  last_saved_health=float(config.get_value("life","health",-1.))
 var discovered: Variant=config.get_value("materials","discovered",[])
 if discovered is Array:
  for id in MATERIAL_IDS:
   if id in discovered:discovered_materials[id]=true
 if int(crafted.get("paper_plane",0))>0:discovered_materials["homework_paper"]=true
 if int(crafted.get("slingshot",0))>0:
  discovered_materials["twigs"]=true
  discovered_materials["gel119"]=true
 if bath_ready_at>=0. or water_baby>0:discovered_materials["water_seed"]=true
 remember_materials()
 tin_layers=reconcile(saved)

func recipe_cost(id:String) -> Dictionary:
 match id:
  "slingshot":return {"twigs":SLINGSHOT_TWIGS,"gel119":BALANCE119.SLINGSHOT_GEL}
  "paper_plane":return {"homework_paper":PLANE_PAPER}
  "snack":return {"water_baby":SNACK_WATER}
 return {}

func can_make_recipe(id:String) -> bool:
 if not unlocked.get(id,false) or int(owned.get(id,0))>=999:return false
 var cost:=recipe_cost(id)
 for material in cost:
  if int(get(material))<cost[material]:return false
 return not cost.is_empty()

func make_recipe(id:String,path:String) -> Error:
 if not can_make_recipe(id):return ERR_UNAVAILABLE
 remember_materials()
 var previous_layers:=tin_layers
 var cost:=recipe_cost(id)
 var layout:=reconcile(tin_layers)
 if layout.back().size()>=LAYER_LIMIT:layout.append([])
 var bottom:Array=layout.back()
 bottom.append({"id":id,"at":initial_point(bottom)})
 owned[id]+=1
 crafted[id]+=1
 for material in cost:set(material,int(get(material))-cost[material])
 tin_layers=layout
 var result:=save_to(path)
 if result!=OK:
  owned[id]-=1
  crafted[id]-=1
  for material in cost:set(material,int(get(material))+cost[material])
  tin_layers=previous_layers
 return result

func try_craft119(_id:String,_stock:Dictionary,_made:Dictionary,_gel:int) -> int:
 # Crafting consumes both materials in the diary's save transaction.
 return -1

func set_bouncy_ball(earned:bool) -> void:
 owned[BOUNCY_BALL]=1 if earned else 0
 crafted[BOUNCY_BALL]=0
 unlocked[BOUNCY_BALL]=earned

func card(id:String) -> Dictionary:
 var entry:=super.card(id).duplicate(true)
 if id=="snack":
  entry.name="养大的水宝宝"
  entry.desc="泡了一晚，小珠子已经长成软乎乎的一团了。"
  entry.line="昨天明明还是这么小一颗！"
  entry.fx=entry.fx.replace("糖屑","小水珠")
  entry.fx2=entry.fx2.replace("糖屑","小水珠")
 elif id=="forest_fireboy":
  entry.name="双人闯关"
 elif id==BOUNCY_BALL:
  entry.line="接住！它又弹回来啦。"
 return entry

func used(ids:Array) -> int:
 return super.used(ids)+ids.count(BOUNCY_BALL)*int(PROFILE346.COSTS[BOUNCY_BALL])

func valid(ids:Array,stock:Dictionary={}) -> bool:
 var count:=ids.count(BOUNCY_BALL)
 if count==0:return super.valid(ids,stock)
 var available:=owned if stock.is_empty() else stock
 if count>1 or not unlocked.get(BOUNCY_BALL,false) or int(available.get(BOUNCY_BALL,0))<count:return false
 if "balloon_sword" in ids or used(ids)>CAPACITY:return false
 var ordinary:=ids.duplicate()
 ordinary.erase(BOUNCY_BALL)
 return super.valid(ordinary,available)

func stock_valid118(stock:Variant,made:Variant,open:Variant) -> bool:
 if not stock is Dictionary or not made is Dictionary or not open is Dictionary:return false
 var count:Variant=stock.get(BOUNCY_BALL,0)
 var crafted_count:Variant=made.get(BOUNCY_BALL,0)
 var earned:Variant=open.get(BOUNCY_BALL,false)
 if not count is int or not earned is bool or not crafted_count is int:return false
 if count!=int(earned) or crafted_count!=0:return false
 var base_stock:Dictionary=stock.duplicate()
 var base_made:Dictionary=made.duplicate()
 var base_open:Dictionary=open.duplicate()
 base_stock.erase(BOUNCY_BALL)
 base_made.erase(BOUNCY_BALL)
 base_open.erase(BOUNCY_BALL)
 return super.stock_valid118(base_stock,base_made,base_open)

func summary(ids:Array) -> String:
 if BOUNCY_BALL not in ids:return super.summary(ids)
 if ids.size()==1:return card(BOUNCY_BALL).name
 return super.summary(ids)+"、"+str(card(BOUNCY_BALL).name)

func save_to(path:String) -> Error:
 if manual_save:
  remember_materials()
  tin_layers=reconcile(tin_layers)
  return OK
 return save_checkpoint(path)

func save_checkpoint(path:String) -> Error:
 remember_materials()
 var layout:=reconcile(tin_layers)
 var config:=memory_config168()
 config.set_value("tin","layers",layout)
 config.set_value("materials","discovered",discovered_materials.keys())
 config.set_value("materials","twigs",twigs)
 config.set_value("materials","homework_paper",homework_paper)
 config.set_value("encounters","tuantuan_unlocked",tuantuan_unlocked)
 config.set_value("life","water_seed",water_seed)
 config.set_value("life","water_baby",water_baby)
 config.set_value("life","bath_ready_at",bath_ready_at)
 config.set_value("life","time",last_saved_time)
 config.set_value("life","health",last_saved_health)
 var staged:=path+".tmp"
 var result:=config.save(staged)
 if result==OK:
  result=DirAccess.rename_absolute(staged,path)
 if result==OK:tin_layers=layout
 else:DirAccess.remove_absolute(staged)
 return result

func reconcile(saved:Variant) -> Array:
 var available: Dictionary=owned.duplicate()
 for id in equipped:available[id]=maxi(0,int(available.get(id,0))-1)
 var layers: Array=[]
 if saved is Array:
  for saved_layer in saved:
   if not saved_layer is Array:continue
   var layer: Array=[]
   for entry in saved_layer:
    if not entry is Dictionary:continue
    var id: Variant=entry.get("id")
    var at: Variant=entry.get("at")
    if not id is String or not at is Vector2 or not at.is_finite():continue
    if layer.size()>=LAYER_LIMIT or int(available.get(id,0))<=0:continue
    layer.append({"id":id,"at":at.limit_length(RADIUS)})
    available[id]-=1
   layers.append(layer)
 if layers.is_empty():layers.append([])
 var order: Array=FEATURED.duplicate()
 for id in ORDER:
  if not order.has(id):order.append(id)
 order.append(BOUNCY_BALL)
 for id in order:
  for copy in int(available.get(id,0)):
   if layers.back().size()>=LAYER_LIMIT:layers.append([])
   var layer: Array=layers.back()
   var at:=initial_point(layer)
   layer.append({"id":id,"at":at})
 while layers.size()<2:layers.append([])
 return layers

func initial_point(layer:Array) -> Vector2:
 var best:=Vector2.ZERO
 var most_space:=-1.
 for i in 61:
  var point:=Vector2.from_angle(i*2.39996)*sqrt(float(i)/60.)*122.
  var clearance:=INF
  for bead in layer:clearance=minf(clearance,point.distance_squared_to(bead.at))
  if clearance>most_space:
   most_space=clearance
   best=point
 return best
