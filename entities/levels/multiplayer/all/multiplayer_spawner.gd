class_name MPSpawner extends MultiplayerSpawner

@onready var mp_level: AbstractMultiplayerLevel = get_parent();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(spawn_player)

func spawn_player(id: int) -> void:
	var player: Player = mp_level.init_player(id, "Player" + str(id), true)
	
	player.name = str(id)
	player.add_brain(PlayerBrain.new())
	mp_level.player_chars[player] = player

	get_node(spawn_path).call_deferred("add_child", player)
	
	mp_level.respawn_player(player)
	
	var mp_synchronizer: MultiplayerSynchronizer = MultiplayerSynchronizer.new()
	player.add_child(mp_synchronizer)
	player.set_multiplayer_authority(name.to_int())
	

func spawn_ai(id: int) -> void:
	var ai: Player = mp_level.init_player(id, "BOT " + str(id), false)
	ai.add_brain(KothAIBrain.new(mp_level))
	mp_level.ai_chars[ai] = ai
	get_node(spawn_path).call_deferred("add_child", ai)
	mp_level.respawn_player(ai)
