class_name HeroDefinition extends Resource

@export var hero_id: int;
@export var display_name: String;
@export var hero_scene: PackedScene;
@export var hero_portrait: ImageTexture
@export var hero_name: Texture2D

func instantiate() -> Hero:
	var hero: Hero = hero_scene.instantiate();
	hero.definition = self
	return hero;
