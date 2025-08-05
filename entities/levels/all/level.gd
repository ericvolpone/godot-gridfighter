class_name Level extends Node3D

# Packed Scenes
var player_scene: PackedScene = preload("res://entities/player/all/player.tscn");

# Utility Variables
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Multiplayer Variables
@onready var player_spawner: MultiplayerSpawner = $PlayerSpawner
@onready var projectile_spawner: MultiplayerSpawner = $ProjectileMPSpawner
@onready var respawner: Respawner = $Respawner
@onready var koth_manager: KothManager = $KothManager

# Lobby Variables
@onready var scoreboard: Scoreboard = $Scoreboard
var player_chars: Dictionary = {}
var ai_chars: Dictionary = {}; # TODO Might not need this except in tutorials?
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

func handle_player_death(player: Player) -> void:
	respawner.respawn_player(player);
