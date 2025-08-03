class_name AbstractMultiplayerLevel extends AbstractLevel

enum MPMatchType {
	UNDEFINED = 0,
	KING_OF_THE_HILL = 1, 
	DEATH_MATCH = 2, 
	ELIMINATION = 3
}

# Utility Variables
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Multiplayer Variables
@onready var mp_spawner: MultiplayerSpawner = $MultiplayerSpawner

# Lobby Variables
@export var spawn_locations: Array[Node3D];
var player_chars: Dictionary = {}
var ai_chars: Dictionary = {};
var respawn_time: float = 3;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready();
	call_deferred("_configure_spawner")

func _configure_spawner() -> void:
	mp_spawner.spawn_function = func(peer_id: int) -> Player:
		print("Spawning player for peer_id:", peer_id)
		var player: Player = init_player(peer_id, "Player", true)
		player.name = str(peer_id)
		player.add_brain(PlayerBrain.new())
		player_chars[player] = player
		add_player_to_score(player);
		respawn_player(player)
		return player
	
	if(multiplayer.is_server()):
		mp_spawner.spawn(multiplayer.get_unique_id())
		# 🔑 Spawn future connecting players
		multiplayer.peer_connected.connect(func(peer_id: int) -> void:
			print("New peer connected:", peer_id)
			mp_spawner.spawn(peer_id)
		)

func get_match_type() -> MPMatchType:
	push_error("You must define a MP Match Type")
	return MPMatchType.UNDEFINED;

func handle_player_death(player: Player) -> void:
	match get_match_type():
		MPMatchType.KING_OF_THE_HILL:
			get_tree().create_timer(respawn_time).timeout.connect(func() -> void:
				respawn_player(player)
			);
		MPMatchType.DEATH_MATCH:
			pass;
		MPMatchType.ELIMINATION:
			pass
		_:
			if(player.is_player_controlled):
				player.global_position = get_player_spawn_positions()[0]
			else:
				ai_chars.erase(player)
				player.queue_free();
	

# Generic Methods, override in levels
func get_player_spawn_positions() -> Array:
	push_error("get_player_spawn_position Not Implemented")
	return [
		Vector3(0,0,0)
		];

func add_player_to_score(player: Player) -> void:
	push_error("add_player_to_score Not Implemented")
	pass;

func get_ai_spawn_locations() -> Array:
	push_error("Not Implemented")
	return [Vector3(1,0,1)]

func respawn_player(player: Player) -> void:
	push_error("respawn_player not implemented")
	var spawn_positions: Array = get_player_spawn_positions();
	var spawn_index: int = rng.randi_range(0, spawn_positions.size() - 1);
	player.global_position = spawn_positions[spawn_index];
