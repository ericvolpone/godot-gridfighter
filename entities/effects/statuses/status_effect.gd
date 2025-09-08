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

enum Type {
	SHOCKED,
	BURNT,
	COLD,
	FROZEN,
	ROOTED
}

func _ready() -> void:
	effect_sprite.texture = status_effect_image

func _initialize_from_spawn_data(spawn_data: Dictionary) -> void:
	var owner_player_id: String = spawn_data["owner_player_id"]
	var players: Array[Node] = get_tree().get_nodes_in_group(Groups.PLAYER)

	print("Looking for owner player id: ", owner_player_id)
	for player: Player in players:
		print("Checking player id: ", player.player_id)
		if player.player_id == owner_player_id:
			print("Found player")
			tracking_player = player
			reparent(player)
			break
	global_position = tracking_player.global_position
	
	print("Has tracking player? " , str(tracking_player))
	effect_ttl = spawn_data["effect_ttl"]
	if effect_ttl > 0:
		if multiplayer.is_server():
			get_tree().create_timer(effect_ttl).timeout.connect(
				func() -> void: self.queue_free()
				)
