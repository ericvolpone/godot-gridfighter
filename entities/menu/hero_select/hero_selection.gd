class_name HeroSelection extends Control

@export var border_default: CompressedTexture2D
@export var border_selected: CompressedTexture2D
@export var hero_definition: HeroDefinition
@onready var button: TextureButton = $Button
@onready var hero_image: TextureRect = $HeroImage
@onready var name_image: TextureRect = $NameImage

signal hero_selected;

func _ready() -> void:
	hero_image.texture = hero_definition.hero_portrait
	name_image.texture = hero_definition.hero_name
	var name_size: Vector2 = name_image.texture.get_size()
	var aspect_ratio: float = name_size.x / 134.0
	
	name_image.size = name_size / aspect_ratio 
	name_image.position.x -= name_image.size.x / 2
	name_image.position.y -= name_image.size.y


func _on_button_pressed() -> void:
	emit_signal(hero_selected.get_name())
