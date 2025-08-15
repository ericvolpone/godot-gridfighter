class_name Level extends Node3D

@onready var death_scene: PackedScene = preload("res://entities/effects/death/player_death.tscn")

# Multiplayer Variables
@onready var player_spawner: PlayerSpawner = $PlayerSpawner
@onready var projectile_spawner: ProjectileSpawner = $ProjectileSpawner
@onready var respawner: Respawner = $Respawner
@onready var koth_manager: KothManager = $KothManager
@onready var power_up_spawner: PowerUpSpawner = $PowerUpSpawner

# Lobby Variables
@onready var scoreboard: Scoreboard = $Scoreboard
# TODO: I can probably just like... do a groups check or something
var player_chars: Dictionary = {}
# TODO: It may clean things up to actually sync this some day
var lobby_settings: LobbySettings;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Init default settings
	if not lobby_settings:
		lobby_settings = LobbySettings.default();

	player_spawner.max_player_speed = lobby_settings.max_player_speed
	player_spawner.max_player_strength = lobby_settings.max_player_strength

	# Enable Koth Manager
	if lobby_settings.is_koth:
		koth_manager.is_enabled = true;
		koth_manager.scoreboard = scoreboard
		koth_manager.start_cycle();

	if lobby_settings.are_power_ups_enabled:
		power_up_spawner.are_power_ups_enabled = true
		power_up_spawner.spawn_time = lobby_settings.power_up_spawn_rate
		power_up_spawner.enabled_power_up_types = lobby_settings.enabled_power_ups
		power_up_spawner.start_cycle();

	# Handle offline games
	if multiplayer.multiplayer_peer == null:
		var peer: MultiplayerPeer = OfflineMultiplayerPeer.new()
		multiplayer.multiplayer_peer = peer
		multiplayer.set_root_path("/")
		print("Setup offline");

func handle_player_death(player: Player) -> void:
	if player.is_respawning:
		return
	_spawn_death_explosion.rpc(player.global_position)
	scoreboard.update_player_score(player, -5)
	
	# Move to the next hero
	# TODO hard coding hero IDs here, put in a registry
	var next_hero_id: int = player.current_hero_id + 1
	if next_hero_id > 1:
		next_hero_id = 0
	player.current_hero_id = next_hero_id
	
	respawner.respawn_player(player)

@rpc("call_local", "any_peer", "reliable")
func _spawn_death_explosion(location: Vector3) -> void:
	var death: PlayerDeath = death_scene.instantiate();
	add_child(death)
	death.global_position = location
