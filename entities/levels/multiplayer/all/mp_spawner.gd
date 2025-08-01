class_name MPSpawner extends MultiplayerSpawner

@onready var mp_level: AbstractMultiplayerLevel = get_parent();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("MP Ready")
	multiplayer.peer_connected.connect(spawn_player)
	add_spawnable_scene("res://entities/player/all/player.tscn")

func spawn_player(id: int) -> void:
	print("MP Server? " + str(multiplayer.is_server()))
	if not multiplayer.is_server(): return;
	print("MP Spawning " + str(id))
	var player: Player = mp_level.init_player(id, "Player" + str(id), true)
	player.add_brain(PlayerBrain.new())
	player.name = str(id)
	mp_level.player_chars[player] = player

	get_node(spawn_path).call_deferred("add_child", player)
	
	mp_level.respawn_player(player)
	
	print("Name: " + player.name);

func spawn_ai(id: int) -> void:
	var ai: Player = mp_level.init_player(id, "BOT " + str(id), false)
	ai.add_brain(KothAIBrain.new(mp_level))
	mp_level.ai_chars[ai] = ai
	get_node(spawn_path).call_deferred("add_child", ai)
	mp_level.respawn_player(ai)
