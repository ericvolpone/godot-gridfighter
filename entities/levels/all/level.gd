class_name Level extends Node3D

@onready var death_scene: PackedScene = preload("res://entities/effects/death/player_death.tscn")

# Packed Scenes
var player_scene: PackedScene = preload("res://entities/player/all/player.tscn");

# Utility Variables
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

# Multiplayer Variables
@onready var player_spawner: PlayerSpawner = $PlayerSpawner
@onready var projectile_spawner: ProjectileSpawner = $ProjectileSpawner
@onready var respawner: Respawner = $Respawner
@onready var koth_manager: KothManager = $KothManager
@onready var power_up_spawner: PowerUpSpawner = $PowerUpSpawner

# Lobby Variables
@onready var scoreboard: Scoreboard = $Scoreboard
var player_chars: Dictionary = {}
var respawn_time: float = 3;
var lobby_settings: LobbySettings;


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Init default settings
	if not lobby_settings:
		lobby_settings = LobbySettings.default();

	player_spawner.max_player_speed = lobby_settings.max_player_speed

	# Enable Koth Manager
	if lobby_settings.is_koth:
		koth_manager.is_enabled = true;
		koth_manager.scoreboard = scoreboard
		koth_manager.start_cycle();

	if lobby_settings.are_power_ups_enabled:
		power_up_spawner.are_power_ups_enabled = true
		power_up_spawner.spawn_time = lobby_settings.power_up_spawn_rate
		power_up_spawner.start_cycle();

	# Handle offline games
	if multiplayer.multiplayer_peer == null:
		var peer: MultiplayerPeer = OfflineMultiplayerPeer.new()
		multiplayer.multiplayer_peer = peer
		multiplayer.set_root_path("/")
		print("Setup offline");

func handle_player_death(player: Player) -> void:
	var death: Node3D = death_scene.instantiate();
	print("Adding death")
	add_child(death)
	death.global_position = player.global_position
	respawner.respawn_player(player);
