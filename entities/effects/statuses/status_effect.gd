class_name StatusEffect extends Node3D

@export var status_effect_image: Texture2D
@onready var effect_sprite: Sprite3D = $Sprite3D

var tracking_player: Player;
var effect_ttl: float;
var spawn_data: Dictionary;

enum Type {
	SHOCKED,
	BURNT,
	COLD,
	FROZEN,
	ROOTED
}

func _ready() -> void:
	effect_sprite.texture = status_effect_image
	_initialize_from_spawn_data()
	NetworkTime.on_tick.connect(_tick)

func _initialize_from_spawn_data() -> void:
	global_position = tracking_player.global_position
	effect_ttl = spawn_data["effect_ttl"]

func _tick(delta: float, _tick_id: int) -> void:
	global_position = tracking_player.global_position
	effect_ttl -= delta
	if effect_ttl <= 0:
		tracking_player.status_effects.erase(self)
		queue_free()
		NetworkTime.on_tick.disconnect(_tick)
