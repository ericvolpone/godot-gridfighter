class_name Level extends Node3D

enum MatchType {
	UNDEFINED = 0,
	KING_OF_THE_HILL = 1, 
	DEATH_MATCH = 2, 
	ELIMINATION = 3,
	TUTORIAL = 4
}

# Packed Scenes
var player_scene: PackedScene = preload("res://entities/player/all/player.tscn");

# Utility Variables
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Multiplayer Variables
@onready var mp_spawner: MultiplayerSpawner = $MultiplayerSpawner

# Lobby Variables
@export var spawn_locations: Array[Node3D];
var player_chars: Dictionary = {}
var ai_chars: Dictionary = {};
var respawn_time: float = 3;
var is_networked: bool = false;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if multiplayer.multiplayer_peer == null:
		var peer: MultiplayerPeer = OfflineMultiplayerPeer.new()
		multiplayer.multiplayer_peer = peer
		multiplayer.set_root_path("/")
		print("Setup offline");
	
	print("Multiplayer is_server? " + str(multiplayer.is_server()))
	
	call_deferred("_configure_spawner")

func init_player(id: int, player_name: String) -> Player:
	var player: Player = player_scene.instantiate();
	player.player_id = id;
	player.player_name = player_name
	return player;

func _configure_spawner() -> void:
	mp_spawner.spawn_function = func(peer_id: int) -> Player:


		print("Spawning player for peer_id:", peer_id)
		var player: Player = init_player(peer_id, "Player")
		player.name = str(peer_id)
		player_chars[player] = player
		add_player_to_score(player);
		call_deferred("respawn_player", player)
		return player
	
	if(multiplayer.is_server()):
		var player: Player = mp_spawner.spawn(multiplayer.get_unique_id())
		print("Player is here: " + player.name)
		player.add_brain(PlayerBrain.new())
		# 🔑 Spawn future connecting players
		multiplayer.peer_connected.connect(func(peer_id: int) -> void:
			print("New peer connected:", peer_id)
			var peer_player: Player = mp_spawner.spawn(peer_id)
			peer_player.add_brain(PlayerBrain.new())
		)

func get_match_type() -> MatchType:
	push_error("You must define a MP Match Type")
	return MatchType.UNDEFINED;

func handle_player_death(player: Player) -> void:
	match get_match_type():
		MatchType.KING_OF_THE_HILL:
			get_tree().create_timer(respawn_time).timeout.connect(func() -> void:
				respawn_player(player)
			);
		MatchType.DEATH_MATCH:
			pass;
		MatchType.ELIMINATION:
			pass
		_:
			if(player.is_player_controlled):
				player.global_position = get_player_spawn_positions()[0]
			else:
				ai_chars.erase(player)
				player.queue_free();
	

# Generic Methods, override in levels
func get_player_spawn_positions() -> Array[Vector3]:
	push_error("get_player_spawn_position Not Implemented")
	return [
		Vector3(0,0,0)
		];

func add_player_to_score(player: Player) -> void:
	push_error("add_player_to_score Not Implemented")
	pass;

func get_ai_spawn_locations() -> Array[Vector3]:
	push_error("Not Implemented")
	return []

func respawn_player(player: Player) -> void:
	push_error("respawn_player not implemented")
	var spawn_positions: Array = get_player_spawn_positions();
	var spawn_index: int = rng.randi_range(0, spawn_positions.size() - 1);
	player.global_position = spawn_positions[spawn_index];
