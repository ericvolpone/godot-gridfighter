class_name StatusEffect extends Node3D

## Example Spawn Data
#{
	#"owner_player_id" : player.player_id,
	#"effect_ttl" : 5,
	#"effect_type" : Type.SHOCKED
#}

var tracking_player: Player;
var effect_ttl: float;

enum Type {
	SHOCKED,
	BURNED,
	FROZEN,
	ROOTED
}

func _initialize_from_spawn_data(spawn_data: Dictionary) -> void:
	var owner_player_id: String = spawn_data["owner_player_id"]
	var players: Array[Node] = get_tree().get_nodes_in_group(Groups.PLAYER)

	for player: Player in players:
		if player.player_id == owner_player_id:
			tracking_player = player
			break
	global_position = tracking_player.global_position

	effect_ttl = spawn_data["effect_ttl"]
	if effect_ttl > 0:
		if multiplayer.is_server():
			get_tree().create_timer(effect_ttl).timeout.connect(
				func() -> void: self.queue_free()
				)

func _physics_process(_delta: float) -> void:
	global_position = tracking_player.global_position
