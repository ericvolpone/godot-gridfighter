class_name ProjectileSpawner extends MultiplayerSpawner

var rock_scene: PackedScene = preload("res://entities/objects/combat/rock.tscn")

@onready var level: Level = get_parent();

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("_configure_projectile_spawner")

func _configure_projectile_spawner() -> void:
	spawn_function = func(spawn_data: Dictionary) -> Rock:
		var peer_id: int = spawn_data["peer_id"]
		var rock: Rock = rock_scene.instantiate();
		rock.set_multiplayer_authority(peer_id)
		return rock
