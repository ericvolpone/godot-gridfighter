@tool
extends SubViewport

@export var image_texture_name: String;

@export_tool_button("Generate Sprite")
var generate_sprite := func() -> void:
	if not image_texture_name:
		push_error("No PNG Name provided")
		return
	var image: Image = get_texture().get_image()
	var image_texture: ImageTexture = ImageTexture.create_from_image(image)
	ResourceSaver.save(image_texture, "res:///models/sprites/generated_sprites/" + image_texture_name + ".tres")
	print("Saved Resource")
