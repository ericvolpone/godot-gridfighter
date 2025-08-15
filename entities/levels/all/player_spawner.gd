class_name PlayerSpawner extends MultiplayerSpawner

var player_scene: PackedScene = preload("res://entities/player/all/player.tscn")

@export var respawner: Respawner;
var max_player_speed: float = 10;
var max_player_strength: float = 10;
@onready var level: Level = get_parent()

# Track who already spawned to prevent duplicates and to handle reconnects
var _spawned_peers: Dictionary[int, bool] = {} # peer_id -> true

func _ready() -> void:
	call_deferred("_configure_player_spawner")

func init_player(id: int, player_name: String) -> Player:
	var player: Player = player_scene.instantiate();
	player.player_id = id
	player.player_name = player_name
	return player;

func _configure_player_spawner() -> void:
	spawn_function = func(spawn_data: Dictionary) -> Player:
		var peer_id: int = spawn_data["peer_id"]
		var player: Player = init_player(peer_id, "Player" + str(get_child_count()))
		var hero_id: int = spawn_data.get("hero_id", 0)
		player.name = str(peer_id)
		player.chosen_hero_id = hero_id
		player.set_multiplayer_authority(peer_id)
		level.player_chars[player] = player
		var brain_type: Brain.BrainType = spawn_data["brain"]
		# Quick hack to get AI players workingsddddddddwsd
		player.add_brain(Brain.new_brain_from_type_with_deps(brain_type, level.koth_manager))
		player.brain.set_multiplayer_authority(player.get_multiplayer_authority())
		player.max_player_speed = max_player_speed
		player.max_player_strength = max_player_strength
		level.scoreboard.add_player_to_score(player);
		_spawned_peers[peer_id] = true
		call_deferred("respawn_player", player)
		return player
	
	if(multiplayer.is_server()):
		#spawn({"peer_id": multiplayer.get_unique_id(), "brain" : Brain.BrainType.PLAYER})
#
		## 🔑 Spawn future connecting players
		#multiplayer.peer_connected.connect(func(peer_id: int) -> void:
			#spawn({"peer_id": peer_id, "brain" : Brain.BrainType.PLAYER})
		#)
	
		if level.lobby_settings.ai_count > 0:
			for index: int in level.lobby_settings.ai_count:
				var brain_type: Brain.BrainType;
				if level.lobby_settings.is_koth:
					brain_type = Brain.BrainType.KOTH_AI
				else:
					brain_type = Brain.BrainType.ZERO
				spawn({"peer_id": multiplayer.get_unique_id(), "brain" : brain_type})

@rpc("any_peer", "reliable")
func request_spawn(hero_id: int) -> void:
	# Only the server should honor this and call spawn()
	if !multiplayer.is_server():
		return

	var requester: int = multiplayer.get_remote_sender_id()
	# If the server called locally (for its own player), get_remote_sender_id() returns 0.
	if requester == 0:
		requester = multiplayer.get_unique_id()

	if _spawned_peers.has(requester):
		return # already spawned—ignore duplicate clicks, scene reloads, etc.

	spawn({
		"peer_id": requester,
		"brain": Brain.BrainType.PLAYER,
		"hero_id": hero_id
	})

func respawn_player(player: Player) -> void:
	respawner.respawn_player(player)
