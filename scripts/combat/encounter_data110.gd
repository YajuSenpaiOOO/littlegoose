extends RefCounted
const ACT_TABLE := [
	# 1-6 幕 = 已校准锚点（制作人手调值，基准玩家 k≈3 在这几行上）。
	# 5/6 幕血量 0928e 制作人实测下调（普通构筑第 5 波起打不动=刮痧）；
	# boss_hp 键 = 大王显式血量（第六波怪降血后大王保持 264 不动）
	{"count": 3, "hp": 12.0, "spd": 1.0, "scale": 1.0, "touch": 2.0, "elite": 0, "behaviors": []},
	{"count": 4, "hp": 16.2, "spd": 1.04, "scale": 1.04, "touch": 2.0, "elite": 0, "behaviors": ["pack"]},
	{"count": 5, "hp": 20.4, "spd": 1.08, "scale": 1.08, "touch": 2.5, "elite": 0, "behaviors": ["double_hop"]},
	{"count": 7, "hp": 26.0, "spd": 1.14, "scale": 1.12, "touch": 2.5, "elite": 0, "behaviors": ["flank"]},
	{"count": 7, "hp": 24.0, "spd": 1.16, "scale": 1.16, "touch": 3.0, "elite": 1, "behaviors": ["sidestep"]},
	{"count": 8, "hp": 27.0, "spd": 1.2, "scale": 1.2, "touch": 3.0, "elite": 1,
			"behaviors": ["pack", "flank"], "boss_hp": 264.0},
	# 7-13 幕 = 从锚点外推 + 已有行为排列组合（行为密度递增，无新行为）；
	# 精英节奏 5/6/8/11(双)/13；数值匹配 pass 中随基准校准微调
	{"count": 8, "hp": 36.0, "spd": 1.22, "scale": 1.2, "touch": 3.0, "elite": 0, "behaviors": ["double_hop", "sidestep"]},
	{"count": 8, "hp": 39.0, "spd": 1.24, "scale": 1.2, "touch": 3.0, "elite": 1, "behaviors": ["flank", "sidestep"]},
	{"count": 9, "hp": 42.0, "spd": 1.26, "scale": 1.25, "touch": 3.0, "elite": 0, "behaviors": ["pack", "flank"]},
	{"count": 9, "hp": 45.0, "spd": 1.28, "scale": 1.25, "touch": 3.5, "elite": 0, "behaviors": ["sidestep", "double_hop"]},
	{"count": 9, "hp": 48.0, "spd": 1.3, "scale": 1.3, "touch": 3.5, "elite": 2, "behaviors": ["flank", "sidestep"]},
	{"count": 10, "hp": 51.0, "spd": 1.32, "scale": 1.3, "touch": 3.5, "elite": 0, "behaviors": ["pack", "double_hop", "sidestep"]},
	{"count": 10, "hp": 54.0, "spd": 1.34, "scale": 1.3, "touch": 4.0, "elite": 1, "behaviors": ["pack", "flank", "sidestep"]},
]
