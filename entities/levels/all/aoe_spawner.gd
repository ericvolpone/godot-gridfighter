class_name AOESpawner extends MultiplayerSpawner

var storm_scene: PackedScene = preload("res://entities/objects/bolty/LightningStorm.tscn")

@onready var level: Level = get_parent();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_configure_aoe_spawner")

func _configure_aoe_spawner() -> void:
	spawn_function = func(spawn_data: Dictionary) -> AOE:
		var storm: LightningStorm = storm_scene.instantiate()
		storm.call_deferred("_initialize_from_spawn_data", spawn_data)
		return storm;

@rpc("any_peer", "call_local", "reliable")
func spawn_aoe(spawn_data: Dictionary) -> AOE:
	if not multiplayer.is_server():
		return null

	return spawn(spawn_data)
