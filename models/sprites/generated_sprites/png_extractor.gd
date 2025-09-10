@tool
extends Node
@export var image_texture: ImageTexture;
@export var png_name: String

@export_tool_button("Extract PNG")
var generate_png := func() -> void:
	if not image_texture or not png_name or png_name.length() == 0:
		push_error("Must provide all input")
		return
	var image: Image = image_texture.get_image()
	var png_path: String = "res:///models/sprites/generated_sprites/" + png_name + ".png"
	image.save_png(png_path)
	print("Saved PNG")
