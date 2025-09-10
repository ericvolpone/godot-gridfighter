class_name StatusEffect extends Node3D

## Example Spawn Data
#{
	#"owner_player_id" : player.player_id,
	#"effect_ttl" : 5,
	#"effect_type" : Type.SHOCKED
#}

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
	var owner_player_id: String = spawn_data["owner_player_id"]
	var players: Array[Node] = get_tree().get_nodes_in_group(Groups.PLAYER)

	for player: Player in players:
		if player.player_id == owner_player_id:
			tracking_player = player
			break
	global_position = tracking_player.global_position

	effect_ttl = spawn_data["effect_ttl"]

func _tick(delta: float, _tick_id: int) -> void:
	global_position = tracking_player.global_position
	effect_ttl -= delta
	if effect_ttl <= 0 and is_multiplayer_authority():
		queue_free()
