class_name HeroDefinition extends Resource

@export var id: int;
@export var display_name: String;
@export var hero_scene: PackedScene;

func instantiate() -> Hero:
	return hero_scene.instantiate() as Hero;
