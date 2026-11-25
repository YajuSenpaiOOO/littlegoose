extends RefCounted

const DIRECTORY := "res://assets/workshop432/fragments/"
const REGIONS := {
 "balloon_sword":Rect2(48,25,1177,1213),
 "bouncy_ball":Rect2(149,46,933,1181),
 "cup_phone":Rect2(40,158,1159,1031),
 "exercise":Rect2(152,13,894,1237),
 "eye_exercise":Rect2(19,376,1217,561),
 "flashlight":Rect2(22,94,1196,1070),
 "forest_fireboy":Rect2(98,43,1056,1190),
 "hero_moment":Rect2(29,61,1125,1168),
 "homework":Rect2(171,38,1060,1031),
 "music_class":Rect2(121,37,1010,1203),
 "pillow_hut":Rect2(7,112,1234,1063),
 "red_banner":Rect2(130,17,981,1228),
 "snack":Rect2(45,100,1144,1108)
}

static func load_icons() -> Dictionary:
 var icons:Dictionary={}
 for id in REGIONS:
  var icon:=AtlasTexture.new()
  icon.atlas=load(DIRECTORY+id+".png")
  icon.region=REGIONS[id]
  icon.filter_clip=true
  icons[id]=icon
 return icons
