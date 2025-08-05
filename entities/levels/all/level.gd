class_name Level extends Node3D

enum MatchType {
	UNDEFINED = 0,
	KING_OF_THE_HILL = 1, 
	DEATH_MATCH = 2, 
	ELIMINATION = 3,
	TUTORIAL = 4
}

# Export Variables
@export var spawn_locations: Array[Node3D];
@export var koth_manager: KothManager;

# Packed Scenes
var player_scene: PackedScene = preload("res://entities/player/all/player.tscn");

# Utility Variables
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Multiplayer Variables
@onready var mp_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var respawner: Respawner = $Respawner

# Lobby Variables
@onready var scoreboard: Scoreboard = $Scoreboard
var player_chars: Dictionary = {}
var ai_chars: Dictionary = {};
var respawn_time: float = 3;
var lobby_settings: LobbySettings;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Init default settings
	if not lobby_settings:
		lobby_settings = LobbySettings.default();

	# Enable Koth Manager
	if lobby_settings.is_koth:
		koth_manager.is_enabled = true;
		koth_manager.scoreboard = scoreboard
		koth_manager.start_cycle();

	# Handle offline games
	if multiplayer.multiplayer_peer == null:
		var peer: MultiplayerPeer = OfflineMultiplayerPeer.new()
		multiplayer.multiplayer_peer = peer
		multiplayer.set_root_path("/")
		print("Setup offline");

	# Configured MP Spawners
	call_deferred("_configure_spawner")

func init_player(id: int, player_name: String) -> Player:
	var player: Player = player_scene.instantiate();
	player.player_id = id;
	player.player_name = player_name
	return player;

func _configure_spawner() -> void:
	mp_spawner.spawn_function = func(spawn_data: Dictionary) -> Player:
		var peer_id: int = spawn_data["peer_id"]
		var player: Player = init_player(peer_id, "Player" + str(peer_id))
		player.name = str(peer_id)
		player.set_multiplayer_authority(peer_id)
		player_chars[player] = player
		var brain_type: Brain.BrainType = spawn_data["brain"]
		player.add_brain(Brain.new_brain_from_type_with_deps(brain_type, koth_manager))
		scoreboard.add_player_to_score(player);
		call_deferred("respawn_player", player)
		return player
	
	if(multiplayer.is_server()):
		var player: Player = mp_spawner.spawn({"peer_id": multiplayer.get_unique_id(), "brain" : Brain.BrainType.PLAYER})

		# 🔑 Spawn future connecting players
		multiplayer.peer_connected.connect(func(peer_id: int) -> void:
			var peer_player: Player = mp_spawner.spawn({"peer_id": peer_id, "brain" : Brain.BrainType.PLAYER})
		)
	
		if lobby_settings.ai_count > 0:
			for index: int in lobby_settings.ai_count:
				var brain_type: Brain.BrainType;
				if lobby_settings.is_koth:
					brain_type = Brain.BrainType.KOTH_AI
				else:
					brain_type = Brain.BrainType.ZERO
				var ai: Player = mp_spawner.spawn({"peer_id": multiplayer.get_unique_id() + index + 5, "brain" : brain_type})
				index += 1
				
				ai_chars[ai] = ai;
				pass

func get_match_type() -> MatchType:
	push_error("You must define a MP Match Type")
	return MatchType.UNDEFINED;

func handle_player_death(player: Player) -> void:
	respawner.respawn_player(player);

func respawn_player(player: Player) -> void:
	respawner.respawn_player(player);
