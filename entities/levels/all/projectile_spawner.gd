class_name ProjectileSpawner extends MultiplayerSpawner

var rock_scene: PackedScene = preload("res://entities/objects/projectiles/rock/rock.tscn")

@onready var level: Level = get_parent();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_configure_projectile_spawner")

func _configure_projectile_spawner() -> void:
	spawn_function = func(spawn_data: Dictionary) -> Rock:
		var rock: Rock = rock_scene.instantiate();
		
		rock.call_deferred("initialize_from_spawn_data", spawn_data)
		return rock

@rpc("any_peer", "call_local", "reliable")
func spawn_projectile(spawn_data: Dictionary) -> void:
	if not multiplayer.is_server():
		return

	spawn(spawn_data)
