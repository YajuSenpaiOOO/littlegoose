extends RefCounted
static func texture119() -> AtlasTexture:
 var texture := AtlasTexture.new();texture.atlas=preload("res://assets/collectibles119/blue_elastic_drop.png")
 # Crop transparent margins at runtime, preserving the selected original PNG.
 texture.region=Rect2(174,263,914,750);return texture
