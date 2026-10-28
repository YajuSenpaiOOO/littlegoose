extends RefCounted
## Decode an imported texture through Godot's resource remapping, including PCK.
static func read(path: String) -> Image:
 var texture := load(path) as Texture2D
 if texture==null:
  push_error("Expected imported Texture2D: "+path);return Image.new()
 var image := texture.get_image()
 if image.is_compressed(): image.decompress()
 return image
